# Enduro — recriação do clássico Atari 2600

Projeto experimental de recriação do **Enduro (Activision, 1983)**, com prioridade para fidelidade de jogabilidade, regras, visual e transições de ambiente.

**Estado atual: baseline documental. O jogo ainda NÃO foi implementado e não há executável disponível.**

## Direção técnica

- **Godot 4.7.2 stable**, edição padrão + **GDScript** (sem .NET/C#).
- Jogo 2D com perspectiva pseudo-3D, sem backend.
- **Principal:** macOS Apple Silicon, aplicativo nativo e Nintendo Switch Pro Controller via Bluetooth.
- **Secundária:** Web (Godot Compatibility, WebGL 2, export single-thread); Windows após validação.
- A versão nativa para macOS é a referência primária da dirigibilidade. Compatibilidade Web deve ser testada separadamente.
- Primeiro a experiência original; melhorias modernas somente após aprovação da recriação.

## Começando pelo repositório

1. Leia [AGENTS.md](AGENTS.md) antes de iniciar trabalho por IA.
2. Leia [as regras e lacunas de pesquisa](docs/GAMEPLAY_SPEC.md).
3. Leia [controles e plataformas](docs/CONTROLS_AND_PLATFORMS.md).
4. Execute apenas o [Marco A do plano](docs/DELIVERY_PLAN.md).
5. Demonstre resultados seguindo [o checklist de validação](docs/VALIDATION.md).

O agente deverá criar o projeto Godot, as cenas, o código e o primeiro build como parte do **Marco A**. Esta baseline não afirma que algo foi compilado ou testado.

## Referências prioritárias

- [Manual original, reproduzido pelo AtariAge](https://atariage.com/manual_html_page.php?SoftwareLabelID=163)
- [Godot 4.7.2 stable (arquivo oficial)](https://godotengine.org/download/archive/)
- [Godot — Controllers, gamepads and joysticks](https://docs.godotengine.org/en/4.5/tutorials/inputs/controllers_gamepads_joysticks.html)
- [Godot — Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)

## Direitos

Projeto independente de estudo, **não oficial e não afiliado à Activision ou Atari**. Enduro e marcas relacionadas pertencem aos respectivos titulares. Não distribuir ROM, código-fonte extraído ou assets proprietários. Gráficos, sons e código devem ser criados originalmente; referências históricas destinam-se à análise e calibração.
