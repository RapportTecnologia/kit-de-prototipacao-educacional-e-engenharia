---
layout: post
title: "Início do ciclo de trabalho v0.6"
date: 2026-01-10 14:15:00 -0300
categories: ["Publicações"]
tags: ["KEPR", "Release", "v0.6"]
description: "Abrimos o ciclo de trabalho da versão v0.6 do KEPR (versão liberada = versão em desenvolvimento)."
---

# Início do ciclo de trabalho v0.6

A partir de agora, o projeto entra oficialmente no ciclo de desenvolvimento da **versão v0.6**.

Nossa política de versão é simples:

- a **versão liberada** é também a **versão em que estamos trabalhando**.
- ou seja, a branch principal passa a refletir o estado atual de trabalho da **v0.6**.

## O que marca o início da v0.6

Conforme definido na tag `v0.6`, este ciclo inicia com:

- Iniciado o trabalho na Versão 0.6.
- Adotado novos conversores de tensão e sensores de corrente.
- Desativado no firmware o uso dos OpAmps e reconfiguração dos ADCs.

## Escopo de trabalho previsto para a v0.6

Além do marco inicial acima, nesta versão iremos aprofundar alguns pontos estruturais do hardware, com foco em robustez elétrica, expansão e padronização:

- Evoluir em mais detalhes o **conector principal do UCE**, adicionando **novos sinais** a serem compartilhados.
- Estudar a adoção de **PCB multilayer** (se já faz sentido adotar nesta fase).
- Estudar **impedância**, **vias** e conceitos relacionados (ex.: caminhos críticos, retorno de corrente, integridade de sinal).
- Estudar o **nivelamento/conversão de nível de sinais** entre o **conector principal do UCE** e o **conector de externalização**.
- Revisar e consolidar a **disponibilidade de tensões para uso externo**, tanto no conjunto de conectores de uso externo quanto no **conector UCE**.
- Adicionar o **circuito de clock** do microcontrolador de controle da UCE.

## Atualizações no repositório

Este marco também inclui a atualização da revisão nos arquivos do KiCad (schematics/projeto/pcb) e a sincronização da documentação para refletir a nova versão.

Para acompanhar as mudanças:

- Consulte o `CHANGELOG.md` no repositório
- Navegue pelos esquemáticos e PCB em `kicad/KEPR/`
