# Changelog

## 0.5

* Organização hierárquica das folhas de esquema, com `KEPR.kicad_sch` como folha raiz e as demais como filhas.
* Ajustado os conectores para barramento de Depuração, Networking e Wireless.
* Criado folha para padronizar as folhas dos esquemas, adicionado uma marca d'agua.
* Criado o Barramento que externaliza os sinais obtidos no barramento do módulo do processador

## 0.4

Reorganização da documentação: a especificação da UCE foi movida para `UCE_BOARD.md` e o `README.md` passou a apresentar o projeto e pontos de entrada. Adição de badges (licença CC-BY-4.0, visitas, KiCad, issues, stars e forks) e atualização das referências do repositório para `git@github.com:RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia.git`. Atualização da revisão do projeto KiCad `UCE_Bus` para 0.4.

## 0.3

* foi adotado o Windsurf para finalizar o barramento inserindo os pinos de GND e tensões extras, além de pinos reservados para expanção futura.
* Gestão e melhoria da documentação

## 0.2

Nesta versão fizemos uma revisão inserindo os pinos para Debug, ADC/DAC e identificação do módulo através de um eeprom de 2k. Ficando definido um módulo extra para Network e outro para Debug.

## 0.1

primeira versão decidi usar o modelo propriedde, porém aberto a comunidade, usando um conector SO-DIMM de 200 pinos.

## 0.0

conceito debatido no chatgpt, discutimos sobre os padrões de conectores e barramentos entre eles SO-DIMM, SMARC E QSEVEM, Além de outros
