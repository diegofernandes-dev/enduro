# Plano de entrega por marcos

**Política:** um marco por vez, evidências antes de aprovação, sem modernizações antes da recriação completa.

## Marco A — Primeira versão realmente dirigível

Escopo:
- Inicializar um projeto Godot 4.7.2 / GDScript.
- Carro do jogador, pista pseudo-3D, movimento da estrada e tráfego em perspectiva.
- Aceleração / conservação de velocidade ao soltar / freio, direção analógica e digital.
- Colisões, ultrapassagens reais (ainda que o painel final venha no Marco B).
- Gamepad como interface principal, inclusive iniciar, pausar e reiniciar.
- Build nativo macOS Apple Silicon fora do editor.

**Gate A:** aplicativo realmente abre e se joga, com evidências de execução. Suporte físico Nintendo só passa mediante teste real, preferencialmente com o proprietário. Não basta o projeto carregar nem produzir capturas estáticas.

## Marco B — Regras e ciclo completo

- Quotas (200/300), contador, bandeiras verdes.
- Odômetro e indicação do dia; resultado por dias e quilômetros.
- Passagem contínua ao próximo dia, derrotas, reinício, progressão e troféu após cinco dias.
- Testes unitários/determinísticos dos eventos e estados.
- Partidas completas em tempo acelerado somente no ambiente de testes (não alterar o tempo real do jogo).

**Gate B:** percorrer todos os resultados possíveis sem falha de estado e sem atribuição incorreta de ultrapassagens.

## Marco C — Fidelidade audiovisual

- Sequência temporal contínua, amanhecer/dia/entardecer/noite.
- Neblina e gelo funcionais, lanternas noturnas.
- Ajuste de estrada, tráfego, HUD, paletas, sons autorais e resposta da direção.
- Comparativos lado a lado de cenas representativas com fonte de referência.

**Gate C:** diferenças perceptíveis listadas, principais comportamentos do jogo confirmados e testados.

## Marco D — Distribuição

- Aplicativo nativo para Mac, build Web e build Windows.
- Validação de controles nativos/Web separadamente.
- Arquivos de distribuição e instruções reproduzíveis.
- Registro de plataformas testadas e suas limitações.

**Gate D:** execução real fora do editor; builds não demonstrados não podem ser considerados aprovados.

## Escopo explicitamente fora desta fase

Melhorias gráficas modernas, arte copiada da ROM, achievements extras, multiplayer, backend, conta/login, ranking online, analytics, sistema de upgrades, physics engine customizada e automações de release sem necessidade.

## Processo do agente

1. Ler AGENTS.md, gameplay, controles, validação e manual.
2. Investigar pontos necessários para o marco ativo sem abrir pesquisa interminável.
3. Implementar e executar; corrigir antes de relatar.
4. Entregar: commit/arquivos, comandos de execução, evidências, resultados, lacunas reais.
5. **Parar e pedir aceite** para seguir ao próximo marco.
