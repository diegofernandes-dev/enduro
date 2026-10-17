# Controles e plataformas

## Hardware de referência

**Nintendo Switch Pro Controller original**, pareado por **Bluetooth** a um **Mac Apple Silicon**. O usuário não quer depender do teclado. A interface prioritária será o controle desde o primeiro marco.

## Mapeamento inicial pretendido

| Entrada física Nintendo | Comportamento |
| --- | --- |
| Analógico esquerdo | Esterçamento proporcional, com deadzone pequena e ajustável. |
| Direcional esquerdo/direito | Alternativa digital para esterçar. |
| Botão físico A | Acelerar (segurar aumenta velocidade; soltar mantém velocidade segundo manual). |
| Botão físico B | Frear. |
| Botão + | Iniciar / pausar / retomar. |
| Botão A em menus | Confirmar. |
| Analógico ou direcional em menus | Navegar. |

O texto “botão A/B” designa **a legenda física Nintendo**, não valores crus do SDK. **Não presumir que os códigos de eventos, nem a ordem A/B/X/Y, sejam iguais aos de Xbox.** Antes de conectar o input real do jogo, usar um diagnóstico temporário para exibir device ID, nome, botões acionados e eixos crus. Confirmar o mapeamento no dispositivo real.

### Comportamento

- Direção analógica proporcional (não transformar analógico em liga/desliga).
- Deadzone, curva de sensibilidade e limite de esterçamento ajustáveis internamente.
- Se analógico e D-pad coexistirem, definir política clara para que não haja conflito.
- Detectar conexão, desconexão e reconexão; evitar veículo preso acelerando/freando após perder o controle.
- Telas de início, pausa e reinício operáveis por controle, sem teclado.
- Teclado mantido **só como fallback de desenvolvimento/acessibilidade**.
- Pausa/menu são conveniências modernas mínimas e não devem alterar as regras da corrida.

## Matriz de compatibilidade

| Destino | Meta | Evidência de aceite |
| --- | --- | --- |
| macOS Apple Silicon nativo | **Obrigatório no Marco A** | Build abre fora do editor + teste físico com Pro Controller Bluetooth pelo usuário. |
| Web / Chromium macOS | Secundária | Export e teste de interação real com controle no navegador. |
| Web / Safari macOS | Secundária | Teste específico; limitações devem ser documentadas, sem prometer suporte idêntico ao nativo. |
| Windows nativo | Marco D | Executável testado e mapeamento de botões confirmado em dispositivo disponível. |

Sem hardware real, **não marcar validação física como PASS**.

## Escolhas de engine/export

- Godot 4.7.2 stable, GDScript, InputMap e eventos de gamepad da engine.
- Preferir renderizador Compatibility, apropriado ao destino WebGL 2.
- Para Web, export single-thread salvo evidência de necessidade contrária.
- C# não é o baseline porque a exportação Web do Godot 4 não possui suporte equivalente.
- Godot 4.5+ usa SDL3 para controles nativos em macOS, Windows e Linux; na Web o caminho de entrada difere, portanto teste separado é obrigatório.

## Referências técnicas

- https://docs.godotengine.org/en/4.5/tutorials/inputs/controllers_gamepads_joysticks.html
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://godotengine.org/download/archive/
