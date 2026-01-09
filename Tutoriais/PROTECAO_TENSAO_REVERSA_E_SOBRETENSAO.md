# Proteção contra tensão reversa e sobretensão (3.3 V a 12 V)

Este tutorial descreve como projetar um estágio de proteção para um **power rail/barramento DC** na faixa de **3.3 V a 12 V**, para reduzir o risco de dano quando:

- a alimentação é conectada com **polaridade invertida**;
- o usuário aplica uma **tensão maior do que a permitida** no barramento (ex.: injetar 12 V em um rail de 3.3 V);
- existe risco de **injeção de tensão** por outro caminho (ex.: cabo externo, periféricos, pinos de expansão, ESD, etc.).

A ideia geral é separar o problema em 2 funções:

- **1) bloquear corrente no sentido errado** (reverse polarity / backfeed)
- **2) limitar/desconectar em caso de sobretensão** (OVP)

A solução “certa” depende do que você quer proteger:

- **Barramento como entrada de energia** (um conector recebe alimentação externa)
- **Barramento como distribuição interna** (gerado na placa e exposto ao usuário)

Em projetos educacionais (onde o usuário pode errar), normalmente vale a pena usar uma proteção mais robusta, mesmo que custe mais.

## 0) Premissas deste projeto

- Os rails (3.3 V, 5 V, 12 V) são **somente saída**.
- Cada rail deve suportar até **1 A**.

Consequência importante:

- A proteção deve **impedir que o usuário alimente o rail por fora** (backfeed). Ou seja, além de proteger contra polaridade reversa/sobretensão, o estágio deve ter **bloqueio de corrente reversa** (de `VOUT` para `VIN`).

## 1) Cenários de falha típicos

### 1.1) Polaridade reversa

Exemplos:

- fonte DC com conector 2 vias invertido;
- jacaré/banana invertidos;
- cabo de alimentação montado errado.

Efeito:

- sem proteção, componentes podem conduzir pela junção PN e queimar rapidamente.

### 1.2) Sobretensão (o caso “12 V no rail de 3.3 V”)

Exemplos:

- o usuário conecta o rail errado no conector (mistura 3.3 V/5 V/12 V);
- um módulo externo injeta 12 V por engano em um pino que deveria ser 3.3 V.

Efeito:

- 3.3 V é excedido rapidamente, e geralmente o dano ocorre em:
  - MCU/SoC (pinos e VDD)
  - sensores
  - LDOs/bucks (se estiverem “no caminho reverso”)

### 1.3) Backfeed (injeção por carga)

Mesmo se você protege o “input principal”, ainda pode existir injeção por:

- sinais de IO com diodos internos (clamp ESD nos pinos do MCU)
- periféricos conectados
- outra fonte conectada em paralelo

Para esse caso, quase sempre você precisa de **isolamento por caminho de alimentação** (série com MOSFET/eFuse) e de regras de interface (resistores, proteção de IO, etc.).

## 2) Requisitos práticos (o que definir antes)

Defina, para cada rail que será exposto ao usuário (3.3 V, 5 V, 12 V):

- **Vnom**: tensão nominal (3.3/5/12)
- **Imax**: corrente máxima esperada
- **Vrev**: quanto tempo/nível você quer sobreviver com polaridade invertida (idealmente indefinido)
- **Vov_trip**: tensão em que deve desligar (ex.: 3.6–4.0 V para rail 3.3 V)
- **Energia de surtos/ESD**: se o conector for “externo”, você precisa de TVS

Também defina se o rail pode ser **entrada OU saída** (bidirecional). Em rails “educacionais”, muitas vezes o rail é exposto como saída, mas o usuário pode tentar usar como entrada.

- Se você quer **impedir que o rail seja alimentado por fora**, você precisa bloquear backfeed.

Nesta placa, como os rails são **somente saída**, o bloqueio de backfeed não é opcional.

## 3) Topologia A (simples, barata): fusível + MOSFET de polaridade + TVS

Esta topologia é boa para:

- polaridade reversa;
- surtos/ESD;
- curto na saída (dependendo do fusível);

Mas **não é a melhor** para “12 V aplicado em rail 3.3 V”, porque o TVS pode ter que absorver muita energia e o fusível pode demorar a atuar.

### 3.1) Bloco do circuito

```
VIN ---- F1 ---- Q1 (MOSFET ideal diode) ---- VOUT ---- COUT ---- carga
                         |
                         +---- DTVS para GND (opcional, recomendado em conector)
```

- **F1**: polyfuse (PTC) ou fusível normal.
- **Q1**: MOSFET canal P no high-side (ou N com controlador ideal diode). Configurado para atuar como “diodo ideal” (baixa queda) e bloquear reverso.
- **DTVS**: TVS para proteger contra ESD e transientes rápidos (não para “segurar 12 V indefinidamente”).

Notas de dimensionamento (para até 1 A):

- Para não perder muita tensão, você quer **Rds(on) baixo**. Exemplo de ordem de grandeza:
  - alvo `Rds(on) <= 50 mΩ` (em condições realistas de `VGS`)
  - queda a 1 A: `V = I*R = 1A*0.05Ω = 50 mV`
  - dissipação a 1 A: `P = I²*R = 1²*0.05 = 50 mW`
- Se usar PTC como F1, escolha um modelo com:
  - `Ihold` maior que sua corrente nominal contínua (ex.: 1 A)
  - `Itrip` coerente com sua fonte/corrente de curto
  - atenção: PTC pode demorar para atuar e deixa a placa aquecida durante falha.

### 3.2) Como o MOSFET bloqueia reverso (visão rápida)

- Com polaridade correta, você puxa o gate do MOSFET de forma que `VGS` fique negativo e o MOSFET conduza.
- Com polaridade invertida, o diodo de corpo fica reversamente polarizado e o MOSFET desliga, bloqueando corrente.

### 3.3) Limitações desta topologia

- **Sobretensão contínua** (ex.: 12 V em rail 3.3 V) só é “resolvida” se:
  - o TVS entrar em avalanche e o **fusível abrir/limitar** rápido o suficiente;
  - e a energia térmica for aceitável.

Em um produto educacional, isso pode funcionar como “último recurso”, mas não é uma proteção elegante.

## 4) Topologia B (recomendada): eFuse/hot-swap com reverse + OVP cutoff

Para evitar dano quando o usuário aplica a tensão errada, o ideal é **desconectar o rail automaticamente** quando `VOUT` ou `VIN` passar do limite.

A forma mais prática e robusta é usar um **eFuse / load switch com proteção**.

### 4.1) Bloco do circuito

```
VIN ---- (TVS) ---- eFuse/LoadSwitch (reverse + OVP + ILIM) ---- VOUT ---- carga
```

Esse CI geralmente fornece:

- **Reverse input protection** (bloqueia polaridade invertida)
- **Reverse current blocking** (impede backfeed do VOUT para VIN)
- **Overvoltage protection (OVP)**: desliga acima de um threshold
- **Current limit / short protection**: limita corrente em falha
- **Thermal shutdown**

### 4.2) Como aplicar na faixa 3.3 V a 12 V

Em um sistema com múltiplos rails expostos (3.3/5/12), a prática recomendada é:

- Ter **um eFuse por rail exposto**, com limiar de OVP adequado:
  - rail 3.3 V: trip ~3.6–4.0 V
  - rail 5 V: trip ~5.6–6.5 V
  - rail 12 V: trip ~13.0–15 V (dependendo do que seus componentes suportam)

Assim, se o usuário aplicar 12 V no rail 3.3 V, o eFuse do rail 3.3 V **abre** e isola o barramento rapidamente.

Para o requisito de 1 A:

- Selecione eFuse/load switch com `ILIM` programável ou fixo que suporte:
  - corrente contínua >= 1 A
  - eventos de curto (foldback/limite/thermal)
- Verifique a queda de tensão no caminho:
  - `Vdrop ≈ I * Ron` (para load switches com resistência de condução)
  - quanto menor `Ron`, melhor para manter 3.3 V dentro da tolerância com 1 A.

### 4.3) Componentes típicos ao redor do eFuse

- Capacitores de entrada/saída (para estabilidade e resposta a transientes)
- Resistor/programação de limite de corrente (se aplicável)
- Pino `EN` e/ou `FAULT` para o MCU sinalizar e registrar falhas

### 4.4) Vantagens

- Atua rápido e de forma repetível.
- Dissipa menos que uma proteção “crowbar+fusível” em erros comuns.
- Ajuda muito no caso de **injeção** e **backfeed**.

### 4.5) Observações importantes

- Verifique a **faixa de operação do CI** (tensão máxima absoluta e tensão operacional).
- Confirme se ele bloqueia **reverse current** (muitos load switches simples não bloqueiam).

## 5) Alternativa clássica para OVP: “crowbar” + fusível (quando faz sentido)

Outra técnica é forçar um curto controlado quando `VOUT` excede o limite, fazendo o fusível atuar:

- Comparador/referência detecta sobretensão.
- Um SCR/triac/MOSFET é acionado, “derrubando” o rail.

Essa abordagem pode ser útil quando:

- você quer uma proteção de sobretensão muito “agressiva”;
- a fonte que alimenta o rail é limitada;
- você aceita trocar fusível (ou deixar o PTC aquecer e limitar).

Mas em rails educacionais (onde o usuário pode errar várias vezes), eFuse costuma ser melhor UX.

## 6) Checklist de implementação (o que não esquecer)

- **Proteção precisa estar o mais perto possível do conector** onde o erro pode acontecer.
- Use **TVS** em entradas expostas para ESD/transientes.
- Garanta **bloqueio de corrente reversa** (backfeed) quando o rail pode ser alimentado externamente.
- Considere também a **proteção dos sinais (IO)**: se o usuário injeta tensão por um pino de sinal, o rail pode subir via diodos internos.
- Se houver conversores DC-DC/LDO, verifique se precisam de:
  - diodo de bypass (proteção contra corrente reversa)
  - ou se o próprio eFuse resolve o backfeed

## 7) Recomendação direta para este caso (rails somente saída, até 1 A)

- Use **um estágio com bloqueio de corrente reversa + OVP por rail exposto**.
- Para o rail **3.3 V**, priorize uma solução que realmente **desconecte** em sobretensão (Topologia B), porque:
  - “12 V no 3.3 V” não é transiente rápido, é erro de conexão;
  - depender só de TVS/Zener vira dissipação e pode falhar.
- Para os rails **5 V** e **12 V**, a mesma lógica se aplica: OVP + reverse-current blocking melhora muito a sobrevivência do kit.

## 8) Recomendações práticas (para um kit educacional)

- Se o rail **3.3 V** for exposto ao usuário: use **eFuse com OVP ajustada** (Topologia B).
- Se o rail **12 V** for exposto ao usuário: use eFuse com **limite de corrente** e **TVS**.
- Evite depender apenas de Zener/TVS para “aguentar 12 V no 3.3 V”: isso vira dissipação térmica e pode falhar.

Observação sobre TVS:

- TVS é excelente para **ESD/transientes curtos**.
- Para erro contínuo de ligação (ex.: conectar 12 V fixo no conector do rail 3.3 V), o elemento que “resolve” deve ser a **desconexão** (eFuse/load switch) e não o TVS.
