# UCE – External Bus (UCE_External_Bus)

* **Versão:** 0.6
* **Fonte:** `kicad/KEPR/UCE_External_Bus.kicad_sch` e `UCE_BOARD.md`

---

## 1. Objetivo

Este documento descreve o **barramento externo** da arquitetura **UCE (Universal Carrier Ecosystem)**, isto é, o conjunto de sinais expostos pela Carrier/Baseboard para conexão com:

- Periféricos externos (sensores, atuadores, módulos)
- Placas de expansão
- Cabeamento/painel/IO externo

A intenção é padronizar um **contrato elétrico e funcional** para que diferentes módulos MCU/SoC possam ser trocados sem alterar a base, conforme definido em `UCE_BOARD.md`.

---

## 2. Convenções e Domínios Elétricos

### 2.1 Domínios de alimentação

Os seguintes domínios aparecem na especificação do UCE e são utilizados/propagados no barramento:

- `VCC_5V`
- `VCC_3V3`
- `VCC_1V8`
- `GND`

### 2.2 Referência e níveis lógicos

- `VREF_IO`: referência de IO (associada ao domínio lógico exposto).
- `VIO_BANK0`, `VIO_BANK1`, `VIO_BANK2`, `VIO_BANK3`: tensões por banco de IO, alinhadas ao princípio de **level shifting por bancos** (OFF / 3V3 / 5V) descrito em `UCE_BOARD.md`.
- `PWR_GOOD`: sinal de “power good” do sistema.

### 2.3 Direção dos sinais

Neste documento:

- **`MCU → EXT`** significa sinal dirigido do módulo MCU para o conector externo.
- **`EXT → MCU`** significa sinal dirigido do conector externo para o módulo MCU.
- **`Bidirecional`** significa que a direção depende da aplicação (ex.: I²C) ou é intrinsecamente bidirecional.

> Observação: no esquemático KiCad, os `global_label` não carregam semântica de direção; portanto, as direções abaixo seguem a convenção típica de cada barramento.

---

## 3. Conectores presentes no esquemático

No `UCE_External_Bus.kicad_sch` aparecem, no mínimo, os seguintes conectores:

- **J1**: `Conn_02x20_Odd_Even` (2x20)
- **J3**: `Conn_02x40_Odd_Even` (2x40)
- **J4**: `Conn_02x40_Odd_Even` (2x40)

> Importante: a **pinagem (pino ↔ sinal)** não fica diretamente disponível como texto simples no `.kicad_sch` (a conectividade é definida por geometrias/UUIDs). Para gerar uma tabela 100% fiel automaticamente, o caminho mais robusto é exportar **netlist/BOM** via KiCad ou gerar um relatório de conectividade. Se você quiser, eu consigo completar a pinagem com base em um export (ex.: netlist IPC-2581/CSV/pos/relatório do KiCad) que você me fornecer.

---

## 4. Catálogo de sinais do Barramento Externo

Abaixo está o catálogo dos sinais observados no esquemático (principalmente via `global_label`) e alinhados à nomenclatura da UCE.

### 4.1 Alimentação e controle

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `VCC_5V` | Power | — | Alimentação 5 V |
| `VCC_3V3` | Power | — | Alimentação 3,3 V |
| `VCC_1V8` | Power | — | Alimentação 1,8 V |
| `GND` | Power | — | Terra |
| `VREF_IO` | Referência | — | Referência para IO/level shifting |
| `VIO_BANK0` | Power/IO ref | — | Tensão do banco 0 |
| `VIO_BANK1` | Power/IO ref | — | Tensão do banco 1 |
| `VIO_BANK2` | Power/IO ref | — | Tensão do banco 2 |
| `VIO_BANK3` | Power/IO ref | — | Tensão do banco 3 |
| `PWR_GOOD` | Status | MCU → EXT | Indica tensões estáveis (ou habilitação do domínio) |

### 4.2 Sinais de boot/reset/enable

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `MCU_EN` | Controle | EXT → MCU | Enable do módulo/MCU (conforme arquitetura) |
| `MCU_BOOT0` | Controle | EXT → MCU | Seleção de boot/perfil (dependente do MCU) |

### 4.3 I²C

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `I2C0_SCL` | I²C | Bidirecional (open-drain) | Clock I²C0 |
| `I2C1_SCL` | I²C | Bidirecional (open-drain) | Clock I²C1 |
| `I2C2_SDA` | I²C | Bidirecional (open-drain) | Data I²C2 |

> Nota: o esquemático listado aqui inclui alguns sinais I²C pontuais; a UCE prevê pares `SCL/SDA` por barramento.

### 4.4 SPI

#### SPI0

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `SPI0_SCK` | SPI | MCU → EXT | Clock |
| `SPI0_MOSI` | SPI | MCU → EXT | Master Out / Slave In |
| `SPI0_MISO` | SPI | EXT → MCU | Master In / Slave Out |
| `SPI0_CS0` | SPI | MCU → EXT | Chip Select 0 |
| `SPI0_CS1` | SPI | MCU → EXT | Chip Select 1 |

#### SPI1

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `SPI1_CS0` | SPI | MCU → EXT | Chip Select 0 |

### 4.5 UART

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `UART0_TX` | UART | MCU → EXT | Transmit |
| `UART1_RX` | UART | EXT → MCU | Receive |
| `UART2_TX` | UART | MCU → EXT | Transmit |

> Nota: a UCE define `UART0..UART3` e, no caso da `UART0`, sinais de controle adicionais. Nem todos aparecem explicitamente neste sheet do barramento externo.

### 4.6 GPIO e PWM

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `GPIO1` | GPIO | Bidirecional | Uso geral |
| `GPIO3` | GPIO | Bidirecional | Uso geral |
| `GPIO6` | GPIO | Bidirecional | Uso geral |
| `GPIO7` | GPIO | Bidirecional | Uso geral |
| `GPIO8` | GPIO | Bidirecional | Uso geral |
| `GPIO9` | GPIO | Bidirecional | Uso geral |
| `PWM1` | PWM | MCU → EXT | Saída PWM |
| `PWM3` | PWM | MCU → EXT | Saída PWM |
| `PWM6` | PWM | MCU → EXT | Saída PWM |

### 4.7 IR

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `IR_TX_OUT` | IR | MCU → EXT | Transmissão IR |

### 4.8 Analógicos (ADC/DAC)

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `AIN3` | Analógico | EXT → MCU | Entrada analógica |
| `AOUT1` | Analógico | MCU → EXT | Saída analógica |

### 4.9 Áudio (I²S)

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `I2S_BCLK` | I²S | MCU → EXT | Bit clock |

### 4.10 SDIO

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `SDIO_D0` | SDIO | Bidirecional | Data 0 |
| `SDIO_D2` | SDIO | Bidirecional | Data 2 |

### 4.11 Debug

| Sinal | Tipo | Direção | Observação |
| --- | --- | --- | --- |
| `DBG_VREF` | Debug ref | — | Referência do domínio de debug |

### 4.12 Reservados

O esquemático contém múltiplos sinais rotulados como `RESERVED`. Estes pinos/sinais estão reservados para expansão futura, uso específico de variantes, ou compatibilidade.

---

## 5. Recomendações de uso

- **Respeite `VIO_BANKx`**: ao conectar periféricos, considere o banco de IO associado e o nível lógico esperado (3V3/5V/1V8).
- **I²C (open-drain)**: use pull-ups coerentes com `VIO_BANKx`/`VREF_IO` e com o perfil do módulo.
- **SPI**: mantenha `SCK/MOSI/MISO/CSx` curtos em cabo/placa de expansão, e considere GND adjacente quando disponível.
- **Analógico**: trate `AINx/AOUTx` como sinais sensíveis (roteamento/filtragem/impedância de fonte).

---

## 6. Como completar a pinagem (pino ↔ sinal)

Se você quiser que eu gere tabelas de pinagem do tipo “J3 pino 1 = …”, preciso de uma fonte de conectividade exportada pelo KiCad, por exemplo:

- Export de netlist/relatório de conectividade
- Print/CSV de “Pin assignments” do conector
- Ou um PDF do esquemático (para leitura visual)

Com isso, eu atualizo este arquivo adicionando:

- Tabela por conector (J1/J3/J4)
- Mapa por função (Power/IO/Bus) indicando exatamente onde cada sinal está.
