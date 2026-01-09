---
layout: post
title: "Alimentação (POWER) e Power Rails do KEPR"
date: 2026-01-09 09:00:00 -0300
categories: ["Tutoriais"]
tags: ["KEPR", "Power", "Alimentação", "Power Rails", "3.3V", "5V", "12V", "24V"]
description: "Visão geral dos power rails do KEPR: +24V, +12V, +5V e +3.3V, como são distribuídos e boas práticas de uso externo."
keywords: ["KEPR", "power rails", "alimentação", "barramentos", "24V", "12V", "5V", "3.3V", "shunt", "segurança elétrica"]
---

# Alimentação (POWER) e Power Rails do KEPR

## Referências

- https://wiki.st.com/stm32mcu/wiki/Basics_of_power_supply_design_for_MCU

## O que são “Power Rails” no KEPR

No KEPR, “Power Rails” são os **barramentos de tensão** distribuídos por toda a placa.
Eles têm duas funções principais:

- **Alimentar os circuitos internos** (microcontrolador, periféricos e blocos de interface).
- **Serem externalizados para o usuário (aluno)**, permitindo alimentar circuitos externos (protoboard, módulos, sensores) com tensões padronizadas.

Esses rails são gerados a partir de **conversores DC-DC chaveados**, o que permite boa eficiência e disponibilidade de diferentes níveis de tensão.

## Rails principais

### Entrada: `+24V`

- **Papel no sistema:** barramento de entrada/primário.
- **Origem:** alimentação externa (entrada de energia do kit).
- **Uso:** serve como “fonte base” para os conversores que geram as demais tensões.

### Rail: `+12V`

- **Papel no sistema:** barramento para cargas e experimentos que necessitam de 12 V.
- **Origem:** gerado por conversão a partir do rail de entrada.
- **Uso:** pode alimentar circuitos internos específicos e também é disponibilizado externamente.

### Rail: `+5V`

- **Papel no sistema:** barramento de uso geral para periféricos, módulos e experimentos.
- **Origem:** gerado por conversor DC-DC.
- **Uso:** distribuição interna e disponibilização ao aluno para protótipos e módulos 5 V.

### Rail: `+3.3V`

- **Papel no sistema:** principal barramento lógico do sistema (MCU e sensores digitais).
- **Origem:** gerado por conversor DC-DC.
- **Uso:** distribuição interna e disponibilização ao aluno para circuitos 3,3 V.

## Instrumentação (Shunt) e controle de rails

Em alguns pontos do projeto aparecem nets do tipo:

- `+3v3 Shunt` / `+3.3v Shunt Out`
- `+5v Shunt` / `+5v Shunt Out`
- `+12v Shunt`

A ideia é que o rail passe por um **shunt (resistor de baixa resistência)** para permitir **medição/monitoramento de corrente** (didático e útil para diagnóstico).
Em termos práticos:

- **`<rail> Shunt`**: lado “antes” do shunt.
- **`<rail> Shunt Out`**: lado “depois” do shunt, já pronto para distribuição.

## Como o aluno usa os Power Rails externamente

O KEPR disponibiliza os rails em conectores/headers no conjunto de “External Power Rails”, tipicamente incluindo:

- `GND` (referência comum)
- `+3.3V`
- `+5V`
- `+12V`

Assim, o aluno pode:

- Alimentar protoboard e módulos diretamente com `+3.3V` ou `+5V`.
- Usar `+12V` quando o experimento exigir (motores/atuadores específicos, drivers, etc.).
- Sempre compartilhar o **mesmo `GND`** entre o KEPR e o circuito externo.

## Boas práticas e segurança

- **Verifique polaridade antes de ligar.** Inversão de polaridade pode danificar conversores e periféricos.
- **Use sempre `GND` comum.** Sinais lógicos e medição só funcionam corretamente com referência comum.
- **Não misture níveis de tensão em GPIO.**
  - GPIOs do MCU são tipicamente `3.3V`.
  - Não aplique `5V` diretamente em pinos do MCU (use conversão de nível quando necessário).
- **Cuidado com curto-circuito.** Um curto em `+5V`/`+3.3V` pode derrubar o rail e aquecer componentes.
- **Não exceda a capacidade de corrente dos rails.** Se o experimento exigir mais corrente (motores grandes, cargas resistivas), use fonte dedicada e apenas compartilhe `GND`.
