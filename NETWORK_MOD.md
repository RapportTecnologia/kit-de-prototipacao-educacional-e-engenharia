# NETWORK_MOD – Módulo de Rede Cabeada (Header genérico 2x10)

## 1. Objetivo

O **NETWORK_MOD** é um módulo encaixável na Carrier cuja função é prover **conectividade Ethernet cabeada** sem alterar a placa base.

A arquitetura do UCE prevê que Ethernet seja sempre modular, suportando diferentes perfis conforme capacidade do MCU/SoC, por exemplo:

- SPI Ethernet (ex.: W5500 / ENC28J60)
- RMII (PHY dedicado)
- RGMII (switch/PHYs) *(fora do escopo deste conector 2x10; ver seção 6)*

## 2. Conector do módulo

- **Tipo:** Header genérico **2x10 (fêmea)**
- **Total de vias:** 20

### 2.1 Numeração física (padrão 2xN)

- Pino **1** no canto com a marcação (chanfro/triângulo) do conector
- **Ímpares** em uma coluna (1,3,5,7,9,11,13,15)
- **Pares** na outra coluna (2,4,6,8,10,12,14,16)

## 3. Perfis suportados pelo NETWORK_MOD

Este conector suporta dois perfis principais. A Carrier e o MCU Module devem selecionar **um perfil por vez**:

- **Perfil A (RMII + MDIO/MDC)**: indicado quando o MCU expõe RMII.
- **Perfil B (SPI Ethernet)**: indicado para MCUs sem MAC Ethernet, usando controladores SPI.

Os pinos do conector são nomeados de forma a permitir reutilização por perfil.

## 4. Pinagem do NETWORK_MOD

| Pino | Nome canônico no conector | Perfil A (RMII) | PINO | Perfil B (SPI Ethernet) |
| ---: | --- | --- | --- | ---|
|  1 | `GND`       | `GND`         |  2 | GND          |
|  3 | `VCC_3V3`   | `VCC_3V3`     |  4 | VCC_3V3      |
|  5 | `NET_CLK`   | `RMII_REFCLK` |  6 | NET_SPI_CLK  |
|  7 | `NET_CMD`   | `MDIO`        |  8 | RESERVADO    |
|  9 | `NET_D0`    | `RMII_TXD0`   | 10 | NET_SPI_MOSI |
| 11 | `NET_D1`    | `RMII_TXD1`   | 12 | RESERVADO    |
| 13 | `NET_D2`    | `RMII_RXD0`   | 14 | NET_SPI_MISO |
| 15 | `NET_D3`    | `RMII_RXD1`   | 16 | RESERVADO    |
| 17 | `NET_CTL0`  | `RMII_TXEN`   | 18 | NET_SPI_CS   |
| 19 | `NET_CTL1`  | `RMII_CRS_DV` | 20 | NET_INT_N    |
| 21 | `NET_CTL2`  | `sMDC`        | 22 | RESERVADO    |
| 23 | `NET_RST_N` | `PHY_RST_N`   | 24 | NET_RST_N    |



















## 5. Regras elétricas e de integração

- O módulo deve operar em **3,3 V** no lado lógico do barramento do UCE, salvo quando explicitamente definido pela Carrier.
- Para **RMII**, manter atenção ao **clock** (`RMII_REFCLK`) e retorno de corrente: preferir planos de GND e pares adjacentes onde possível.
- Para **MDIO/MDC**, observar pull-ups e nível lógico; idealmente o módulo deve ser tolerante ao nível informado pelo sistema (quando aplicável).
- Sinais `*_RST_N` e `*_INT_N` são **ativos em nível baixo**.

## 6. Observações sobre RGMII/Switch

RGMII e/ou switch Ethernet tipicamente exige mais sinais do que cabem neste conector 2x8 (ex.: múltiplos TX/RX data, clocks adicionais e controles). Para estes casos, recomenda-se:

- Um conector dedicado com mais vias, ou
- Um perfil alternativo que utilize outro barramento/slot na Carrier.
