# Medição de corrente com shunt usando OPAMP1..3 + ADC no STM32G484CETx
 
 Este tutorial descreve como usar os OPAMPs internos `OPAMP1`, `OPAMP2`, `OPAMP3` do **STM32G484CETx** para medir a corrente nos resistores shunt do projeto, e como calcular:
 
 - a corrente em cada shunt;
 - a queda de tensão no shunt;
 - a tensão efetiva do barramento após a queda.
 
 A referência principal é a configuração do CubeMX (`firmware_UCE.ioc`) e o esquemático (`UCE_board.kicad_sch`).
 
 ## 1) Visão geral do hardware (shunts e sinais)
 
 No esquemático, os shunts de medição são:
 
 - **R2**: shunt do barramento **3.3V**
 - **R3**: shunt do barramento **5V**
 - **R4**: shunt do barramento **12V**
 
 Cada shunt tem dois pontos de medição (antes/depois do shunt), nomeados no `.ioc` como “in” e “out” (pontos Kelvin/sense).
 
 ### 1.1) Part number / família do shunt
 
 No esquemático, os shunts são da família ROHM **GMR-E** (ex.: `GMR320...`). O símbolo indica a família `GMR320HJAAFD5L00` e o campo `Datasheet` aponta para `gmr-e.pdf`.
 
 Observação prática: no arquivo do esquemático aparecem variações no campo `Value`:
 
 - R2: `GMR320HJAAFM5L00`
 - R3: `GMR320HJAAFS5L00`
 - R4: `GMR320HJAAFE5L00`
 
 O datasheet mostra que esses códigos são usados para identificar variações de resistência/tolerância dentro da mesma série.
 
 #### 1.1.1) Como extrair `Rshunt` pelo código (conforme `gmr-e.pdf`)
 
 O datasheet apresenta a estrutura do código do produto, onde aparecem:
 
 - a **série/tamanho** (ex.: `GMR320` = 7142 / 2817, alta potência)
 - o **código de tolerância** (ex.: `F` = ±1%)
 - um **special code** que define valores típicos de resistência (ex.: `D` = 5mΩ, `E` = 15mΩ/150mΩ, `M` = 33mΩ, `S` = 56mΩ, etc.)
 - um **código de resistência** (no exemplo do datasheet aparecem códigos como `10L0`, `R015`, `R100`)
 
 Como o campo `Value` do esquemático contém apenas o part number completo (sem a tabela ao lado), a forma mais segura é:
 
 - confirmar `Rshunt` no BOM/compra (Mouser/nota fiscal/etiqueta do reel) **ou**
 - decodificar pelo datasheet (usando as tabelas de `special code` e do código de resistência).
 
 **Para cálculo no firmware, defina `Rshunt_3v3`, `Rshunt_5v`, `Rshunt_12v` explicitamente (em ohms) e não “assuma” pelo part number.**
 
 ## 2) Mapeamento de pinos (conforme `firmware_UCE.ioc`)
 
 O CubeMX está configurado para usar os OPAMPs como front-end e ler a saída deles via canais internos do ADC:
 
 ### 2.1) OPAMP1 + ADC1 (shunt 3.3V)
 
 - **OPAMP1_VINP**: `PA1` (label: `shunt_3v3_in`)
 - **OPAMP1_VINM0**: `PA3` (label: `shunt_3v3out`)
 - **ADC1**: canal `ADC_CHANNEL_VOPAMP1`
 
 ### 2.2) OPAMP2 + ADC2 (shunt 5V)
 
 - **OPAMP2_VINP**: `PA7` (label: `shunt_5v_in`)
 - **OPAMP2_VINM0**: `PA5` (label: `shunt_5v_out`)
 - **ADC2**: canal `ADC_CHANNEL_VOPAMP2`
 
 ### 2.3) OPAMP3 + ADC3 (shunt 12V)
 
 - **OPAMP3_VINP**: `PB0` (label: `shunt_12v_in`)
 - **OPAMP3_VINM0**: `PB2` (label: `shunt_12v_out`)
 - **ADC3**: canal `ADC_CHANNEL_VOPAMP3_ADC3`
 
 ## 3) Configuração do ADC (como está no projeto)
 
 No código gerado (`Core/Src/adc.c`), todos os ADCs estão em:
 
 - resolução **12 bits** (`ADC_RESOLUTION_12B`)
 - alinhamento à direita
 - conversão por **software start** (`ADC_SOFTWARE_START`)
 - 1 conversão por sequência (`NbrOfConversion = 1`)
 - amostragem: `ADC_SAMPLETIME_12CYCLES_5`
 
 Importante: o `adc.c` está configurado para ler os canais internos `VOPAMP1`, `VOPAMP2`, `VOPAMP3`.
 
 ## 4) Configuração do OPAMP (como usar no STM32G4)
 
 No estado atual do repositório, `Core/Src/opamp.c` contém apenas as funções `MX_OPAMP1_Init()`, `MX_OPAMP2_Init()`, `MX_OPAMP3_Init()` vazias.
 
 Isso significa que:
 
 - o roteamento dos pinos está definido no `.ioc`;
 - o ADC está pronto para ler `VOPAMPx`;
 - **mas falta inicializar e habilitar os OPAMPs** (seleção de modo, entrada, ganho e start).
 
 Recomendações para configurar no CubeMX (STM32G4 OPAMP):
 
 - **Modo**: para medir shunt normalmente você usa o OPAMP como amplificador (PGA) ou como amplificador não inversor com ganho definido.
 - **Ganho**: selecione um ganho tal que a queda de tensão máxima no shunt, multiplicada pelo ganho, não ultrapasse `VREF` do ADC.
 - **Saída interna para ADC**: habilite a conexão para que o ADC leia `VOPAMPx`.
 
 Como o ganho não está explicitado no `.ioc` atual, os cálculos abaixo são apresentados de forma **parametrizada** por `G` (ganho do OPAMP) e por `Vref` (referência do ADC).
 
 ### 4.1) Calibração de offset (recomendado)
 
 Mesmo em medição unidirecional, offsets podem aparecer (offset do OPAMP/ADC, pequenas diferenças de referência e assimetria dos pontos Kelvin).
 
 Sugestão simples:
 
 - com a carga desligada (corrente ~0A), capture `adc_raw_zero` por canal;
 - converta para `Vopamp_out_zero`;
 - use `Vopamp_out_corrigido = Vopamp_out - Vopamp_out_zero` antes de calcular `Vshunt`.
 
 ## 5) Conversão ADC -> tensão
 
 Para um ADC de 12 bits:
 
 - `ADC_FS = 4095`
 
 A tensão equivalente na entrada do ADC (ou seja, na saída do OPAMP) é:
 
 - `Vopamp_out = (adc_raw / 4095) * Vref`
 
 Onde `Vref` normalmente é ~3.3V (dependendo de como `VREF+` está alimentado no hardware).
 
 ## 6) Cálculo da corrente no shunt
 
 ### 6.1) Relação entre Vopamp_out e a queda no shunt
 
 Em uma medição típica de shunt, você quer estimar:
 
 - `Vshunt = V(in) - V(out)`
 
 Se o OPAMP estiver configurado para produzir na saída um sinal proporcional à queda no shunt com ganho `G`:
 
 - `Vopamp_out = G * Vshunt`
 
 então:
 
 - `Vshunt = Vopamp_out / G`
 
 **Observação**: dependendo do modo escolhido no CubeMX (PGA, follower, etc.) pode existir offset/CM. Se você usar offset (ex.: para permitir correntes bidirecionais), ajuste a equação para subtrair o offset antes de dividir por `G`.
 
 ### 6.2) Corrente
 
 A corrente no shunt é:
 
 - `I = Vshunt / Rshunt`
 
 Substituindo:
 
 - `I = (Vopamp_out / G) / Rshunt`
 - `I = Vopamp_out / (G * Rshunt)`
 
 Com `Rshunt` em ohms.
 
 ## 7) Queda de tensão e tensão efetiva do barramento
 
 Uma vez calculada a corrente `I`:
 
 - **queda no shunt**: `Vdrop = I * Rshunt`
 
 Se `Vbus_in` é a tensão antes do shunt e `Vbus_out` é a tensão após o shunt:
 
 - `Vbus_out = Vbus_in - Vdrop`
 
 Se você considera o barramento nominal como 3.3V/5V/12V e quer estimar a tensão efetiva disponível **depois** do shunt:
 
 - `Vbus_eff_3v3 = 3.3 - Vdrop_3v3`
 - `Vbus_eff_5v  = 5.0 - Vdrop_5v`
 - `Vbus_eff_12v = 12.0 - Vdrop_12v`
 
 Isso é especialmente útil para avaliar perda por consumo elevado.
 
 ## 8) Exemplo numérico (didático)
 
 Suponha:
 
 - `Vref = 3.3 V`
 - `G = 16` (exemplo de ganho)
 - `Rshunt = 5 mΩ = 0.005 Ω` (exemplo)
 - `adc_raw = 620`
 
 1) Tensão na saída do OPAMP:
 
 - `Vopamp_out = (620/4095) * 3.3 ≈ 0.499 V`
 
 2) Queda no shunt:
 
 - `Vshunt = 0.499 / 16 ≈ 0.0312 V`
 
 3) Corrente:
 
 - `I = 0.0312 / 0.005 ≈ 6.24 A`
 
 4) Queda e tensão efetiva (por exemplo no barramento 5V):
 
 - `Vdrop = 6.24 * 0.005 ≈ 0.0312 V`
 - `Vbus_eff = 5.0 - 0.0312 ≈ 4.969 V`
 
 ## 9) Implementação sugerida (estrutura do algoritmo)
 
 Para cada barramento (3.3V, 5V, 12V), faça:
 
 - ler `adc_raw` do ADC correspondente (`ADC1/ADC2/ADC3`);
 - converter para `Vopamp_out`;
 - converter para `Vshunt` dividindo por `G` (e removendo offset, se existir);
 - converter para `I` dividindo por `Rshunt`;
 - calcular `Vdrop = I * Rshunt`;
 - calcular `Vbus_eff = Vbus_nominal - Vdrop`.
 
 Parâmetros que devem ser definidos no firmware:
 
 - `Vref` (em volts)
 - `G1`, `G2`, `G3` (ganhos dos OPAMPs)
 - `Rshunt_3v3`, `Rshunt_5v`, `Rshunt_12v` (ohms)
 
 ## 10) Referência de vídeo
 
 https://www.youtube.com/watch?v=kzecsy9Qnhc
