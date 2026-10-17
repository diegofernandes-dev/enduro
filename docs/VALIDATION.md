# Validação e evidências

Marcar **PASS** apenas com evidência observável. Status possíveis: PASS, FAIL, PENDING, NOT TESTED.

## Marco A — checklist do proprietário

- [ ] Aplicativo nativo macOS abre **fora do editor**.
- [ ] Pista, carro e tráfego animados são visíveis e reconhecíveis.
- [ ] Acelerar aumenta velocidade gradualmente; soltar A **não desacelera automaticamente**.
- [ ] B freia; analógico esterça proporcionalmente.
- [ ] D-pad esterça digitalmente sem conflito.
- [ ] Há ultrapassagens reais; mesmo carro não conta duas vezes.
- [ ] Colisão muda o comportamento conforme a referência investigada.
- [ ] É possível começar, pausar, retomar e reiniciar **sem teclado**.
- [ ] Switch Pro Controller real conecta por Bluetooth ao Mac.
- [ ] Botões A/B/+ físicos correspondem ao que aparece na tela e à ação esperada.
- [ ] Desconectar/reconectar controle não deixa entrada travada.
- [ ] Uma sessão jogável foi executada de verdade, não apenas aberta.

Para cada linha, registrar **quem testou**, data, hardware/OS, build/commit e resultado. Sem acesso ao dispositivo, linhas físicas devem ficar em PENDING.

## Regras — casos automatizados mínimos (Marco B)

- Dia 1 requer 200 ultrapassagens; demais dias, 300.
- Contagem cai uma única vez por veículo válido e não fica negativa.
- Colisões e despawn não contam como ultrapassagens.
- Quota concluída exibe bandeiras, não avança antecipadamente.
- No amanhecer seguinte quota atingida avança dia, quota incompleta encerra partida.
- Quilômetros continuam sendo contabilizados após alcançar quota.
- Resultado do jogo inclui dia e odômetro, não “pontos” inventados.
- Progressão até o troféu de cinco dias e além.
- Dia/clima e simulação não dependem dos FPS.
- Reiniciar zera o estado necessário sem resíduos.

## Fidelidade audiovisual — comparação (Marco C)

Guardar screenshots e notas, cada uma com referência:
- [ ] Dia
- [ ] Entardecer
- [ ] Noite / lanternas
- [ ] Amanhecer
- [ ] Gelo/neve / mudança de direção
- [ ] Neblina / redução de visibilidade
- [ ] Painel, contadores, bandeiras, troféu

## Exportação (Marco D)

- [ ] macOS Apple Silicon testado fora do editor.
- [ ] Web Chromium testado com Gamepad real.
- [ ] Web Safari testado ou limitação explicitada.
- [ ] Windows testado ou export entregue como NÃO VALIDADO.

## Formato da entrega do agente

- Commit/branch e instruções exatas.
- Vídeo curto ou screenshots representativos, quando tecnicamente possível.
- Comandos e logs de testes, separados de resultado manual.
- Lista concisa de diferenças conhecidas vs. original.
- Bloqueios verdadeiros e validações que dependem do proprietário.
