# Gate de fidelidade visual — cena diurna

**Status:** em revisão do proprietário. **Não** se declara equivalência pixel-a-pixel.

## 1. Referência original

| Campo | Valor |
| --- | --- |
| Arquivo | [`docs/reference/enduro_day_ref_160.png`](reference/enduro_day_ref_160.png) |
| Documento de medições | [`docs/reference/REFERENCE.md`](reference/REFERENCE.md) |
| Jogo | Enduro (Activision, Atari 2600, 1983) |
| Resolução lógica | 160×192, nearest-neighbor |
| Stella / ROM | Stella instalado no ambiente; **ROM não incluída** (sem dump ilegal). A referência do repositório é a captura fornecida/normalizada. |

## 2. Screenshot Godot (modo determinístico)

| Campo | Valor |
| --- | --- |
| Captura | [`docs/evidence/fidelity/godot_day_160.png`](evidence/fidelity/godot_day_160.png) |
| Ferramenta | `godot --path . --script res://tools/fidelity_capture.gd` |
| Poses | Estrada medida, carro jogador x=87 y=143, adversários nas bbox da referência, painel 0970 / dia 6 / 208 |

## 3. Comparação objetiva

| Artefato | Caminho |
| --- | --- |
| Lado a lado | [`docs/evidence/fidelity/side_by_side.png`](evidence/fidelity/side_by_side.png) |
| Overlay | [`docs/evidence/fidelity/overlay.png`](evidence/fidelity/overlay.png) |
| Mapa de diferenças | [`docs/evidence/fidelity/diff_map.png`](evidence/fidelity/diff_map.png) |
| Relatório numérico | [`docs/evidence/fidelity/report.txt`](evidence/fidelity/report.txt) |

Comando:

```bash
godot --path . --script res://tools/fidelity_capture.gd
python3 tools/compare_fidelity.py \
  --ref docs/reference/enduro_day_ref_160.png \
  --godot build/evidence/fidelity/godot_day_160.png \
  --out-dir docs/evidence/fidelity
```
## 4. Correções nesta branch

- Renderer `road_view.gd` reescrito em torno de `FidelityLayout` (constantes medidas).
- Removidos banding CRT, chrome inventado e troféu desenhado fora do papel do painel.
- Bordas da pista por tabela de scanlines medidas; silhueta do jogador da bbox da referência.
- Painel: y=151+, caixa 42×157–108×180, rainbow y=185–191, dígitos nas clusters escuras.
- Pipeline de captura determinística + diff por pixel/região.

## 5. Evidências de execução

- Godot **4.7.2.stable** CLI; captura 160×192 gravada com `err=0`.
- Compare Python puro (sem suavização). Último relatório: mean abs ≈5.08; mismatch>30 ≈7.1% (céu≈0.5, pista≈4.8, painel≈12.9).
- Jogabilidade Marco A preservada (acelerar/coasting/freio, tráfego, InputMap Pro Controller).
- **COMPATIBILIDADE FÍSICA PENDENTE** — Pro Controller não validado neste gate.

## 6. Limitações que ainda impedem equivalência visual

1. A referência é JPEG normalizado, não framebuffer raw do Stella — bordas e fontes têm artefatos.
2. Tipografia do painel e “ACTIVISION” são aproximações 3×5, não o charset TIA bit-exact.
3. Adversários usam máscaras Em escala, não sprites TIA extraídos frame-a-frame.
4. Montanhas são polígonos medidos, não fills scanline-idênticos.
5. Sem ROM, não há re-captura Stella sob configurações NTSC documentadas nesta máquina.

Aprovação final: **proprietário**, com as imagens de comparação como diagnóstico — não impressão subjetiva isolada.
