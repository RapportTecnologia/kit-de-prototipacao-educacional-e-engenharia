# DEBUG_MOD – Módulo de Depuração (Header genérico 2x15)

## 1. Objetivo

O **DEBUG_MOD** é um módulo encaixável na Carrier via **conector header genérico 2x15 (macho)**, com espaçamento maior para facilitar uso com jumpers, cuja função é dar acesso ao **Barramento Universal de Depuração** do UCE.

Ele existe para permitir a troca do “método de debug/programação” (ex.: CMSIS-DAP, J-Link, AVR-ISP/UPDI, bridge USB-UART, etc.) sem alterar a placa base.

## 2. Sinais do Barramento Universal de Depuração (referência)

Conforme o `README.md`, o barramento de depuração do UCE disponibiliza os seguintes sinais lógicos (nomes canônicos):

- `DBG_SWDIO`
- `DBG_SWCLK`
- `DBG_TCK`
- `DBG_TMS`
- `DBG_TDI`
- `DBG_TDO`
- `DBG_RESET_N`
- `DBG_VREF`
- `DBG_UART_TX`
- `DBG_UART_RX`

Além dos sinais auxiliares de presença/tipo de módulo:

- `MOD_PRESENT_N`
- `MOD_TYPE0`
- `MOD_TYPE1`
- `MOD_TYPE2`

E referências elétricas:

- `GND`

### 2.1 Referência de pinagem no conector UCE (SO-DIMM J1)

No conector UCE SO-DIMM 200 pinos (J1), a região de depuração está definida no `README.md` como:

| Pino (Sup) | Sinal             | Pino (Inf) | Sinal           |
| ---------: | ----------------- | ---------: | --------------- |
|         83 | `DBG_SWDIO`     |        118 | `DBG_SWCLK`   |
|         84 | `DBG_TCK`       |        117 | `DBG_TMS`     |
|         85 | `DBG_TDI`       |        116 | `DBG_TDO`     |
|         86 | `DBG_RESET_N`   |        115 | `DBG_VREF`    |
|         87 | `DBG_UART_TX`   |        114 | `DBG_UART_RX` |
|         88 | `MOD_PRESENT_N` |        113 | `MOD_TYPE0`   |
|         89 | `MOD_TYPE1`     |        112 | `MOD_TYPE2`   |

## 3. Convenção de pinagem “bordas → miolo”

Este documento descreve a pinagem do conector do módulo **das bordas para o miolo**, isto é:

- Atribuir primeiro os sinais nos **pinos mais externos** do conector.
- Os pinos que sobrarem na região **central (miolo)** devem ser marcados como **RESERVADO**.

> Observação importante
>
> O projeto KiCad neste repositório atualmente descreve o barramento UCE no conector SO-DIMM (J1). A pinagem abaixo fixa a **distribuição funcional** e o conjunto de sinais do DEBUG_MOD no conector **header genérico 2x15**.

Além disso, em versões futuras haverá um **segundo conector** com passo **0.05"** para compatibilidade ainda maior com padrões de cabos/ICE.

## 4. Pinagem do DEBUG_MOD (Header 2x15)

- Total: **30 vias** (pinos **1..30**)
- Numeração: padrão 2xN (ímpares em uma coluna e pares na outra)

### 4.1 Tabela de pinagem

| Pino | Sinal                           | Pino | Sinal           |
| ---: | ------------------------------- | ---: | --------------- |
|    1 | `DBG_VREF` *(VTref)*            |    2 | `GND`           |
|    3 | `DBG_TMS` *(JTAG TMS / SWDIO)*  |    4 | `GND`           |
|    5 | `DBG_TCK` *(JTAG TCK / SWCLK)*  |    6 | `GND`           |
|    7 | `DBG_TDO`                       |    8 | `GND`           |
|    9 | `DBG_TDI`                       |   10 | `GND`           |
|   11 | `DBG_RESET_N` *(nRESET)*        |   12 | `GND`           |
|   13 | `DBG_SWDIO` *(alternativo / uso dedicado quando aplicável)* |   14 | `DBG_SWCLK` *(alternativo / uso dedicado quando aplicável)* |
|   15 | `DBG_UART_TX`                   |   16 | `DBG_UART_RX`   |
|   17 | `MOD_PRESENT_N`                 |   18 | `MOD_TYPE0`     |
|   19 | `MOD_TYPE1`                     |   20 | `MOD_TYPE2`     |
|   21 | `GND`                           |   22 | `GND`           |
|   23 | `RESERVADO`                     |   24 | `RESERVADO`     |
|   25 | `RESERVADO`                     |   26 | `RESERVADO`     |
|   27 | `RESERVADO`                     |   28 | `RESERVADO`     |
|   29 | `GND`                           |   30 | `GND`           |


## 5. Regras elétricas e de integração

- `DBG_VREF` deve ser tratado como **referência do nível lógico** do alvo (MCU Module). O DEBUG_MOD deve **medir** este nível e adaptar seus buffers/transceptores conforme necessário.
- Manter `GND` adjacente aos sinais de clock (ex.: `DBG_SWCLK`, `DBG_TCK`) ajuda no retorno de corrente e integridade de sinal.
- `DBG_RESET_N` é ativo em nível baixo.
- `DBG_UART_TX/RX` são para console/boot/debug e não substituem SWD/JTAG.

## 6. Pontos em aberto

- Definir se o DEBUG_MOD deve receber alimentação exclusivamente por `DBG_VREF` (apenas detecção de nível) ou se também haverá necessidade de `VCC_3V3` dedicado em revisões futuras.
