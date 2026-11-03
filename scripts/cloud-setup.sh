#!/bin/bash
# Script de configuração do ambiente de nuvem (Claude Code).
# Cole este conteúdo em: ambiente > Editar > Script de configuração.
# Cada etapa é independente: se uma falhar, as outras continuam.

step() { echo "==> $1"; shift; "$@" || echo "AVISO: etapa falhou: $*"; }

# 1. Dependências Python do OpenMontage + ferramentas locais
step "requirements OpenMontage" bash -c 'pip install -q -r https://raw.githubusercontent.com/caioSouzl/OpenMontage/main/requirements.txt'
step "ferramentas locais" pip install -q faster-whisper piper-tts youtube-transcript-api mediapipe opencv-python "yt-dlp[default]"

# 2. Voz Piper em português do Brasil
mkdir -p "$HOME/.piper/models"
[ -f "$HOME/.piper/models/pt_BR-faber-medium.onnx" ] || \
  step "voz pt-BR" python -m piper.download_voices --download-dir "$HOME/.piper/models" pt_BR-faber-medium

# 3. yt-dlp usando o Node como runtime JavaScript (YouTube)
mkdir -p "$HOME/.config/yt-dlp"
grep -qs -- "--js-runtimes" "$HOME/.config/yt-dlp/config" || echo "--js-runtimes node" >> "$HOME/.config/yt-dlp/config"

# 4. Blender 5.2.3 + monitor virtual (para o mcp-for-blender)
if ! command -v blender >/dev/null; then
  step "blender" bash -c 'curl -sSL -o /tmp/blender.tar.xz https://download.blender.org/release/Blender5.2/blender-5.2.3-linux-x64.tar.xz && tar -xJf /tmp/blender.tar.xz -C /opt && rm -f /tmp/blender.tar.xz && ln -sf /opt/blender-5.2.3-linux-x64/blender /usr/local/bin/blender'
fi
command -v xvfb-run >/dev/null || step "xvfb" bash -c 'apt-get update -qq && apt-get install -y -qq xvfb'

# 5. HyperFrames e Remotion (dependências do OpenMontage, se já estiver clonado)
step "hyperframes" npx --yes hyperframes --version
for d in /home/user/OpenMontage /home/user/openmontage; do
  [ -d "$d/remotion-composer" ] && step "remotion" bash -c "cd '$d/remotion-composer' && npm ci --no-audit --no-fund"
done

echo "==> Configuração concluída"
exit 0
