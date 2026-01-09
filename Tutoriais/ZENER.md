# Regulador com diodo Zener para obter 3.3 V
 
 Referência rápida:
 
 * https://www.tmatlantic.com/encyclopedia/index.php?ELEMENT_ID=54204
 
 ## 1) Contexto e ponto crítico: Vin = 3.3 V
 
 Um regulador “Zener + resistor” é um **regulador shunt**:
 
 - **R** em série limita corrente.
 - O **Zener** “puxa” corrente para manter a tensão no nó próximo de `VZ`.
 
 Isso só funciona se houver **folga de tensão** no resistor:
 
 - Se `Vin = 3.3 V` e você quer `Vout = 3.3 V`, então `Vin - Vout ≈ 0 V`.
 - Com `0 V` no resistor, não há corrente “sobrando” para alimentar a carga **e** manter `IZ` no Zener.
 
 Portanto:
 
 - **Com Vin = 3.3 V, Zener NÃO regula**. A saída ficará `<= Vin` e ainda pode cair por causa de resistências e dinâmica de carga.
 - Zener só faz sentido aqui se **Vin for maior que 3.3 V por uma margem** (ex.: 5 V, 12 V, etc.).
 
 Se sua alimentação pode ser `3.3 V` (igual ao alvo), o correto é:
 
 - **não usar Zener como regulador**, e sim garantir uma fonte `3.3 V` estável (LDO/buck) ou aceitar que `Vout ≈ Vin`.
 
 ## 2) Dados de corrente do STM32G484 (ordem de grandeza)
 
 No datasheet do `STM32G484CE` (tabelas de “Typical current consumption in Run and Low-power run modes”), valores típicos indicados incluem:
 
 - **Run ~150 MHz (Range 1, PLL ON)**: `IDD ≈ 17.5 mA` (típico, dependendo do código/atividade).
 - **Run ~26 MHz**: `IDD ≈ 2.65 mA` (típico, dependendo do código/atividade).
 - **Low-power run ~2 MHz**: `IDD ≈ 825 µA` (típico, dependendo do código/atividade).
 
 Importante:
 
 - Esses números variam com clock, periféricos, GPIOs, carga externa, temperatura e VDD.
 - Para dimensionar, você deve usar um `Iload_max` que represente **o pior caso do seu firmware + periféricos alimentados em 3.3 V**.
 
 Para este tutorial, vou assumir um exemplo conservador para o “consumo do nó 3.3 V”:
 
 - `Iload_max = 25 mA` (MCU em alta performance + alguma margem)
 
 Ajuste esse número para a sua realidade.
 
 ## 3) Escolha do Zener (3.3 V)
 
 Escolha um Zener nominal `VZ ≈ 3.3 V` (ex.: `BZX55C3V3`, `BZT52C3V3`, etc.).
 
 Atenção às diferenças:
 
 - **VZ depende da corrente `IZ`** (é especificado em uma corrente de teste `IZT`).
 - **Tolerância** (ex.: 2%, 5%) e **coeficiente de temperatura** importam.
 - Em `IZ` muito baixo, o Zener pode ficar “mole” (regulação ruim).
 
 Para um regulador shunt simples, normalmente você escolhe uma corrente mínima de Zener para manter a regulação aceitável, por exemplo:
 
 - `IZ_min` entre `2 mA` e `5 mA` (depende do diodo escolhido e da qualidade de regulação desejada)
 
 Neste tutorial vou usar:
 
 - `IZ_min = 5 mA`
 
 ## 4) Cálculo do resistor série (R)
 
 ### Fórmula base
 
 A corrente no resistor é:
 
 `IR = (Vin - Vout) / R`
 
 E ela se divide em:
 
 `IR = Iload + IZ`
 
 Para garantir regulação no pior caso (carga máxima), queremos:
 
 `IZ >= IZ_min` quando `Iload = Iload_max`.
 
 Então, no pior caso:
 
 `IR_min_needed = Iload_max + IZ_min`
 
 Logo:
 
 `R_max = (Vin_min - Vout) / (Iload_max + IZ_min)`
 
 Você escolhe `R <= R_max`.
 
 ### Exemplo 1: Vin_min = 5.0 V
 
 Dados:
 
 - `Vin_min = 5.0 V`
 - `Vout ≈ VZ = 3.3 V`
 - `Iload_max = 25 mA`
 - `IZ_min = 5 mA`
 
 Corrente mínima necessária no resistor:
 
 - `IR = 25 mA + 5 mA = 30 mA`
 
 Queda no resistor:
 
 - `Vr = 5.0 - 3.3 = 1.7 V`
 
 Resistência máxima:
 
 - `R_max = 1.7 V / 0.03 A ≈ 56.7 ohms`
 
 Escolha comercial típica:
 
 - `R = 56 ohms` (E24)
 
 Verificação rápida (com `R=56 ohms`):
 
 - `IR = 1.7/56 ≈ 30.4 mA`
 - Com `Iload=25 mA`, sobra `IZ ≈ 5.4 mA` (ok)
 
 ### Exemplo 2: Vin_min = 3.6 V (margem pequena)
 
 Se `Vin_min = 3.6 V`:
 
 - `Vr = 3.6 - 3.3 = 0.3 V`
 - Para `IR=30 mA`: `R_max = 0.3/0.03 = 10 ohms`
 
 Aqui fica claro o problema: com folga pequena, o resistor precisa ser muito baixo, e o circuito passa a ser:
 
 - muito sensível a variações,
 - com dissipação considerável,
 - e com regulação ruim (porque `IZ` fica “no limite”).
 
 ## 5) Checagem de corrente máxima (carga mínima)
 
 O pior caso para o Zener (dissipação) costuma ser quando a carga consome pouco:
 
 - `Iload_min` pequeno (ex.: MCU em reset, sleep, ou desconectado)
 - `Vin_max` alto
 
 Nesse caso:
 
 - `IZ_max ≈ IR` (quase toda corrente vai para o Zener)
 
 Fórmula:
 
 - `IR_max = (Vin_max - Vout) / R`
 - `IZ_max ≈ IR_max - Iload_min`
 
 ## 6) Potência no resistor e no Zener
 
 ### Potência no resistor
 
 - `PR = (Vin - Vout) * IR`  (ou `PR = IR^2 * R`)
 
 ### Potência no Zener
 
 - `PZ = Vout * IZ`
 
 #### Exemplo com Vin = 5.5 V, R = 56 ohms, carga mínima ~0 mA
 
 - `IR = (5.5 - 3.3)/56 = 2.2/56 ≈ 39.3 mA`
 - `IZ ≈ 39.3 mA`
 - `PR = 2.2 V * 39.3 mA ≈ 86 mW`
 - `PZ = 3.3 V * 39.3 mA ≈ 130 mW`
 
 Seleção de componentes:
 
 - Resistor: use pelo menos `1/4 W` para margem térmica confortável.
 - Zener: escolha pelo menos `500 mW` se houver chance de `Vin_max` maior, ambiente quente, ou carga frequentemente baixa.
 
 ## 7) Conclusões e recomendações
 
 - **Se Vin pode ser 3.3 V**, o Zener **não** é regulador: ele não tem “headroom” para funcionar.
 - Para `Vin > 3.3 V`, dá para dimensionar com:
   - `R` garantindo `IZ_min` no pior caso de carga.
   - checagem de `IZ_max` e potências no pior caso de `Vin_max` e carga mínima.
 - Para alimentar um MCU, normalmente é melhor usar:
   - **LDO 3.3 V** (se Vin for 5 V e corrente moderada), ou
   - **buck 3.3 V** (se Vin for bem maior ou eficiência for importante).
