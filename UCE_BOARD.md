# UCE – Universal Carrier Ecosystem

* **Versão:** 0.4
  **Status:** Draft de Arquitetura
  **Autor:** Carlos Delfino
  **Objetivo:** Plataforma universal modular para microcontroladores e SoCs para prototipação e aprendizado IoT e Embarcado

---

## 1. Visão Geral

O **UCE – Universal Carrier Ecosystem** é uma arquitetura modular de hardware projetada para permitir a substituição transparente de:

- Microcontroladores (ATtiny, ATmega, ESP32, STM32, NXP, etc.)
- SoCs com maior capacidade (ex.: Cortex-A)
- Módulos de rede (SPI Ethernet, RMII, RGMII/Switch)
- Módulos de gravação e depuração (J-Link, J-ICE, CMSIS-DAP, AVR-ISP, etc.)

sem a necessidade de alterar a **placa base (Carrier)**.

A proposta é criar um **contrato elétrico e funcional** entre módulos, inspirado em padrões industriais como SMARC e COM Express, porém adaptado ao universo de MCUs.

---

## 2. Arquitetura do Sistema

O ecossistema é composto por quatro blocos principais:

- **Carrier/Baseboard (fixa)**Fornece alimentação, conectores externos, level shifting por bancos, proteção e roteamento.
- **MCU Module (trocável)**Contém o microcontrolador/SoC, clock, boot, debug e opcionalmente ADC/DAC externos acoplados.
- **Network Module (trocável)**Implementa Ethernet conforme capacidade do MCU:

  - SPI: W5500 / ENC28J60
  - RMII: PHY dedicado
  - RGMII: Switch KSZ9893 ou similar
- **Debug/Program Module (trocável)**
  Implementa SWD, JTAG, ISP, UPDI, Serial Boot, USB-Debug, etc.

---

## 3. Princípios de Projeto

- A **base não conhece o MCU**, apenas o contrato UCE
- ADC e DAC pertencem ao **MCU Module**
- Ethernet é **sempre modular**
- Debug/Gravação é **sempre modular**
- Todos os sinais externos passam por **level shifting por bancos**
- O **módulo informa suas capacidades e níveis elétricos**

---

## 4. Domínios de Tensão e Level Shifting

- Domínio externo padrão: **3,3 V**
- Suporte a módulos **5 V** e **1,8 V**
- Bancos independentes com seleção:
  - OFF / 3V3 / 5V
- O módulo MCU informa:
  - VIO por banco
  - Capacidades elétricas
- A base protege contra seleções inválidas
- Pinos de alimentação e referência são disponibilizados em três regiões do conector (bordas e miolo), incluindo **VCC_5V**, **VCC_3V3**, **VCC_1V8**, **VREF_IO**, **VIO_BANKx** e **PWR_GOOD**, com múltiplos **GND** adjacentes para facilitar roteamento e level shifting

---

## 5. ADC, DAC e Áudio (I²S)

### ADC / DAC

- Entradas analógicas (`AINx`) e saídas (`AOUTx`) são roteadas até o MCU Module
- O módulo pode:
  - Usar ADC/DAC internos do MCU
  - Implementar ADC/DAC externos via SPI, I²C ou I²S
- A base apenas condiciona e externaliza os sinais

### I²S

Externalização direta para uso com:

- Microfones digitais
- Codecs de áudio
- DACs I²S

Sinais reservados:

- BCLK, LRCLK, DIN, DOUT, MCLK (opcional)

---

## 6. Identificação do Módulo (ID)

Cada MCU Module deve possuir um dispositivo de identificação (EEPROM I²C), informando:

- Família do MCU
- Níveis elétricos por banco
- Presença de ADC, DAC, I²S
- Perfil de debug
- Perfil de rede suportado

Isso permite:

- Uso assistido da plataforma
- Redução de erros elétricos
- Escalabilidade do ecossistema

---

## 7. Mapa de Pinos – Conector MCU Module (SO-DIMM 200 pinos)

### Convenção

- **Coluna 1:** Contagem superior (1 → 100)
- **Coluna 2:** Descrição pinos superiores
- **Coluna 3:** Descrição pinos inferiores
- **Coluna 4:** Contagem inferior (200 → 101)

---

### Tabela de Pinagem (Resumo Funcional)

|     Sup | Descrição (Superior)   | Descrição (Inferior)   |      Inf |
| ------: | ------------------------ | ------------------------ | -------: |
|       1 | GND                      | GND                      |      200 |
|       2 | GND                      | GND                      |      199 |
|       3 | VCC_5V                   | VCC_5V                   |      198 |
|       4 | VCC_3V3                  | VCC_3V3                  |      197 |
|       5 | VCC_1V8                  | VCC_1V8                  |      196 |
|       6 | VREF_IO                  | VREF_IO                  |      195 |
|       7 | VIO_BANK0                | VIO_BANK1                |      194 |
|       8 | VIO_BANK2                | VIO_BANK3                |      193 |
|       9 | PWR_GOOD                 | PWR_GOOD                 |      192 |
|      10 | GND                      | GND                      |      191 |
|      11 | GND                      | GND                      |      190 |
|      12 | VCC_IN                   | GND                      |      189 |
|      13 | MCU_RESET_N              | MCU_EN                   |      188 |
|      14 | MCU_BOOT0                | MCU_BOOT1                |      187 |
|      15 | I2C0_SCL                 | I2C0_SDA                 |      186 |
|      16 | I2C1_SCL                 | I2C1_SDA                 |      185 |
|      17 | I2C2_SCL                 | I2C2_SDA                 |      184 |
|      18 | UART0_TX                 | UART0_RX                 |      183 |
|      19 | UART1_TX                 | UART1_RX                 |      182 |
|      20 | UART2_TX                 | UART2_RX                 |      181 |
|      21 | UART3_TX                 | UART3_RX                 |      180 |
|      22 | UART0_CTS                | UART0_RTS                |      179 |
|      23 | UART0_DSR                | UART0_DCD                |      178 |
|      24 | UART0_RI                 | Reservado / Futuro       |      177 |
|      25 | SPI0_SCK                 | SPI0_MOSI                |      176 |
|      26 | SPI0_MISO                | SPI0_CS0                 |      175 |
|      27 | SPI0_CS1                 | SPI0_CS2                 |      174 |
|      28 | SPI1_SCK                 | SPI1_MOSI                |      173 |
|      29 | SPI1_MISO                | SPI1_CS0                 |      172 |
|      30 | SPI1_CS1                 | SPI1_CS2                 |      171 |
|      31 | GPIO0                    | GPIO8                    |      170 |
|      32 | GPIO1                    | GPIO9                    |      169 |
|      33 | GPIO2                    | GPIO10                   |      168 |
|      34 | GPIO3                    | GPIO11                   |      167 |
|      35 | GPIO4                    | GPIO12                   |      166 |
|      36 | GPIO5                    | GPIO13                   |      165 |
|      37 | GPIO6                    | GPIO14                   |      164 |
|      38 | GPIO7                    | GPIO15                   |      163 |
|      39 | PWM0                     | PWM4                     |      162 |
|      40 | PWM1                     | PWM5                     |      161 |
|      41 | PWM2                     | PWM6                     |      160 |
|      42 | PWM3                     | PWM7                     |      159 |
|      43 | IR_RX_IN                 | IR_TX_OUT                |      158 |
|      44 | AIN0                     | AIN4                     |      157 |
|      45 | AIN1                     | AIN5                     |      156 |
|      46 | AIN2                     | AIN6                     |      155 |
|      47 | AIN3                     | AIN7                     |      154 |
|      48 | AOUT0                    | AOUT1                    |      153 |
|      49 | I2S_BCLK                 | I2S_LRCLK                |      152 |
|      50 | I2S_DOUT                 | I2S_DIN                  |      151 |
|      51 | I2S_MCLK                 | GND                      |      150 |
|      52 | NET_SPI_SCK              | NET_SPI_MOSI             |      149 |
|      53 | NET_SPI_MISO             | NET_SPI_CS               |      148 |
|      54 | NET_INT_N                | NET_RST_N                |      147 |
|      55 | RMII_TXD0                | RMII_TXD1                |      146 |
|      56 | RMII_RXD0                | RMII_RXD1                |      145 |
|      57 | RMII_TXEN                | RMII_CRS_DV              |      144 |
|      58 | RMII_REFCLK              | sMDC                     |      143 |
|      59 | MDIO                     | PHY_RST_N                |      142 |
|      60 | SDIO_CLK                 | SDIO_CMD                 |      141 |
|      61 | SDIO_D0                  | SDIO_D1                  |      140 |
|      62 | SDIO_D2                  | SDIO_D3                  |      139 |
|      63 | Reservado / Futuro       | Reservado / Futuro       |      138 |
|      64 | GND                      | GND                      |      137 |
|      65 | GND                      | GND                      |      136 |
|      66 | VCC_5V                   | VCC_5V                   |      135 |
|      67 | VCC_3V3                  | VCC_3V3                  |      134 |
|      68 | VCC_1V8                  | VCC_1V8                  |      133 |
|      69 | VREF_IO                  | VREF_IO                  |      132 |
|      70 | VIO_BANK0                | VIO_BANK1                |      131 |
|      71 | VIO_BANK2                | VIO_BANK3                |      130 |
|      72 | PWR_GOOD                 | PWR_GOOD                 |      129 |
|      73 | GND                      | GND                      |      128 |
|      74 | GND                      | GND                      |      127 |
| 75–82 | Reservado / Futuro       | Reservado / Futuro       | 126–119 |
|      83 | DBG_SWDIO                | DBG_SWCLK                |      118 |
|      84 | DBG_TCK                  | DBG_TMS                  |      117 |
|      85 | DBG_TDI                  | DBG_TDO                  |      116 |
|      86 | DBG_RESET_N              | DBG_VREF                 |      115 |
|      87 | DBG_UART_TX              | DBG_UART_RX              |      114 |
|      88 | MOD_PRESENT_N            | MOD_TYPE0                |      113 |
|      89 | MOD_TYPE1                | MOD_TYPE2                |      112 |
|      90 | GND                      | GND                      |      111 |
|      91 | GND                      | GND                      |      110 |
|      92 | VCC_5V                   | VCC_5V                   |      109 |
|      93 | VCC_3V3                  | VCC_3V3                  |      108 |
|      94 | VCC_1V8                  | VCC_1V8                  |      107 |
|      95 | VREF_IO                  | VREF_IO                  |      106 |
|      96 | VIO_BANK0                | VIO_BANK1                |      105 |
|      97 | VIO_BANK2                | VIO_BANK3                |      104 |
|      98 | PWR_GOOD                 | PWR_GOOD                 |      103 |
|      99 | GND                      | GND                      |      102 |
|     100 | GND                      | GND                      |      101 |

---

### UART/USART (Portas Seriais)

- **UART0 (Serial0)** é a porta serial principal e inclui sinais de modem/controle além de `TX/RX`:
  - `UART0_TX`, `UART0_RX`, `UART0_CTS`, `UART0_RTS`, `UART0_DSR`, `UART0_DCD`, `UART0_RI`
- **UART1–UART3 (Serial1–Serial3)** expõem apenas `TX/RX`.
- **Compartilhamento de sinais de controle**: se a aplicação não utilizar os sinais de controle da `UART0` (ex.: `CTS/RTS/DSR/DCD/RI`), estes pinos podem ser reaproveitados como sinais auxiliares/controle para as demais UARTs na Carrier, desde que o firmware e o roteamento definam claramente essa multiplexação.

## 8. Conclusão

O **UCE** cria um ecossistema coerente, escalável e didático, permitindo:

- Desenvolvimento educacional
- Prototipagem rápida
- Produtos semi-industriais
- Evolução contínua sem obsolescência da base

A arquitetura separa claramente:

- **processamento**
- **conectividade**
- **depuração**
- **interfaces externas**

tornando o sistema sustentável a longo prazo.

---

## 9. Próximos Passos (v0.4)

- Diagrama de blocos completo
- Especificação elétrica por banco
- Regras de roteamento PCB
- Exemplos de módulos (AVR, STM32, ESP32)
- Guia de firmware de inicialização por perfil
