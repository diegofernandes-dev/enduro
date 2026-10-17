# Entrega — Marco A (primeiro jogo dirigível)

**Data:** 2026-10-17  
**Engine:** Godot 4.7.2.stable  
**Build:** `build/macos/Enduro.app` (Universal: arm64 + x86_64)  
**Branch:** trabalho local sobre a baseline documental

## Funcionalidades concluídas

- Projeto Godot 4.7.2 / GDScript, renderer Compatibility
- Estrada pseudo-3D (scanlines + perspectiva), curvas e bermas
- Carro do jogador na base da tela
- Aceleração gradual; **coasting** ao soltar o acelerador (manual Activision)
- Freio separado; esterçamento analógico proporcional + D-pad
- Tráfego adversário com escala por profundidade
- Ultrapassagens contadas uma vez; colisão reduz velocidade (não conta como ultrapassagem)
- Menus título / pausa / reinício operáveis por gamepad (teclado só como fallback)
- Tela de diagnóstico de controle (F1) — desenvolvimento
- Build nativo macOS fora do editor

## Arquivos principais

| Área | Caminho |
| --- | --- |
| Projeto | `project.godot`, `export_presets.cfg` |
| Entrada | `scripts/autoload/game_input.gd` |
| Calibração | `scripts/autoload/game_params.gd` |
| Sessão / veículo / pista / tráfego | `scripts/race/*.gd` |
| UI | `scripts/ui/*.gd`, `scenes/main.tscn` |
| Smoke test | `tools/smoke_test.gd` |
| Evidências | `build/evidence/` (local; não versionar builds) |

## Como executar

### Editor

```bash
brew install --cask godot   # 4.7.2
cd /caminho/para/enduro
godot --path .
```

### App nativo

```bash
godot --path . --export-release "macOS" build/macos/Enduro.app
open build/macos/Enduro.app
```

Se o Gatekeeper bloquear um build não assinado: Clique direito → Abrir, ou `xattr -cr build/macos/Enduro.app`.

### Controles

| Entrada | Ação |
| --- | --- |
| Analógico esquerdo / D-pad / A D | Esterçar |
| A físico Nintendo (mapeado como joy btn 1 / SDL B) | Acelerar / confirmar |
| B físico Nintendo (mapeado como joy btn 0 / SDL A) | Frear |
| + (Start) / Esc / P | Pausar |
| F1 | Diagnóstico de entrada (dev) |
| Teclado W/S ou ↑/↓ | Acelerar / frear (fallback) |
| Enter / Espaço | Confirmar (fallback) |

**Nota de mapeamento:** no macOS com SDL, os botões face do Switch Pro costumam seguir posições Xbox na API. Os defaults assumem A físico → btn 1 e B físico → btn 0. Confirme com F1 no dispositivo real.

### Smoke test headless

```bash
godot --headless --path . --script res://tools/smoke_test.gd
```

## Evidências

| Evidência | Resultado |
| --- | --- |
| Smoke test (coasting, freio, overtake único, colisão) | PASS (2026-10-17) |
| Screenshots `build/evidence/01`–`04` | PASS (inspeção visual) |
| `Enduro.app` abre fora do editor (arm64) | PASS |
| Nintendo Switch Pro Controller Bluetooth | **COMPATIBILIDADE FÍSICA PENDENTE** |
| Botões A/B/+ físicos confirmados no Mac do proprietário | PENDING |
| Desconexão/reconexão do pad | PENDING |

## Checklist VALIDATION.md (Marco A)

| Item | Status | Quem / notas |
| --- | --- | --- |
| App nativo abre fora do editor | PASS | Agente; arm64 Mac; 2026-10-17 |
| Pista, carro e tráfego animados | PASS | Screenshots + sessão simulada |
| Acelerar / coasting / freio | PASS | Smoke test + lógica `PlayerVehicle` |
| Analógico proporcional / D-pad | PASS (código + InputMap) | Teste físico PENDING |
| Ultrapassagens únicas | PASS | Smoke test |
| Colisão altera velocidade | PASS | Smoke test / params empíricos |
| Iniciar / pausar / reiniciar sem teclado | PASS (InputMap gamepad) | Teste físico PENDING |
| Pro Controller Bluetooth real | PENDING | Sem hardware nesta máquina |
| A/B/+ físicos corretos | PENDING | Usar F1 no Mac do proprietário |
| Hotplug sem entrada travada | PASS (código zera em disconnect) | Teste físico PENDING |
| Sessão jogável real | PASS (agente: teclado + app nativo) | Sessão com Pro Controller PENDING |

## Diferenças conhecidas vs Atari original

- Arte procedural inspirada no layout Enduro (céu, montanhas, ombro verde, pista cinza, painel inferior); **não** copia sprites/ROM
- Resolução interna 160×192 com scale nearest (sensação 2600), não pixels idênticos ao hardware
- Painel mostra KM / DAY / CARS (CARS = 200 − ultrapassagens no Marco A); regras completas de dia/quota = Marco B
- Sem ciclo dia/noite, neblina, gelo, áudio (Marco C)
- Calibração de velocidade/curvas/colisões é empírica
- Menus de pausa/título são conveniência moderna mínima

## Não avançar

Marco B/C/D **não** iniciados. Aguardando aprovação do proprietário.
