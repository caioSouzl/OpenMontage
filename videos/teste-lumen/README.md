# LUMEN — teste (motion graphics 9:16)

10 s · 1080x1920 · 30 fps · HyperFrames (HTML + GSAP)

- `index.html` — composição (timeline única, determinística)
- `scripts/gen_sfx.py` — gera `audio/sfx.wav` (bipes discretos, pico −22 dBFS)
- `render.sh` — gera SFX → renderiza → mixa `audio/narracao.mp3` (se existir) a partir de 0,5 s, com os SFX abaixados sob a voz (sidechain)
- `renders/lumen_teste.mp4` — entrega final

Para incluir a narração: coloque o arquivo em `audio/narracao.mp3` e rode `./render.sh`.
