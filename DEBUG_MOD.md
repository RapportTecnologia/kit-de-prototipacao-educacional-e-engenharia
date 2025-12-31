# DEBUG_MOD – Módulo de Depuração (conector M.2)

## 1. Objetivo

O **DEBUG_MOD** é um módulo encaixável na Carrier via **conector M.2** (referido no projeto como “M2.0”), cuja função é dar acesso ao **Barramento Universal de Depuração** do UCE.

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

| Pino (Sup) | Sinal | Pino (Inf) | Sinal |
| ---: | --- | ---: | --- |
| 83 | `DBG_SWDIO` | 118 | `DBG_SWCLK` |
| 84 | `DBG_TCK` | 117 | `DBG_TMS` |
| 85 | `DBG_TDI` | 116 | `DBG_TDO` |
| 86 | `DBG_RESET_N` | 115 | `DBG_VREF` |
| 87 | `DBG_UART_TX` | 114 | `DBG_UART_RX` |
| 88 | `MOD_PRESENT_N` | 113 | `MOD_TYPE0` |
| 89 | `MOD_TYPE1` | 112 | `MOD_TYPE2` |

## 3. Convenção de pinagem “bordas → miolo”

Este documento descreve a pinagem do conector do módulo **das bordas para o miolo**, isto é:

- Atribuir primeiro os sinais nos **pinos mais externos** do conector.
- Os pinos que sobrarem na região **central (miolo)** devem ser marcados como **RESERVADO**.

> Observação importante
>
> O projeto KiCad neste repositório atualmente descreve o barramento UCE no conector SO-DIMM (J1). A definição exata de **quantidade de vias** e **numeração física** do conector “M2.0” (M.2) do módulo de depuração deve ser alinhada com o footprint/socket escolhido.
>
> A pinagem abaixo fixa a **distribuição funcional** (bordas→miolo) e o conjunto de sinais; a correspondência 1:1 com “Axx/Bxx” (padrão M.2) ou “Pin 1..N” deve ser feita conforme a numeração do footprint adotado na PCB.

## 4. Pinagem do DEBUG_MOD (distribuição funcional)

### 4.1 Região de borda (pinos externos)

Distribuição recomendada para os pinos externos (começando pelos mais externos e avançando para o centro):

**Borda – Grupo 1 (Alimentação/Referência e handshakes)**

1. `GND`
2. `DBG_VREF`
3. `GND`
4. `MOD_PRESENT_N`
5. `MOD_TYPE0`
6. `MOD_TYPE1`
7. `MOD_TYPE2`
8. `GND`

**Borda – Grupo 2 (Debug principal)**

9. `DBG_RESET_N`
10. `DBG_SWDIO`
11. `DBG_SWCLK`
12. `GND`
13. `DBG_TMS`
14. `DBG_TCK`
15. `DBG_TDI`
16. `DBG_TDO`
17. `GND`

**Borda – Grupo 3 (Canal UART de depuração)**

18. `DBG_UART_TX`
19. `DBG_UART_RX`
20. `GND`

### 4.2 Região de miolo (pinos centrais)

- Todos os demais pinos do conector, não utilizados pelos grupos acima, devem ser marcados como:

- `RESERVADO`

## 5. Regras elétricas e de integração

- `DBG_VREF` deve ser tratado como **referência do nível lógico** do alvo (MCU Module). O DEBUG_MOD deve **medir** este nível e adaptar seus buffers/transceptores conforme necessário.
- Manter `GND` adjacente aos sinais de clock (ex.: `DBG_SWCLK`, `DBG_TCK`) ajuda no retorno de corrente e integridade de sinal.
- `DBG_RESET_N` é ativo em nível baixo.
- `DBG_UART_TX/RX` são para console/boot/debug e não substituem SWD/JTAG.

## 6. Pontos em aberto (para fechar junto do footprint M.2)

- **Tipo de chave do M.2 (Key)** e o **socket** a ser utilizado.
- **Tabela final de pinos físicos** (mapeamento para “Pin 1..N” ou “Axx/Bxx”) conforme a numeração do footprint.
- Definir se o conector terá pinos dedicados adicionais para `VCC_3V3`/`VCC_5V` (caso o DEBUG_MOD precise de alimentação pelo slot) ou se o módulo será autoalimentado.
