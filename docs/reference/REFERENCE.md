# Referência canônica — cena diurna Enduro

## Fonte

| Campo | Valor |
| --- | --- |
| Jogo | Enduro (Activision, Atari 2600, 1983) |
| Arquivo no repo | [`enduro_day_ref_160.png`](enduro_day_ref_160.png) |
| Origem | Screenshot de jogabilidade Enduro fornecida pelo proprietário (JPEG de captura de emulação/TV), recortada e normalizada |
| Formato lógico | **160×192** pixels (framebuffer estilo 2600) |
| Escala | Nearest-neighbor (`-filter point`), sem suavização |
| Padrão de vídeo | Cores compatíveis com **NTSC TIA** (amostradas da captura) |
| Limitações | A captura original é JPEG; há artefatos de compressão. Cores foram estabilizadas pela paleta dominante. Não é dump raw do Stella framebuffer. |

## Layout medido (160×192)

| Região | Y (inclusive) | Notas |
| --- | --- | --- |
| Céu | 0–63 | Cor dominante `#2C3ABF` |
| Horizonte | 64 | Transição céu → gramado; montanhas brancas baixas em y≈59–63 |
| Campo / pista | 64–150 | Preenchimento `#003900` (pista = mesmo verde do gramado) |
| Painel preto | 151–191 | Fundo `#000000` |
| Caixa vermelha do instrumento | 157–180, x 42–108 | Predominantemente vermelha; dígitos pretos |
| Rainbow Activision | y 185–191, x 12–32 | Uma cor por scanline |
| Texto ACTIVISION | ≈ y 186–190, x≥34 | Branco/cinza |

## Cores canônicas (amostradas)

| Uso | RGB |
| --- | --- |
| Céu | `44,58,191` (`#2C3ABF`) |
| Gramado/pista | `0,57,0` (`#003900`) |
| Preto painel | `0,0,0` |
| Bezel vermelho | `≈180,40,23` |
| Tan interior | `≈200,150,55` |
| Linhas / carro branco | próximo de `#D0D0D0`–`#F0F0F0` |

## Veículo do jogador

Sprite medido em `assets/sprites/car_player_measured.png` (máscara branca extraída da referência quantizada), bbox aproximada **12×9** na cena de referência.

## Validação

Comparar capturas Godot 160×192 (nearest) com `enduro_day_ref_160.png` via `tools/compare_fidelity.py`.
