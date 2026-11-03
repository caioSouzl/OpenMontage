#!/usr/bin/env bash
# LUMEN — render pipeline
#   1. generate SFX (audio/sfx.wav)
#   2. render the HyperFrames composition (1080x1920, 30 fps) with SFX
#   3. if audio/narracao.mp3 exists: mix it in from 0.5 s, in the foreground
#      (SFX are ducked under the voice via sidechain compression)
set -euo pipefail
cd "$(dirname "$0")"

python3 scripts/gen_sfx.py

npx --yes hyperframes render . --fps 30 --quality high --output renders/lumen_base.mp4

FINAL=renders/lumen_teste.mp4
if [ -f audio/narracao.mp3 ]; then
  echo "narracao.mp3 encontrada — mixando a partir de 0,5 s"
  ffmpeg -y -v error -i renders/lumen_base.mp4 -i audio/narracao.mp3 -filter_complex "\
    [1:a]aresample=48000,aformat=channel_layouts=stereo,adelay=500|500,volume=1.0,asplit=2[vo][sc];\
    [0:a]aresample=48000,aformat=channel_layouts=stereo,volume=0.8[fx];\
    [fx][sc]sidechaincompress=threshold=0.02:ratio=8:attack=5:release=250[fxd];\
    [vo][fxd]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[a]" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -t 10 "$FINAL"
else
  echo "AVISO: audio/narracao.mp3 não encontrado — renderizando sem narração"
  cp renders/lumen_base.mp4 "$FINAL"
fi

ffprobe -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate -of compact "$FINAL"
echo "OK -> $(pwd)/$FINAL"
