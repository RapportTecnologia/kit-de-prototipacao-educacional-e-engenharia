---
layout: page
title: "Kit Educacional e Prototipação Rapport"
subtitle: "KEPR — Kit Educacional e de Prototipação da Rapport"
---

## Visão geral

Este repositório contém o projeto do **Kit Educacional e de Prototipação** da Rapport (Kit Educacional e Prototipação Rapport - KEPR), incluindo a documentação do barramento/modularidade (UCE) e os arquivos de CAD eletrônico em KiCad.

O KEPR é um ecossistema de hardware para **prototipação e aprendizagem** em sistemas embarcados e IoT: uma base modular que permite trocar o microcontrolador sem “quebrar” o restante do projeto, além de integrar **módulos de rede e wireless** (WiFi, Bluetooth e outros) quando essas interfaces não estão disponíveis nativamente no módulo principal.

A proposta é reduzir atrito no desenvolvimento (e no estudo) de firmware e hardware, organizando um padrão de conexão e expansão para acelerar testes, validações e iterações. O projeto busca compatibilidade com famílias como **STM32**, **ESP32**, **AVR (ATtiny/ATmega)** e outros fabricantes.

Este projeto nasce inicialmente com fins **educacionais** (estudos e evolução técnica de Carlos Delfino) e **pode vir a se tornar comercial** no futuro. Ainda assim, o projeto permanece sob a mesma licença para que outras pessoas e empresas possam **usar, adaptar e redistribuir** da forma que desejarem.

<div class="grid">
  <div class="card">
    <h3>Publicações</h3>
    <p>Notas e publicações relacionadas ao projeto KEPR.</p>
    <a class="btn" href="{{ "/publicacoes/" | relative_url }}">Ver publicações</a>
  </div>
  <div class="card">
    <h3>Documentação</h3>
    <p>Links rápidos para documentos principais do repositório.</p>
    <a class="btn" href="{{ "/sobre/" | relative_url }}">Ver documentação</a>
  </div>
  <div class="card">
    <h3>Licença</h3>
    <p>Projeto licenciado sob Creative Commons CC BY 4.0 (atribuição).</p>
    <a class="btn" href="{{ "/licenca/" | relative_url }}">Ver licença</a>
  </div>
</div>

## Documentação (no repositório)

- **UCE (placa / barramento):** [`UCE_BOARD.md`](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/UCE_BOARD.md)
- **Changelog:** [`CHANGELOG.md`](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/CHANGELOG.md)

## Projeto KiCad

O projeto principal atualmente está em:

- [`kicad/KEPR/`](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/tree/main/kicad/KEPR)

## Repositório Git (origem)

- [git@github.com:RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia.git](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia)
