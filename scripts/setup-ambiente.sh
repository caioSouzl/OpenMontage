#!/usr/bin/env bash
# Prepara um ambiente Linux (nuvem ou local) com todas as ferramentas
# locais/gratuitas usadas pelo OpenMontage e pelos repositórios auxiliares.
#
# Uso:  bash scripts/setup-ambiente.sh            (essencial)
#       FULL=1 bash scripts/setup-ambiente.sh     (+ Blender, ComfyUI, chatterbox)
#
# Idempotente: pode rodar várias vezes. Requer rede liberada para PyPI, npm,
# Hugging Face, download.pytorch.org e download.blender.org.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPOS="${REPOS_DIR:-$HOME/repos}"      # onde clonar ComfyUI/chatterbox (modo FULL)
VENVS="${VENVS_DIR:-$HOME/.venvs}"
BLENDER_VERSION="${BLENDER_VERSION:-5.2.3}"

log() { printf '\n==> %s\n' "$*"; }

log "Dependências Python do OpenMontage"
pip install -q -r "$ROOT/requirements.txt"
pip install -q faster-whisper piper-tts youtube-transcript-api mediapipe opencv-python "yt-dlp[default]"

log "Voz Piper pt-BR (TTS local gratuito)"
mkdir -p "$HOME/.piper/models"
[ -f "$HOME/.piper/models/pt_BR-faber-medium.onnx" ] || \
  python -m piper.download_voices --download-dir "$HOME/.piper/models" pt_BR-faber-medium

log "yt-dlp: usar Node como runtime JavaScript (necessário para o YouTube)"
mkdir -p "$HOME/.config/yt-dlp"
grep -qs -- "--js-runtimes" "$HOME/.config/yt-dlp/config" || echo "--js-runtimes node" >> "$HOME/.config/yt-dlp/config"

log "Remotion (remotion-composer)"
(cd "$ROOT/remotion-composer" && npm ci --no-audit --no-fund)

log "HyperFrames (pré-carrega o pacote npm)"
npx --yes hyperframes --version

if [ "${FULL:-0}" = "1" ]; then
  log "Blender $BLENDER_VERSION + monitor virtual (xvfb) para o mcp-for-blender"
  if ! command -v blender >/dev/null; then
    major="${BLENDER_VERSION%.*}"
    curl -sSL -o /tmp/blender.tar.xz \
      "https://download.blender.org/release/Blender${major}/blender-${BLENDER_VERSION}-linux-x64.tar.xz"
    tar -xJf /tmp/blender.tar.xz -C /opt && rm /tmp/blender.tar.xz
    ln -sf "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender
  fi
  command -v xvfb-run >/dev/null || { apt-get update -qq && apt-get install -y -qq xvfb; }

  mkdir -p "$REPOS" "$VENVS"
  command -v uv >/dev/null || pip install -q uv

  log "ComfyUI (PyTorch CPU; troque o índice por CUDA se houver GPU NVIDIA)"
  [ -d "$REPOS/ComfyUI" ] || git clone --depth 1 https://github.com/caioSouzl/ComfyUI "$REPOS/ComfyUI"
  [ -d "$VENVS/comfyui" ] || uv venv -q -p 3.13 "$VENVS/comfyui"
  VIRTUAL_ENV="$VENVS/comfyui" uv pip install -q torch torchvision torchaudio --index-url "${TORCH_INDEX:-https://download.pytorch.org/whl/cpu}"
  VIRTUAL_ENV="$VENVS/comfyui" uv pip install -q -r "$REPOS/ComfyUI/requirements.txt"

  log "chatterbox (TTS com clonagem de voz, suporta pt-BR)"
  [ -d "$REPOS/chatterbox" ] || git clone --depth 1 https://github.com/caioSouzl/chatterbox "$REPOS/chatterbox"
  [ -d "$VENVS/chatterbox" ] || uv venv -q -p 3.13 "$VENVS/chatterbox"
  VIRTUAL_ENV="$VENVS/chatterbox" uv pip install -q torch==2.6.0 torchaudio==2.6.0 --index-url "${TORCH_INDEX:-https://download.pytorch.org/whl/cpu}"
  VIRTUAL_ENV="$VENVS/chatterbox" uv pip install -q -e "$REPOS/chatterbox"
fi

log "Verificação"
cd "$ROOT"
python - <<'EOF'
from tools.tool_registry import registry
registry.discover()
s = registry.provider_menu_summary()
print("runtimes:", s["composition_runtimes"])
for c in s["capabilities"]:
    if c["capability"] in ("tts", "analysis", "3d_world_rendering", "image_generation", "video_generation"):
        print(f'  {c["capability"]}: {c["configured"]}/{c["total"]}')
EOF
echo "Pronto."
