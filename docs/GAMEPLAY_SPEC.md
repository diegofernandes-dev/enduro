# Especificação de jogabilidade — Enduro original

Objetivo: orientar implementação e testes por fatos, separando comportamentos documentados de aspectos que exigem observação. Fonte principal: [manual original da Activision, reproduzido no AtariAge](https://atariage.com/manual_html_page.php?SoftwareLabelID=163) (seções “Enduro Basics” e “Special Features”).

## Fatos confirmados pelo manual (obrigatórios)

| Assunto | Comportamento original |
| --- | --- |
| Objetivo do dia 1 | Ultrapassar **200** carros. |
| Objetivo dos demais dias | Ultrapassar **300** carros por dia. |
| Contador | Começa na quota do dia, diminui a cada ultrapassagem válida; ao atingir a quota aparecem bandeiras verdes. |
| Após cumprir quota | **Continua correndo** até o encerramento do dia; quilômetros adicionais continuam acumulados. |
| Se não cumprir quota | Fim do jogo no amanhecer que encerra o dia. |
| Resultado/score | É representado por **dia alcançado + quilômetros percorridos**. Não inventar pontuação numérica por carro. |
| Acelerador | Segurar aumenta a velocidade gradualmente até o limite. |
| Soltar o acelerador | O veículo **mantém a velocidade atingida**; não desacelera automaticamente. |
| Freio | É entrada separada do acelerador, originalmente joystick puxado para trás. |
| Direção | Joystick lateral move o carro lateralmente na pista. |
| Noite | A iluminação muda; dos adversários enxergam-se essencialmente as lanternas traseiras. |
| Trechos de gelo/neve | Estrada branca/gelada deixa a direção menos responsiva. |
| Neblina | Encurta a distância na qual o tráfego torna-se visível. |
| Dificuldade | A cada dia os demais carros tornam-se mais rápidos e mais espalhados na estrada. |
| Troféu | Ao sobreviver por cinco dias ou mais aparece um troféu na tela; não é um encerramento definitivo obrigatório da corrida. |
| Colisão/saída | Manual do designer indica que sair para a lateral causa um revés menor que bater em outro carro; intensidade precisa exige calibração. |

## Forma da partida

1. Iniciar corrida e identificar o dia e a quota.
2. Dirigir, ultrapassar tráfego e acumular quilômetros.
3. Passar pelas variações contínuas de luminosidade e clima durante a corrida.
4. Quando a quota chegar a zero, mostrar as bandeiras sem interromper a condução.
5. No amanhecer seguinte, avançar ao dia seguinte se a quota foi atendida; caso contrário encerrar.
6. Continuar a progressão indefinidamente enquanto o jogador cumprir as quotas, incluindo o troféu dos cinco dias.

**Não usar tela de “fase concluída”, loading ou seleção de nível a cada dia.**

## Fidelidade visual a reproduzir

- Estrada em perspectiva pseudo-3D, curvas e fluxo de tráfego reconhecíveis.
- Carro do jogador próximo da base da área de jogo.
- Painel original: odômetro, número do dia, ultrapassagens restantes.
- Paletas e transições entre amanhecer, dia, entardecer e noite.
- Silhuetas/lanternas dos outros veículos à noite.
- Neblina, neve/gelo e os respectivos efeitos funcionais.
- Efeitos sonoros autorais que evoquem o Atari 2600.

## Pontos que o manual NÃO fixa numericamente (pesquisar e calibrar)

- Duração exata de cada dia, velocidade do odômetro e seus incrementos.
- Curvas, posição da câmera, horizonte, escala e proporções da imagem.
- Modelos de aceleração, frenagem, velocidade máxima e resposta lateral.
- Temporização e frequência de neblina/gelo/noite; regras de alternância.
- Velocidades e distribuição espacial dos adversários, padrões e limites.
- Geometria de colisão, perda de velocidade, penalidades e recuperação.
- Condições precisas de exibição do troféu e feedback de fim de partida.
- Frequência de atualização perceptiva (simular fidelidade, sem assumir equivalência de hardware).

Para cada aproximação significativa, registrar fonte de observação e valor ajustável. Não apresentar estimativas como fatos confirmados.

## Critérios de consistência

- Ultrapassagens devem ser eventos reais, contados exatamente uma vez por carro ultrapassado.
- Colidir, despawnar, ultrapassar o jogador ou sair da tela não podem gerar crédito indevido.
- Contador não pode ficar negativo.
- Condições climáticas impactam jogo, não apenas mudam a paleta.
- Sistema de tempo/dias independente da taxa de renderização.
- Testes determinísticos devem ser possíveis com relógio e aleatoriedade controlados.

## Referência principal

Manual: https://atariage.com/manual_html_page.php?SoftwareLabelID=163

Antes de declarar fidelidade alta, observar registros de gameplay por período (dia/noite/neblina/gelo) e documentar diferenças entre a recriação e a referência.
