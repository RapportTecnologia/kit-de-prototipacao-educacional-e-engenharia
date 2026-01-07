# Manual do Carimbo NBR 6492 - Kit Educacional Rapport

Este documento explica como preencher os campos da tela **Configurações da página** do KiCad para que as informações apareçam corretamente no carimbo conforme a norma **NBR 6492**.

---

## Seleção do Template

Na seção **Folha de desenho**, no campo **Arquivo**, selecione um dos templates:

| Template | Uso |
|----------|-----|
| `rapport_abnt_with_logo.kicad_wks` | Com logotipo da empresa |
| `rapport_abnt_without_logo.kicad_wks` | Sem logotipo |

---

## Mapeamento dos Campos

A tabela abaixo mostra como cada campo do KiCad é exibido no carimbo NBR 6492:

| Campo KiCad | Campo no Carimbo | Descrição | Exemplo |
|-------------|------------------|-----------|---------|
| **Título** | PROJETO | Nome do projeto | `KEPR` |
| **Empresa** | EMPRESA | Nome da empresa responsável | `Rapport Tecnologia` |
| **Revisão** | REVISÃO | Número da revisão atual | `0.5` |
| **Data de Emissão** | DATA | Data de emissão do desenho | `2025-12-31` |
| **Comentário1** | Endereço da Empresa | Endereço, CNPJ e telefone | `Rua Example, 123 - CNPJ: 00.000.000/0001-00` |
| **Comentário2** | CLIENTE | Nome do cliente/contratante | `Cliente XYZ Ltda` |
| **Comentário3** | CONTEÚDO | Descrição do conteúdo da prancha | `Esquemático Principal - Fonte de Alimentação` |
| **Comentário4** | LOCAL | Cidade/Local do projeto | `São Paulo - SP` |
| **Comentário5** | ESCALA | Escala do desenho | `1:1` ou `N/A` |
| **Comentário6** | DESENHO | Nome do desenhista | `João Silva` |
| **Comentário7** | VERIFICAÇÃO | Nome do verificador | `Maria Santos` |
| **Comentário8** | APROVAÇÃO | Nome do aprovador | `Carlos Oliveira` |
| **Comentário9** | (Reservado) | Uso futuro | - |

---

## Campos Automáticos

Os seguintes campos são preenchidos automaticamente pelo KiCad:

| Campo no Carimbo | Origem | Descrição |
|------------------|--------|-----------|
| **PRANCHA** | Sistema | Número da folha atual / Total de folhas (ex: `1/7`) |
| **FORMATO** | Configuração de papel | Formato do papel selecionado (ex: `A3`, `A4`) |
| **Nome do arquivo** | Sistema | Nome do arquivo `.kicad_sch` ou `.kicad_pcb` |

---

## Estrutura Visual do Carimbo

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ EMPRESA:                                                                     │
│ [Empresa]                                                                    │
│ [Comentário1 - Endereço, CNPJ, Telefone]                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ CLIENTE:                                                                     │
│ [Comentário2]                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ PROJETO:                                                                     │
│ [Título]                                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ CONTEÚDO:                                                                    │
│ [Comentário3]                                                                │
├───────────────┬───────────────┬─────────────┬─────────────┬─────────────────┤
│ LOCAL:        │ DATA:         │ ESCALA:     │ PRANCHA:    │ REVISÃO:        │
│ [Comentário4] │ [Data Emissão]│ [Coment.5]  │ [Auto]      │ [Revisão]       │
├───────────────┼───────────────┼─────────────┼─────────────┴─────────────────┤
│ DESENHO:      │ VERIFICAÇÃO:  │ APROVAÇÃO:  │ FORMATO:                      │
│ [Comentário6] │ [Comentário7] │ [Coment.8]  │ [Auto] / [Nome arquivo]       │
└───────────────┴───────────────┴─────────────┴───────────────────────────────┘
```

---

## Passo a Passo

1. **Abra o projeto** no KiCad (Esquemático ou PCB)

2. **Acesse as configurações de página:**
   - Menu: `Arquivo` → `Configurações da página`
   - Ou pressione o atalho correspondente

3. **Selecione o template:**
   - Em **Arquivo**, clique no ícone de pasta
   - Navegue até a pasta `kicad/KEPR/`
   - Selecione `rapport_abnt_with_logo.kicad_wks` ou `rapport_abnt_without_logo.kicad_wks`

4. **Preencha os campos obrigatórios:**
   - **Título:** Nome do projeto
   - **Empresa:** Nome da sua empresa
   - **Revisão:** Versão atual (ex: `1.0`, `Rev.A`)
   - **Data de Emissão:** Data do desenho

5. **Preencha os campos de comentário** conforme a tabela de mapeamento acima

6. **Marque "Copie nas outras folhas"** para os campos que devem se repetir em todas as páginas

7. Clique em **OK** para aplicar

---

## Dicas

- **Comentário1** é ideal para informações complementares da empresa (endereço, CNPJ, telefone, registro CREA/CAU)
- **Comentário3** deve descrever especificamente o que está representado naquela prancha
- Para projetos eletrônicos, **Escala** geralmente é `1:1` ou `N/A`
- Use **Copie nas outras folhas** para campos que são iguais em todo o projeto (empresa, cliente, projeto)
- Campos como **CONTEÚDO** e **PRANCHA** geralmente variam entre folhas

---

## Dimensões do Carimbo

O carimbo segue as especificações da NBR 6492:
- **Largura:** 175 mm
- **Altura:** 55 mm
- **Posição:** Canto inferior direito da folha

---

## Referências

- **NBR 6492** - Representação de projetos de arquitetura
- **NBR 10068** - Folha de desenho - Leiaute e dimensões
- **NBR 10582** - Apresentação da folha para desenho técnico

---

*Template desenvolvido para o Kit Educacional e Prototipação Rapport*
