# Instruções para agentes de IA — Enduro

## Missão

Implemente uma recriação fiel, completa e jogável de Enduro (Atari 2600, 1983). Não entregue apenas um protótipo genérico de corrida, animação ou mockup.

## Ordem de leitura obrigatória

1. docs/GAMEPLAY_SPEC.md — comportamento original confirmado e pontos a investigar.
2. docs/CONTROLS_AND_PLATFORMS.md — Nintendo Switch Pro Controller como principal interface.
3. docs/DELIVERY_PLAN.md — marcos e limites de escopo.
4. docs/VALIDATION.md — provas de funcionamento.

O manual original da Activision (linkado na especificação) prevalece sobre intuição sobre física e jogos modernos. Quando o manual não especificar um número ou comportamento exato, investigue jogabilidade de referência e documente claramente a aproximação.

## Tecnologia e restrições

- Godot **4.7.2 stable**, edição padrão, GDScript; Godot Compatibility para Web.
- Entrega primária: aplicativo nativo macOS Apple Silicon. Depois Web; Windows no Marco D.
- Código pequeno e claro: lógica do jogo, entrada, apresentação e áudio desacoplados somente na medida em que melhora legibilidade e teste.
- Sem backend, multiplayer, telemetria, banco de dados, containers, CI/CD enterprise, renderização 3D real ou frameworks sem necessidade.
- Não adicionar power-ups, placar de pontos moderno, vidas, upgrades ou modos extras.

## Ordem de execução

**Comece exclusivamente pelo Marco A.** Pesquise o mínimo necessário para não implementar regras erradas; depois produza código real, abra o jogo e valide o fluxo. Não pare no planejamento.

Não avance ao Marco B/C/D antes da aprovação do proprietário.

## Evidências e honestidade

- Diferencie testes automatizados, inspeção visual e teste físico real.
- Sem acesso ao Pro Controller, reporte explicitamente **COMPATIBILIDADE FÍSICA PENDENTE**. Nunca marque como validado por simulação.
- Não confunda build bem-sucedido com jogabilidade aprovada.
- Ao entregar cada marco, inclua: resumo, arquivos, como rodar, testes e suas evidências, diferenças conhecidas e validações pendentes.
- Se uma decisão técnica contradisser a documentação de referência, justifique e registre a diferença antes de prosseguir.
- Não copiar ROM, código ou assets originais protegidos.

## Ajuste importante de fidelidade

O manual afirma que, ao soltar o acelerador, o carro **mantém a velocidade** (coasting); desacelerar depende do freio. Não implemente desaceleração automática inspirada em jogos modernos sem motivo comprovado.
