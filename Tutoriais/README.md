# Tutoriais

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![Visits](https://hits.sh/github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia_Tutoriais_README.svg?label=visits&color=0e75b6)](https://hits.sh/github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia_Tutoriais_README)

 Esta pasta reúne tutoriais e anotações técnicas para **relembrar** (e padronizar) conceitos de eletrônica usados no desenvolvimento do projeto.
 Como o objetivo do KEPR é educacional, estes textos também servem como material de apoio para quem estiver estudando, montando, depurando ou evoluindo o hardware/firmware.

## Como usar estes tutoriais

- Leia os arquivos na ordem sugerida quando fizer sentido (ex.: alimentação antes de instrumentação).
- Sempre que um tutorial citar referências do repositório (ex.: esquemático, `.ioc` do CubeMX, firmware), use-o como ponto de partida para encontrar a “fonte de verdade” das configurações.
- Quando algo for alterado no hardware/firmware, atualize também o tutorial correspondente para manter a documentação coerente.

## Índice de conteúdos

- **Alimentação e barramentos (Power Rails)**
  - [`POWER.md`](./POWER.md): visão geral dos rails do KEPR, função de cada tensão e boas práticas de uso externo.
- **Medição de corrente com shunt + OPAMP + ADC no STM32G4**
  - [`OPAMPS.md`](./OPAMPS.md): mapeamento de pinos, relação ADC→tensão→corrente, parâmetros de calibração e exemplo numérico.
- **Proteção elétrica (tensão reversa e sobretensão)**
  - [`PROTECAO_TENSAO_REVERSA_E_SOBRETENSAO.md`](./PROTECAO_TENSAO_REVERSA_E_SOBRETENSAO.md): topologias de proteção para rails expostos ao usuário (incluindo bloqueio de backfeed e OVP).

## Objetivo do material

- **Didático**: explicar “por que” e “como” cada bloco do sistema funciona.
- **Prático**: registrar decisões de projeto e facilitar manutenção (debug, troca de componentes, mudanças no CubeMX, etc.).
- **Reutilizável**: permitir que partes do projeto (power, proteção, instrumentação) sejam reaproveitadas em outros designs.
