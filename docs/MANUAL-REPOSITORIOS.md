# Manual dos repositórios — caioSouzl

Análise feita em 03/11/2026 com os 21 repositórios da conta. Cada um foi clonado e testado em um ambiente Linux na nuvem (Node 22, Python 3.13, FFmpeg 6.1, sem GPU). Esse ambiente bloqueia o acesso a Hugging Face, PyTorch, YouTube e blender.org. Por isso, os projetos que dependem de modelos de IA foram verificados até onde a rede permitiu, e isso está indicado em cada caso.

Todos os 19 forks estão idênticos ao projeto original: nenhum tem alterações suas. Para usá-los, normalmente é melhor instalar a versão publicada (npm, PyPI ou binário oficial) do que compilar o fork. O fork só faz diferença se você quiser modificar o código.

---

## 1. Situação de cada repositório

| Repositório | O que é | Funciona? | Evidência do teste |
|---|---|---|---|
| OpenMontage | Sistema de produção de vídeo guiado por agente | Sim | 2.228 testes passaram; HyperFrames e Remotion renderizaram vídeos |
| hyperframes | Motor de vídeo em HTML/CSS/GSAP | Sim | Instalação e build completos do monorepo; CLI v0.9.9 executa |
| remotion | Motor de vídeo em React (código-fonte) | Sim (via npm) | O Remotion do OpenMontage listou as composições e renderizou um MP4 |
| GSAP | Biblioteca de animação JavaScript | Sim | Pasta `dist` completa, versão 3.15.0 |
| three.js | Biblioteca 3D para navegador | Sim (via npm) | Fork íntegro; uso normal por npm/CDN |
| FFmpeg | Processamento de áudio e vídeo (código-fonte) | Sim (binário) | Não é preciso compilar: o binário do sistema funciona |
| yt-dlp | Download de vídeos | Sim | 119 testes passaram; versão 2026.10.26 |
| faster-whisper | Transcrição de fala (Whisper) | Parcial | Instala e importa; o modelo não pôde ser baixado aqui (rede bloqueada) |
| chatterbox | Síntese de voz (TTS), com português | Precisa de configuração | Depende de PyTorch 2.6 e de modelos do Hugging Face |
| ComfyUI | Geração de imagem/vídeo por nós | Precisa de configuração | Depende de PyTorch, GPU e modelos baixados manualmente |
| blender | Software 3D (código-fonte) | Precisa de instalação | Não há executável do Blender instalado |
| mcp-for-blender | Servidor MCP que controla o Blender por IA | Sim (via PyPI) | 545 testes passaram, 1 falhou (ver seção 2) |
| chrome-devtools-mcp | Servidor MCP que controla o Chrome | Sim | `npm ci` e build ok; o CLI responde |
| impeccable | Skill de design e detector de "AI slop" | Sim | Build das skills ok; 253 testes passaram |
| skills | 13 skills oficiais de Remotion | Sim | Todos os `SKILL.md` válidos |
| motion-prompt | Biblioteca de nomes de movimentos e efeitos | Sim | 192 itens verificados, 0 falhas |
| cinetic | Skill de motion design | Sim | `SKILL.md` válido |
| taste-skill | Skill de gosto visual para frontend | Sim | 8 testes passaram (um exige o pacote `yaml`) |
| ui-ux-pro-max-skill | Base de dados de UI/UX pesquisável | Sim | A busca funciona; os assets estão sincronizados |
| G.E | Repositório privado | Não | Vazio: nenhum commit, nenhum arquivo |
| Claude-Code | Repositório privado | Não (sem conteúdo) | Só tem um README com o texto "Projetos pessoal" |

---

## 2. O que fazer nos que não estão funcionando

**G.E.** O repositório foi criado, mas nunca recebeu commit. Faça o primeiro commit com o conteúdo pretendido. Se ele não tem mais uso, apague-o no GitHub.

**Claude-Code.** Só tem o README. Envie os projetos pessoais que pretendia guardar nele. Corrija também o texto do README para "Projetos pessoais".

**blender.** Para usar o Blender, não compile o fork: a compilação exige dezenas de GB e várias horas. Baixe o executável oficial em blender.org (versão 4.2 LTS ou mais nova) e coloque o comando `blender` no PATH. Isso ativa a ferramenta `blender_world` do OpenMontage e permite usar o mcp-for-blender. Para conferir, rode `blender --version`.

**ComfyUI.** Precisa de uma máquina com GPU NVIDIA (8 GB de VRAM no mínimo; 16 GB recomendados para vídeo).
1. Crie um ambiente Python 3.12 ou 3.13.
2. Instale o PyTorch para CUDA conforme o site pytorch.org.
3. Rode `pip install -r requirements.txt` na pasta do fork.
4. Coloque os modelos em `models/checkpoints`, `models/vae` etc.
5. Inicie com `python main.py`. A interface abre em `http://127.0.0.1:8188`.

Para o OpenMontage usar o ComfyUI, deixe-o rodando e configure o endereço conforme a mensagem de instalação que o registro de ferramentas mostra.

**chatterbox.** Precisa de PyTorch 2.6 e de acesso ao Hugging Face (os modelos são baixados no primeiro uso). Use Python 3.10 a 3.13 e rode `pip install -e .` na pasta do fork. Também funciona em CPU, só que devagar. A versão "Multilingual" suporta português.

**faster-whisper.** Já instala. Falta só a máquina ter acesso ao Hugging Face para baixar o modelo na primeira execução. Sem internet, baixe o modelo antes e passe o caminho da pasta em vez do nome.

**mcp-for-blender.** O único teste que falha acontece porque o arquivo `src/blender_mcp/config.py` é gerado na publicação e não fica no repositório. Instale pela versão publicada: `uvx mcp-for-blender`. Só use o fork se for alterar o código; nesse caso, crie um `config.py` mínimo com o objeto `telemetry_config`.

**OpenMontage.** Funciona, mas três ajustes ampliam o que ele consegue fazer:
1. Rode `npm ci` dentro de `remotion-composer/`. Sem isso o Remotion aparece como indisponível. Neste ambiente o comando já foi executado e o Remotion voltou a funcionar.
2. Configure chaves de API no arquivo `.env` da raiz para liberar voz, imagem, vídeo e música por IA. Hoje há 0 de 18 provedores de voz e 0 de 29 de imagem configurados. Os nomes das variáveis aparecem no menu de pré-checagem (seção 3.1).
3. Para narração gratuita e local, use o Piper TTS, que já vem incluído e baixa a voz na primeira execução.

---

## 3. Manual de uso

### 3.1 OpenMontage

**Para que serve.** Produzir vídeos completos (explicativos, animações, trailers, cortes de podcast, vídeos com avatar) conduzindo um agente de IA por etapas: pesquisa, proposta, roteiro, plano de cenas, assets, edição e composição.

**Requisitos.** Python 3.10 ou mais novo, Node 22 ou mais novo, FFmpeg.

**Instalação.**
1. Na raiz do repositório: `pip install -r requirements.txt`.
2. Em `remotion-composer/`: `npm ci`.
3. O HyperFrames não precisa ser instalado; ele é chamado com `npx hyperframes`.
4. Opcional: crie `.env` com as chaves dos provedores que for usar.

**Como usar.**
1. Abra o repositório em um agente (Claude Code, Cursor, Codex). O agente lê `AGENT_GUIDE.md` automaticamente.
2. Peça o vídeo em linguagem natural, informando duração, formato, tom e público.
3. O agente escolhe um pipeline em `pipeline_defs/` e roda a pré-checagem, que mostra quais ferramentas estão disponíveis.
4. Em cada etapa com aprovação, ele pausa e espera a sua resposta.

**Pipelines.** `animated-explainer`, `animation`, `cinematic`, `talking-head`, `screen-demo`, `clip-factory`, `podcast-repurpose`, `hybrid`, `avatar-spokesperson`, `localization-dub`, `character-animation`, `documentary-montage`.

**Motores de render.**
- **HyperFrames:** melhor para tipografia animada e motion graphics.
- **Remotion:** melhor para cenas em React, gráficos e legendas palavra por palavra.
- **FFmpeg:** cortes e concatenação simples.

**Saída.** Os trabalhos ficam em `projects/<nome-do-projeto>/`, e o vídeo final em `renders/final.mp4`. O painel Backlot (`python -m backlot open <projeto>`) mostra o andamento no navegador.

**Pré-checagem manual.** Rode `python -c "from tools.tool_registry import registry; import json; registry.discover(); print(json.dumps(registry.provider_menu_summary(), indent=2))"`.

**Testes.** `python -m pytest tests`.

### 3.2 hyperframes

**Para que serve.** Transformar um arquivo HTML com animações GSAP em vídeo MP4, quadro a quadro e de forma determinística.

**Uso sem o fork (recomendado).** Todos os comandos rodam com `npx hyperframes`:
- `init nome-do-projeto` cria um projeto.
- `lint`, `validate` e `inspect` verificam a composição.
- `snapshot --at 1,3,5` captura quadros específicos.
- `preview` abre o editor Studio.
- `render --fps 30 --quality high --output video.mp4` renderiza.

**Regras principais de autoria.**
- O elemento raiz precisa de `data-composition-id`, `data-width`, `data-height` e `data-duration`.
- Use uma única timeline GSAP pausada, registrada em `window.__timelines`.
- Nada de `Math.random` sem semente, relógio do sistema ou loops infinitos.
- Áudio e vídeo devem ser filhos diretos da raiz.
- Arquivos externos devem ficar locais. Em redes restritas, copie o `gsap.min.js` para dentro do projeto.

**Uso do fork.** Rode `bun install` e depois `bun run build`. O CLI fica em `packages/cli/dist/cli.js`. Só vale a pena se você for modificar o motor.

**Exemplo real.** O projeto `videos/teste-lumen/` neste repositório.

### 3.3 remotion

**Para que serve.** Criar vídeos programando componentes React. Cada quadro é uma renderização do componente no instante correspondente.

**Uso sem o fork.**
- Projeto novo: `npx create-video@latest`.
- Projeto existente: `npm i remotion @remotion/cli`.

**Comandos.**
- `npx remotion studio` abre o editor no navegador.
- `npx remotion compositions <entrada>` lista as composições.
- `npx remotion render <entrada> <IdDaComposicao> saida.mp4` renderiza.

Em redes que bloqueiam o download do Chrome, acrescente `--browser-executable=<caminho do Chrome/Chromium>`.

**Conceitos.**
- `<Composition>` define o ID, a duração em quadros, o fps e o tamanho.
- `useCurrentFrame()` retorna o quadro atual.
- `interpolate()` e `spring()` criam as animações.
- `<Sequence>` posiciona elementos no tempo.
- `<Audio>`, `<Video>` e `<Img>` incluem mídia.

**Licença.** A Remotion é gratuita para pessoas físicas e empresas de até 3 funcionários. Acima disso exige licença paga; a skill `remotion-license` do repositório `skills` explica os detalhes.

**Uso do fork.** O monorepo usa bun 1.4. Rode `bun install` e `bun run build`. Só vale a pena para contribuir com o projeto.

### 3.4 GSAP

**Para que serve.** Animar qualquer propriedade de elementos HTML, SVG, canvas ou objetos JavaScript.

**Instalação.** `npm i gsap`, ou copie `dist/gsap.min.js` do fork para o seu projeto.

**Conceitos.**
- `gsap.to`, `gsap.from` e `gsap.fromTo` criam animações individuais (tweens).
- `gsap.timeline()` encadeia animações; o terceiro argumento define a posição no tempo.
- `ease` controla a curva, por exemplo `power2.out` ou `sine.inOut`.
- `stagger` escalona a mesma animação entre vários elementos.

**Plugins.** Ficam na pasta `dist`: ScrollTrigger, SplitText, MorphSVG, DrawSVG, MotionPath, Flip, CustomEase e outros. Desde a versão 3.13 todos são gratuitos. Registre-os com `gsap.registerPlugin(NomeDoPlugin)`.

### 3.5 three.js

**Para que serve.** Criar cenas 3D em tempo real no navegador com WebGL ou WebGPU.

**Instalação.** `npm i three`.

**Estrutura mínima de uma cena.**
1. Crie uma cena (`Scene`) e uma câmera (`PerspectiveCamera`).
2. Crie um renderizador (`WebGLRenderer`) e adicione o canvas dele à página.
3. Adicione objetos (`Mesh` = geometria + material) e luzes.
4. Chame `renderer.render(scene, camera)` em um loop de animação.

Os módulos extras (`OrbitControls`, `GLTFLoader` etc.) ficam em `three/addons/`. No OpenMontage, o three.js é usado pela ferramenta `threejs_world` dentro do HyperFrames.

### 3.6 FFmpeg

**Para que serve.** Converter, cortar, juntar, redimensionar e mixar áudio e vídeo.

**Instalação.** Use o pacote do sistema operacional (`apt install ffmpeg`, `brew install ffmpeg` ou o executável oficial no Windows). O fork é o código-fonte; compile apenas se precisar de uma configuração específica (`./configure && make`).

**Operações comuns.**
- **Converter:** `ffmpeg -i entrada.mov saida.mp4`.
- **Cortar sem recodificar:** `ffmpeg -ss 00:00:05 -to 00:00:15 -i entrada.mp4 -c copy corte.mp4`.
- **Redimensionar:** `ffmpeg -i entrada.mp4 -vf scale=1080:1920 saida.mp4`.
- **Extrair o áudio:** `ffmpeg -i video.mp4 -vn audio.mp3`.
- **Inspecionar um arquivo:** `ffprobe -v error -show_format -show_streams arquivo.mp4`.

### 3.7 yt-dlp

**Para que serve.** Baixar vídeo, áudio e legendas do YouTube e de mais de mil sites.

**Instalação.** `pip install yt-dlp`, ou na pasta do fork `python -m yt_dlp`.

**Comandos comuns.**
- Baixar: `yt-dlp URL`.
- Só o áudio: `yt-dlp -x --audio-format mp3 URL`.
- Escolher a qualidade: `yt-dlp -f "bv*[height<=1080]+ba" URL`.
- Legendas: `yt-dlp --write-subs --sub-langs pt URL`.
- Só informações: `yt-dlp --simulate --print title URL`.

O FFmpeg precisa estar instalado para juntar áudio e vídeo. Respeite os direitos autorais e os termos de cada site.

### 3.8 faster-whisper

**Para que serve.** Transcrever áudio em texto, com marcação de tempo, até 4 vezes mais rápido que o Whisper original.

**Instalação.** `pip install faster-whisper`, ou `pip install -e .` na pasta do fork.

**Como usar em Python.**
1. Crie o modelo: `WhisperModel("small", device="cpu", compute_type="int8")`. Com GPU, use `device="cuda"` e `compute_type="float16"`.
2. Transcreva: `segments, info = model.transcribe("audio.mp3", language="pt", word_timestamps=True)`.
3. Percorra `segments`; cada item tem `start`, `end` e `text`.

**Tamanhos de modelo.** `tiny`, `base`, `small`, `medium`, `large-v3` e `turbo`. Quanto maior, mais preciso e mais lento. O download é automático no primeiro uso.

No OpenMontage, a ferramenta `transcriber` já usa essa biblioteca para legendas e análise.

### 3.9 chatterbox

**Para que serve.** Síntese de voz de código aberto, com clonagem de voz a partir de alguns segundos de referência. A versão Multilingual V3 suporta mais de 23 idiomas. Também existe um modelo dedicado ao português do Brasil (`ResembleAI/Chatterbox-Multilingual-pt-br`), com qualidade superior para pt-BR.

**Instalação.** Python 3.10 a 3.13. Rode `pip install chatterbox-tts`, ou `pip install -e .` na pasta do fork. Uma GPU é recomendada.

**Como usar.**
1. Importe com `from chatterbox.mtl_tts import ChatterboxMultilingualTTS` e carregue o modelo com `ChatterboxMultilingualTTS.from_pretrained(device="cuda")`. Use `device="mps"` no Mac e `"cpu"` sem GPU.
2. Gere a fala com `model.generate("texto", language_id="pt", audio_prompt_path="referencia.wav")`.
3. Salve com `torchaudio.save`.

**Ajustes.**
- `exaggeration` controla a expressividade (0,5 é neutro).
- `cfg_weight` controla o ritmo; valores mais baixos deixam a fala mais lenta e clara.

**Interfaces prontas.** `gradio_tts_app.py`, `multilingual_app.py` e `gradio_vc_app.py` (conversão de voz). Os áudios gerados levam uma marca d'água inaudível (Perth).

### 3.10 ComfyUI

**Para que serve.** Gerar imagens, vídeos, áudio e 3D com modelos de difusão, montando fluxos de trabalho em nós.

**Instalação.** Veja a seção 2.

**Como usar.**
1. Inicie com `python main.py`. Sem GPU, use `--cpu` (muito lento).
2. Abra `http://127.0.0.1:8188`.
3. Carregue um fluxo de trabalho (arquivo JSON ou imagem PNG gerada pelo ComfyUI).
4. Ajuste os nós e clique em "Queue".

**Pastas.**
- `models/` recebe os modelos.
- `input/` recebe as imagens de entrada.
- `output/` recebe os resultados.
- `custom_nodes/` recebe extensões.

**API.** É possível enviar um fluxo exportado em "API format" por `POST /prompt`; exemplos em `script_examples/`. O OpenMontage usa esse caminho nas ferramentas `comfyui_*`.

### 3.11 blender + mcp-for-blender

**Para que serve.** O Blender é o software 3D completo: modelagem, animação e render com Cycles ou EEVEE. O mcp-for-blender permite que um agente de IA crie e altere cenas no Blender por comandos.

**Instalação do Blender.** Use o executável oficial (seção 2).

**Instalação do mcp-for-blender.**
1. Instale o `uv` (gerenciador Python).
2. No Blender, instale o add-on: Edit, Preferences, Add-ons, Install, e escolha o `addon.py` do repositório.
3. Ative o add-on. No painel lateral (tecla N), aba BlenderMCP, clique em "Connect".
4. No Claude Code, registre o servidor: `claude mcp add blender -- uvx mcp-for-blender`. Em outros clientes, adicione um servidor MCP com o comando `uvx` e o argumento `mcp-for-blender`.

**Como usar.**
- Com o Blender aberto e conectado, peça ao agente em linguagem natural para criar objetos, materiais, luzes, câmeras ou para renderizar.
- Integrações opcionais (Poly Haven, Sketchfab, Hyper3D, Tripo) aparecem no próprio painel do add-on.
- Para desativar a telemetria, defina a variável `DISABLE_TELEMETRY=true`.

**Atenção.** O agente pode executar código Python arbitrário dentro do Blender. Salve o arquivo antes de usar.

### 3.12 chrome-devtools-mcp

**Para que serve.** Permitir que um agente de IA controle o Chrome: navegar, clicar, preencher formulários, ler o console e a rede, medir desempenho (traces e Core Web Vitals) e tirar capturas de tela.

**Instalação no Claude Code.** `claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest`.

**Uso do fork.** Rode `npm ci` e `npm run build`. O executável fica em `build/src/bin/chrome-devtools-mcp.js`.

**Opções úteis.**
- `--headless` roda sem janela.
- `--isolated` usa um perfil temporário.
- `--browserUrl http://127.0.0.1:9222` conecta a um Chrome já aberto.
- `--executablePath` aponta um Chrome específico.
- `--categoryX=false` desliga grupos de ferramentas. A lista completa sai com `--help`.

**Como usar.** Peça ao agente, por exemplo, para abrir uma página, verificar erros no console ou medir o desempenho. O navegador expõe todo o conteúdo aberto ao agente, então não use um perfil com contas pessoais logadas.

### 3.13 impeccable

**Para que serve.** Melhorar o design gerado por agentes de IA. Oferece comandos de direção (`polish`, `bolder`, `quieter` e outros), revisão (`critique`, `audit`) e um detector com 62 regras para padrões genéricos de "AI slop".

**Instalação.** Na raiz do seu projeto, rode `npx impeccable install` e reabra o agente.

**Como usar.**
- Primeiro rode `/impeccable init` para registrar o contexto do produto.
- Depois use `/impeccable <comando> <alvo>`, por exemplo `/impeccable critique página de preços`.
- O detector também roda sem IA, pela linha de comando.

**Uso do fork.** Rode `bun install` e `bun run build`. Os testes rodam com `npm run test:core`.

### 3.14 skills (Remotion)

**Para que serve.** São 13 skills oficiais da Remotion para agentes: criação de projeto, boas práticas, render, legendas, mapas, multimídia, Studio, upgrade, licença, interatividade, SaaS, markup e documentação.

**Instalação.** Rode `npx skills add remotion-dev/skills`. Outra opção é copiar as pastas de `skills/` do fork para `.claude/skills/` do seu projeto ou para `~/.claude/skills/`.

**Como usar.** O agente ativa a skill certa conforme a tarefa. Também dá para chamar uma skill pelo nome, por exemplo `/remotion-render`.

### 3.15 motion-prompt

**Para que serve.** É um vocabulário: 192 nomes de movimentos de motion graphics, movimentos de câmera, componentes de UI, efeitos de landing page e estilos de foto. Cada nome tem um significado e um modelo de pedido para a IA.

**Como usar.**
1. Consulte as listas em `packs/<categoria>/README.md`. Há versões em inglês, japonês, espanhol e chinês.
2. Use os nomes nos seus pedidos à IA para descrever exatamente o movimento desejado.
3. A skill em `skills/` pode ser instalada no agente para ele conhecer o vocabulário.

A pasta `make-your-own/` traz os prompts para criar uma biblioteca equivalente na sua área e no seu idioma.

### 3.16 cinetic

**Para que serve.** Skill de motion design que orienta o agente a criar animações com intenção, ritmo e acabamento.

**Instalação.** Copie `skills/cinetic` para a pasta de skills do agente. O guia de instalação está em `docs/setup.md`.

**Como usar.** Peça animações ou vídeos normalmente; a skill entra quando o assunto é movimento. O arquivo `evals/evals.json` traz casos para avaliar a qualidade das respostas.

### 3.17 taste-skill

**Para que serve.** Skill (`design-taste-frontend`) que dá ao agente critérios de gosto visual para interfaces: tipografia, espaçamento, cor e hierarquia, evitando o visual genérico.

**Instalação.** Rode `./install.sh` ou copie `skills/` para a pasta de skills do agente.

**Testes.** `npm install --no-save yaml@2.6.1`, depois `node --test tests/*.mjs`.

**Como usar.** Peça uma interface; a skill é aplicada automaticamente ao design.

### 3.18 ui-ux-pro-max-skill

**Para que serve.** Base de dados pesquisável de design: 79 estilos, 192 paletas por tipo de produto, 74 combinações de fontes, 119 diretrizes de UX, ícones, gráficos, animações GSAP e regras para 22 tecnologias.

**Instalação.** Rode `npm i -g ui-ux-pro-max-cli` e depois `uipro init` no seu projeto. Outra opção é usar a skill já incluída em `.claude/skills/ui-ux-pro-max/`.

**Busca direta.**
- Por domínio: `python3 src/ui-ux-pro-max/scripts/search.py "consulta" --domain <domínio>`. Domínios: product, style, typography, color, landing, chart, ux, icons, react, web, google-fonts, gsap.
- Por tecnologia: `--stack <tecnologia>` (por exemplo react, nextjs, vue, flutter, swiftui).
- Sistema de design completo: `--design-system`, com os ajustes opcionais `--variance`, `--motion` e `--density` (de 1 a 10).

**Manutenção.** Ao editar dados em `src/`, rode `npm run sync:assets` e `npm run check:assets` dentro de `cli/`.

---

## 4. Como os repositórios se encaixam

Para produzir vídeo, use o OpenMontage como orquestrador. Ele chama:
- HyperFrames (com GSAP e three.js) ou Remotion para animar;
- FFmpeg para montar;
- faster-whisper para transcrever;
- yt-dlp para baixar referências;
- ComfyUI e chatterbox para gerar imagem e voz localmente, quando configurados;
- Blender para cenas 3D de alta qualidade.

As skills de design (impeccable, taste-skill, ui-ux-pro-max, cinetic, motion-prompt e as skills da Remotion) orientam a qualidade visual do que o agente produz. Os servidores MCP (chrome-devtools-mcp e mcp-for-blender) dão ao agente controle direto do navegador e do Blender.
