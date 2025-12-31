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

## 5. Clock

- O módulo MCU fornece o clock principal
- Pinos CLOCK_0 e CLOCK_1 disponíveis para a UCE como referência
- Suporte a múltiplos cristais e osciladores definidos pelo módulo
- Frequências variáveis conforme necessidade do módulo
- Pinos CLOCK_0 e CLOCK_1 podem ser usados para sincronização entre módulos
- A UCE pode configurar o clock conforme necessário
- Informações sobre o Clock podem ser obtidas na eeprom de identificação.

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

- **Coluna 1:** Pinos ímpares (1 → 199) — lado esquerdo
- **Coluna 2:** Descrição pinos ímpares
- **Coluna 3:** Descrição pinos pares
- **Coluna 4:** Pinos pares (2 → 200) — lado direito

---

### Tabela de Pinagem (Resumo Funcional)

| Ímpar | Descrição (Ímpar) | Descrição (Par) | Par |
| -----: | ---------------------- | ---------------------- | :------- |
|     1 | GND                    | GND                    | 2   |
|     3 | GND                    | GND                    | 4   |
|     5 | VCC_5V                 | VCC_5V                 | 6   |
|     7 | VCC_3V3                | VCC_3V3                | 8   |
|     9 | VCC_1V8                | VCC_1V8                | 10  |
|    11 | VREF_IO                | VREF_IO                | 12  |
|    13 | VIO_BANK0              | VIO_BANK1              | 14  |
|    15 | VIO_BANK2              | VIO_BANK3              | 16  |
|    17 | PWR_GOOD               | PWR_GOOD               | 18  |
|    19 | GND                    | GND                    | 20  |
|    21 | GND                    | GND                    | 22  |
|    23 | VCC_IN                 | GND                    | 24  |
|    25 | MCU_RESET_N            | MCU_EN                 | 26  |
|    27 | MCU_BOOT0              | MCU_BOOT1              | 28  |
|    29 | I2C0_SCL               | I2C0_SDA               | 30  |
|    31 | I2C1_SCL               | I2C1_SDA               | 32  |
|    33 | I2C2_SCL               | I2C2_SDA               | 34  |
|    35 | UART0_TX               | UART0_RX               | 36  |
|    37 | UART1_TX               | UART1_RX               | 38  |
|    39 | UART2_TX               | UART2_RX               | 40  |
|    41 | UART3_TX               | UART3_RX               | 42  |
|    43 | UART0_CTS              | UART0_RTS              | 44  |
|    45 | UART0_DSR              | UART0_DCD              | 46  |
|    47 | UART0_RI               | GND                    | 48  |
|    49 | SPI0_SCK               | SPI0_MOSI              | 50  |
|    51 | SPI0_MISO              | SPI0_CS0               | 52  |
|    53 | SPI0_CS1               | SPI0_CS2               | 54  |
|    55 | SPI1_SCK               | SPI1_MOSI              | 56  |
|    57 | SPI1_MISO              | SPI1_CS0               | 58  |
|    59 | SPI1_CS1               | SPI1_CS2               | 60  |
|    61 | GPIO0                  | GPIO8                  | 62  |
|    63 | GPIO1                  | GPIO9                  | 64  |
|    65 | GPIO2                  | GPIO10                 | 66  |
|    67 | GPIO3                  | GPIO11                 | 68  |
|    69 | GPIO4                  | GPIO12                 | 70  |
|    71 | GPIO5                  | GPIO13                 | 72  |
|    73 | GPIO6                  | GPIO14                 | 74  |
|    75 | GPIO7                  | GPIO15                 | 76  |
|    77 | PWM0                   | PWM4                   | 78  |
|    79 | PWM1                   | PWM5                   | 80  |
|    81 | PWM2                   | PWM6                   | 82  |
|    83 | PWM3                   | PWM7                   | 84  |
|    85 | IR_RX_IN               | IR_TX_OUT              | 86  |
|    87 | AIN0                   | AIN4                   | 88  |
|    89 | AIN1                   | AIN5                   | 90  |
|    91 | AIN2                   | AIN6                   | 92  |
|    93 | AIN3                   | AIN7                   | 94  |
|    95 | AOUT0                  | AOUT1                  | 96  |
|    97 | I2S_BCLK               | I2S_LRCLK              | 98  |
|    99 | I2S_DOUT               | I2S_DIN                | 100 |
|   101 | I2S_MCLK               | GND                    | 102 |
|   103 | NET_SPI_SCK            | NET_SPI_MOSI           | 104 |
|   105 | NET_SPI_MISO           | NET_SPI_CS             | 106 |
|   107 | NET_INT_N              | NET_RST_N              | 108 |
|   109 | RMII_TXD0              | RMII_TXD1              | 110 |
|   111 | RMII_RXD0              | RMII_RXD1              | 112 |
|   113 | RMII_TXEN              | RMII_CRS_DV            | 114 |
|   115 | RMII_REFCLK            | sMDC                   | 116 |
|   117 | MDIO                   | PHY_RST_N              | 118 |
|   119 | SDIO_CLK               | SDIO_CMD               | 120 |
|   121 | SDIO_D0                | SDIO_D1                | 122 |
|   123 | SDIO_D2                | SDIO_D3                | 124 |
|   125 | Reservado / Futuro     | Reservado / Futuro     | 126 |
|   127 | GND                    | GND                    | 128 |
|   129 | GND                    | GND                    | 130 |
|   131 | VCC_5V                 | VCC_5V                 | 132 |
|   133 | VCC_3V3                | VCC_3V3                | 134 |
|   135 | VCC_1V8                | VCC_1V8                | 136 |
|   137 | VREF_IO                | VREF_IO                | 138 |
|   139 | VIO_BANK0              | VIO_BANK1              | 140 |
|   141 | VIO_BANK2              | VIO_BANK3              | 142 |
|   143 | PWR_GOOD               | PWR_GOOD               | 144 |
|   145 | GND                    | GND                    | 146 |
|   147 | GND                    | GND                    | 148 |
|   149 | CLOCK_0                | CLOCK_1                | 150 |
| 151–163 | Reservado / Futuro   | Reservado / Futuro     | 150–164 |
|   165 | DBG_SWDIO              | DBG_SWCLK              | 166 |
|   167 | DBG_TCK                | DBG_TMS                | 168 |
|   169 | DBG_TDI                | DBG_TDO                | 170 |
|   171 | DBG_RESET_N            | DBG_VREF               | 172 |
|   173 | DBG_UART_TX            | DBG_UART_RX            | 174 |
|   175 | MOD_PRESENT_N          | MOD_TYPE0              | 176 |
|   177 | MOD_TYPE1              | MOD_TYPE2              | 178 |
|   179 | GND                    | GND                    | 180 |
|   181 | GND                    | GND                    | 182 |
|   183 | VCC_5V                 | VCC_5V                 | 184 |
|   185 | VCC_3V3                | VCC_3V3                | 186 |
|   187 | VCC_1V8                | VCC_1V8                | 188 |
|   189 | VREF_IO                | VREF_IO                | 190 |
|   191 | VIO_BANK0              | VIO_BANK1              | 192 |
|   193 | VIO_BANK2              | VIO_BANK3              | 194 |
|   195 | PWR_GOOD               | PWR_GOOD               | 196 |
|   197 | GND                    | GND                    | 198 |
|   199 | GND                    | GND                    | 200 |

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
