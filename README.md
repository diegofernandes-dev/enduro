# Enduro — recriação do clássico Atari 2600

Projeto experimental de recriação do **Enduro (Activision, 1983)**, com prioridade para fidelidade de jogabilidade, regras, visual e transições de ambiente.

**Estado atual: Marco A entregue** — primeiro jogo dirigível (pista, carro, tráfego, coasting, gamepad InputMap, app macOS). Marcos B/C/D aguardam aprovação.

Entrega detalhada: [docs/MARCO_A_DELIVERY.md](docs/MARCO_A_DELIVERY.md)

## Direção técnica

- **Godot 4.7.2 stable**, edição padrão + **GDScript** (sem .NET/C#)
- Jogo 2D com perspectiva pseudo-3D; renderer **Compatibility**
- **Principal:** macOS Apple Silicon + Nintendo Switch Pro Controller (Bluetooth)
- **Secundária:** Web e Windows nos marcos posteriores
- Sem backend, multiplayer ou modernizações prematuras

## Como jogar (Marco A)

### Requisitos

- macOS Apple Silicon (ou Universal)
- Godot 4.7.2 (`brew install --cask godot`) para abrir no editor / reexportar
- Templates de exportação 4.7.2 (Editor → Manage Export Templates) para gerar o `.app`

### App nativo

```bash
godot --path . --export-release "macOS" build/macos/Enduro.app
open build/macos/Enduro.app
```

### Editor

```bash
godot --path .
```

### Controles

| Entrada | Ação |
| --- | --- |
| Analógico esquerdo / D-pad | Esterçar (proporcional no stick) |
| A (Nintendo) | Acelerar / confirmar menus |
| B (Nintendo) | Frear |
| + | Pausar / retomar |
| F1 | Diagnóstico do controle (dev) |
| Teclado W/S, setas, Enter, Esc | Fallback de desenvolvimento |

Ao soltar o acelerador o carro **mantém a velocidade** (coasting), como no manual original.

**COMPATIBILIDADE FÍSICA PENDENTE:** o mapeamento do Switch Pro foi implementado via InputMap/SDL, mas não foi validado com o controle Bluetooth real nesta entrega. Use F1 para confirmar botões no seu Mac.

### Smoke test

```bash
godot --headless --path . --script res://tools/smoke_test.gd
```

## Documentação de referência

1. [AGENTS.md](AGENTS.md)
2. [docs/GAMEPLAY_SPEC.md](docs/GAMEPLAY_SPEC.md)
3. [docs/CONTROLS_AND_PLATFORMS.md](docs/CONTROLS_AND_PLATFORMS.md)
4. [docs/DELIVERY_PLAN.md](docs/DELIVERY_PLAN.md)
5. [docs/VALIDATION.md](docs/VALIDATION.md)

## Direitos

Projeto independente de estudo, **não oficial e não afiliado à Activision ou Atari**. Enduro e marcas relacionadas pertencem aos respectivos titulares. Não distribuir ROM, código-fonte extraído ou assets proprietários.
