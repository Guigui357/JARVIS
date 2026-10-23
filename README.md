# J.A.R.V.I.S.

Assistente pessoal local em um único arquivo (`jarvis.py`): interface Arc Reactor / Cyberpunk em
CustomTkinter, telemetria em tempo real, Gemini com *function calling* autônomo, controle do PC e
automação residencial via Home Assistant.

## Recursos

- **Interface HUD**: reator Arc animado com grade, varredura de radar e partículas (ocioso, processando, transmitindo);
  medidores circulares de CPU/RAM/disco, barras segmentadas por núcleo, gráficos com brilho (CPU e rede),
  temperatura, bateria, top processos, indicadores de conexão (Gemini/Home Assistant) no cabeçalho e console
  em estilo de conversa com ícones e cores por origem.
- **Cérebro**: Gemini (`google-generativeai`) com persona britânica ("Senhor"/"Chefe") e 27 ferramentas
  encadeadas de forma autônoma pelo modelo.
- **PC**: encerrar processos, listar consumo de RAM, minimizar janelas, cliques por coordenada ou imagem,
  brilho, volume, bateria, logs críticos do SO, travar a máquina, buscar arquivos, abrir URLs/aplicativos,
  capturar tela, atalhos e digitação.
- **Controle de tela**: a ferramenta `control_screen` opera a interface como uma pessoa: captura a tela, o Gemini (visão)
  decide uma ação por vez (clicar, duplo clique, botão direito, mover, digitar, atalhos, rolar, esperar) e o `pyautogui`
  executa, repetindo até concluir, falhar ou atingir o limite de passos. Um círculo vermelho marca o último clique na
  imagem enviada ao modelo, a janela do JARVIS se minimiza durante a tarefa e o histórico de ações é realimentado.
- **Casa inteligente**: ligar/desligar, brilho de luzes, temperatura de climatizadores, leitura de
  sensores, listagem de entidades e chamada genérica de qualquer serviço do Home Assistant.
- **Segurança**: ações sensíveis (encerrar processos, travar, teclado, abrir aplicativos, controlar a tela, fechaduras,
  alarmes, portões) pedem autorização por diálogo; serviços administrativos do Home Assistant são bloqueados.
- **Extras**: voz opcional (`pyttsx3`), histórico de comandos (↑/↓), botões de ação rápida, log persistente em
  `~/.jarvis/jarvis.log` e migração automática de modelo se o configurado for descontinuado.

## Instalação

```bash
git clone <url-do-seu-repositorio>
cd jarvis
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp jarvis.env.example jarvis.env  # preencha GEMINI_API_KEY e as credenciais do Home Assistant
python jarvis.py
```

No Linux, instale também o Tk do sistema (`sudo apt install python3-tk`). Para brilho/volume/travar a tela
são usados utilitários do SO quando presentes (`brightnessctl`, `pactl`, `loginctl`, `xdotool`).

## Configuração

Ordem de prioridade: variáveis de ambiente, `jarvis.env` ao lado do script, `jarvis.env` no diretório atual,
`~/.jarvis/config.env`.

| Variável | Descrição |
| --- | --- |
| `GEMINI_API_KEY` | Chave da API do Google AI Studio |
| `GEMINI_MODEL` | Modelo (padrão `gemini-1.5-pro`; se não existir mais, o JARVIS escolhe outro automaticamente) |
| `HOME_ASSISTANT_URL` | URL da instância, ex.: `http://homeassistant.local:8123` |
| `HOME_ASSISTANT_TOKEN` | Token de acesso de longa duração |
| `JARVIS_VOZ` | `1` liga a voz (requer `pyttsx3`) |
| `JARVIS_CONFIRMAR` | `0` desativa os diálogos de autorização (não recomendado) |
| `GEMINI_MODEL_TELA` | Modelo de visão só para o controle de tela (vazio = o mesmo do chat) |
| `JARVIS_TELA_CONFIRMAR_PASSOS` | `1` pede autorização a cada ação do controle de tela (padrão `0`: uma autorização por tarefa) |
| `JARVIS_TELA_MINIMIZAR` | `0` mantém a janela do JARVIS visível durante o controle de tela (padrão `1`) |

## Uso

Digite pedidos em linguagem natural: "feche o Chrome", "deixe a luz da sala a 30%", "como está a temperatura
da casa?", "quais arquivos PDF recentes eu tenho em Documentos?". Comandos locais: `/limpar`, `/reset`, `/parar`, `/ajuda`.

O campo de mensagem fica na base da coluna central ("Ordene, Senhor..."); Enter ou **TRANSMITIR** envia. A janela se ajusta
à resolução da tela (cabe em 1366x768; a conta de tamanho é testada, o visual não) e **F11** alterna tela cheia.

### Controle de tela

Exemplos: "abra o Bloco de Notas e digite a lista de compras", "no navegador, abra o site do meu banco e me diga o saldo"
(este último será recusado: o agente não digita senhas). Cada tarefa pede uma autorização por diálogo.

Para **abortar** a qualquer momento: mova o mouse para o canto superior esquerdo da tela, digite `/parar` ou clique em
**PARAR TELA**. O agente também desiste sozinho após 3 repetições idênticas e no limite de passos (padrão 15, máximo 40).

Boas práticas: dê objetivos curtos e autocontidos, deixe a tela destravada e sem notificações sobrepostas, e acompanhe
a execução pelo console. O texto exibido na tela é tratado como dado, não como instrução, mas isso é uma mitigação e
não uma garantia contra injeção de prompt em páginas hostis; evite usar o controle de tela em sites não confiáveis.

## Testes

```bash
python -m unittest discover -s tests -v
```

Os testes rodam sem interface gráfica, sem rede e sem chave Gemini (usam um servidor Home Assistant falso e widgets
falsos). Eles garantem que o código de desenho e a construção da janela executam sem erros, mas **não** validam a
aparência nem chamadas reais ao Gemini; esses pontos precisam ser conferidos manualmente.

## Limitações conhecidas

- Brilho por WMI funciona em notebooks; monitores externos costumam não suportar.
- No Windows o volume é ajustado por teclas de mídia (passos de 2%), então o valor é aproximado.
- `type_text` aceita apenas ASCII (limitação do `pyautogui`).
- Em Wayland, automação de cliques e teclado pode não funcionar.
- O controle de tela captura apenas o monitor principal, não enxerga janelas elevadas/UAC nem telas de bloqueio, e a
  precisão dos cliques depende do modelo de visão (cliques errados são possíveis; por isso há marcador, histórico e parada).
- Texto com acentos no controle de tela usa a área de transferência (`pip install pyperclip`; no Linux requer `xclip` ou `xsel`).

## Licença

MIT (veja `LICENSE`; ajuste o titular dos direitos autorais ao publicar).
