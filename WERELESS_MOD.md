# WIRELESS_MOD – Módulo Wireless para WiFI e Bluetooth Classico e LE (Header genérico 2x8)

## 1. Objetivo

O **WIRELESS_MOD** é um módulo encaixável na Carrier cuja função é prover **conectividade Wi‑Fi e Blueetoh** por meio de módulos baseados em:

- ESP32 (ex.: ESP32-WROOM / ESP32-C3/S3 em variantes com interface externa)
- NRF (ex.: nRF7002 para Wi‑Fi, ou módulos combo conforme fornecedor)
- STM (ex.: módulos/solutions com Wi‑Fi controlado por host)

O objetivo é permitir trocar o “módulo de rádio” sem alterar a placa base, mantendo um contrato de sinais estável.

## 2. Conector do módulo

- **Tipo:** Header genérico **2x8**
- **Total de vias:** 16

### 2.1 Numeração física (padrão 2xN)

- Pino **1** no canto com a marcação (chanfro/triângulo) do conector
- **Ímpares** em uma coluna (1,3,5,7,9,11,13,15)
- **Pares** na outra coluna (2,4,6,8,10,12,14,16)

## 3. Barramentos suportados

O WIFI_MOD pode ser implementado com diferentes interfaces de host, dependendo do módulo adotado:

- **SDIO (recomendado quando disponível)**: maior throughput, adequado para Wi‑Fi.
- **SPI**: comum em módulos mais simples ou em bridges.
- **UART**: útil para AT firmware/bridge, provisioning e debug; throughput limitado para tráfego.

Este documento padroniza o conector com foco em **SDIO**, mas prevendo fallback.

## 4. Pinagem do WIRELESS_MOD

Os pinos são nomeados para suportar **SDIO** como perfil principal. Quando um módulo não suportar SDIO, os pinos podem ser reinterpretados conforme a seção 5.

| Pino | Nome canônico no conector | Função principal (SDIO)         |
| ---: | -------------------------- | --------------------------------- |
|    1 | `GND`                    | `GND`                           |
|    2 | `VCC_3V3`                | `VCC_3V3`                       |
|    3 | `SDIO_CLK`               | `SDIO_CLK`                      |
|    4 | `SDIO_CMD`               | `SDIO_CMD`                      |
|    5 | `SDIO_D0`                | `SDIO_D0`                       |
|    6 | `SDIO_D1`                | `SDIO_D1`                       |
|    7 | `SDIO_D2`                | `SDIO_D2`                       |
|    8 | `SDIO_D3`                | `SDIO_D3`                       |
|    9 | `WIFI_EN`                | Enable do módulo (se aplicável) |
|   10 | `WIFI_RST_N`             | Reset do módulo (ativo baixo)    |
|   11 | `WIFI_INT_N`             | Interrupt/Host wake (ativo baixo) |
|   12 | `UART0_TX`               | Canal UART auxiliar (TX do host)  |
|   13 | `RESERVADO`              | `RESERVADO`                     |
|   14 | `UART0_RX`               | Canal UART auxiliar (RX do host)  |
|   15 | `RESERVADO`              | `RESERVADO`                     |
|   16 | GND                        | GND                               |

## 5. Mapeamentos alternativos (quando não houver SDIO)

Quando o módulo adotado **não** suportar SDIO, recomenda-se um destes perfis alternativos:

### 5.1 Perfil SPI (módulo Wireless via SPI)

Reaproveitar as linhas SDIO como SPI:

- `SDIO_CLK`  -> `SPI_SCK`
- `SDIO_CMD`  -> `SPI_MOSI`
- `SDIO_D0`   -> `SPI_MISO`
- `SDIO_D1`   -> `SPI_CS`
- `SDIO_D2`   -> `RESERVADO` (ou `SPI_CS2` se necessário)
- `SDIO_D3`   -> `RESERVADO`

E manter:

- `WIFI_INT_N`, `WIFI_RST_N`, `WIFI_EN` conforme disponível.

### 5.2 Perfil UART (módulo/bridge AT)

Usar:

- `UART0_TX`, `UART0_RX` como interface principal
- `WIFI_EN` / `WIFI_RST_N` para controle

As linhas `SDIO_*` permanecem `RESERVADO`.

## 6. Regras elétricas e de integração

- **Alimentação:** o conector fornece `VCC_3V3`.
- **Nível lógico:** idealmente 3,3 V, mas o módulo deve ser escolhido de forma compatível com o domínio de IO do host/Carrier.
- **Sinais ativos baixo:** `WIFI_RST_N` e `WIFI_INT_N`.
- **RF:** antena (U.FL/IPEX ou PCB) e keep-out são responsabilidade do WIFI_MOD; a Carrier não deve rotear RF.

## 7. Observações por família de módulos

- **ESP32:** muitas variações expõem SPI/UART; SDIO depende do módulo/solução. Quando o ESP32 for o “host” (MCU+Wi‑Fi no mesmo chip), este documento serve mais para módulos “coprocessor”/bridge.
- **NRF:** para Wi‑Fi, considerar soluções como nRF7002 (tipicamente SDIO/SPI conforme integração).
- **STM:** soluções de Wi‑Fi podem usar SDIO/SPI/UART dependendo do módulo e stack.
