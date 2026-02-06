# ✅ Checklist de Migração de Medidas

## 📋 Visão Geral

Este checklist **OBRIGATÓRIO** deve ser seguido para toda migração de medidas do V3 para o V2 (ou entre modelos).

**Objetivo:** Garantir que todas as medidas migradas possuam documentação completa e sigam os padrões estabelecidos.

**Responsável:** Data Team / Developer que está realizando a migração

**Revisão:** Peer review obrigatório antes de aplicar ao Power BI

---

## 📅 Informações da Migração

- **Data:** _____________
- **Responsável:** _____________
- **Revisor:** _____________
- **Modelo Origem:** _____________
- **Modelo Destino:** _____________
- **Total de Medidas:** _____________

---

## 🔍 FASE 1: PRÉ-MIGRAÇÃO

### 1.1 Preparação e Planejamento

- [ ] **Documentação lida e compreendida**
  - [ ] `best-practices/dax-comments.md` revisado
  - [ ] `.agents/agents/dax-specialist.md` consultado
  - [ ] Exemplos de medidas bem documentadas analisados

- [ ] **Ferramentas instaladas**
  - [ ] `MeasureMigrationTools.ps1` importado
  - [ ] Funções testadas com exemplo
  - [ ] Power BI MCP configurado e funcionando

- [ ] **Análise de dependências**
  - [ ] Todas as medidas base identificadas
  - [ ] Dependências mapeadas (tabelas, colunas, medidas)
  - [ ] Equivalências no modelo destino confirmadas
  - [ ] Ajustes necessários documentados

### 1.2 Preparação das Definições

Para cada medida a ser migrada:

- [ ] **Nome definido**
  - [ ] Segue convenção Title Case com espaços
  - [ ] Sufixos apropriados adicionados (%, YTD, etc.)
  - [ ] Nome único no modelo destino

- [ ] **Expressão DAX ajustada**
  - [ ] Referências a medidas atualizadas
  - [ ] Referências a tabelas atualizadas
  - [ ] Referências a colunas atualizadas
  - [ ] Sintaxe validada

- [ ] **Documentação preparada**
  - [ ] Propósito de negócio definido claramente
  - [ ] Lógica descrita passo-a-passo
  - [ ] Dependências listadas
  - [ ] Regras de negócio documentadas
  - [ ] Notas adicionais incluídas (se aplicável)

- [ ] **Metadados definidos**
  - [ ] Display Folder correto
  - [ ] Format String apropriado
  - [ ] Description (annotation) escrito
  - [ ] Hidden (se helper measure)

---

## 🔨 FASE 2: CRIAÇÃO

### 2.1 Uso das Ferramentas

- [ ] **Template usado corretamente**
  - [ ] `New-MigratedMeasure` chamado com todos os parâmetros obrigatórios
  - [ ] Parâmetro `-Name` preenchido
  - [ ] Parâmetro `-Expression` preenchido (DAX puro, sem comentários)
  - [ ] Parâmetro `-Purpose` preenchido
  - [ ] Parâmetro `-Logic` preenchido (se medida complexa)
  - [ ] Parâmetro `-Dependencies` preenchido (array)
  - [ ] Parâmetro `-DisplayFolder` preenchido
  - [ ] Parâmetro `-FormatString` preenchido (se aplicável)
  - [ ] Parâmetros opcionais preenchidos conforme necessário

### 2.2 Validação Pré-Criação

**🔴 OBRIGATÓRIO: Esta validação DEVE passar antes de prosseguir**

- [ ] **Validação automática executada**
  - [ ] `Test-MeasureHasDocumentation` executado
  - [ ] Validação passou ✅
  - [ ] Se falhou: Correções aplicadas e re-validado

- [ ] **Inspeção manual**
  - [ ] Expressão gerada inspecionada visualmente
  - [ ] Comentários DAX presentes e completos
  - [ ] Bloco `/* ... */` presente
  - [ ] Emoji 📦 presente
  - [ ] Seções obrigatórias presentes:
    - [ ] PROPÓSITO
    - [ ] DEPENDÊNCIAS
    - [ ] ORIGEM
    - [ ] DATA
    - [ ] AUTOR

### 2.3 Revisão de Código (Peer Review)

**🔴 OBRIGATÓRIO: Peer review antes de aplicar ao Power BI**

- [ ] **Código revisado por:** _____________
- [ ] **Data da revisão:** _____________

**Checklist do Revisor:**

- [ ] Expressão DAX está correta
- [ ] Comentários são claros e precisos
- [ ] Documentação explica o "POR QUÊ", não apenas o "O QUÊ"
- [ ] Dependências estão corretas
- [ ] Metadados apropriados
- [ ] Segue padrão estabelecido
- [ ] Sem erros de digitação ou gramática
- [ ] Revisão aprovada ✅

**Comentários do Revisor:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

---

## 🚀 FASE 3: APLICAÇÃO

### 3.1 Criação no Power BI

- [ ] **Backup realizado**
  - [ ] Arquivo .pbix salvo com backup
  - [ ] TMDL exportado antes das mudanças
  - [ ] Cópia de segurança criada

- [ ] **Medidas criadas via MCP**
  - [ ] Conexão com Power BI estabelecida
  - [ ] Comando MCP `measure_operations:Create` executado
  - [ ] Todas as medidas criadas com sucesso
  - [ ] Nenhum erro reportado

- [ ] **Verificação imediata**
  - [ ] Medidas aparecem no Power BI Desktop
  - [ ] Display Folders corretos
  - [ ] Format Strings aplicados corretamente
  - [ ] Descriptions visíveis

---

## ✅ FASE 4: PÓS-MIGRAÇÃO

### 4.1 Validação Funcional

- [ ] **Testes básicos**
  - [ ] Medidas retornam valores (não BLANK ou ERROR)
  - [ ] Valores parecem razoáveis
  - [ ] Sem erros de sintaxe

- [ ] **Testes de dependências**
  - [ ] Medidas dependentes funcionam corretamente
  - [ ] Filtros aplicam corretamente
  - [ ] Context transitions funcionam

- [ ] **Comparação V3 vs V2** (se aplicável)
  - [ ] Mesmos filtros aplicados em ambos os modelos
  - [ ] Valores idênticos ou dentro de tolerância aceitável
  - [ ] Discrepâncias documentadas e explicadas

### 4.2 Validação de Documentação

- [ ] **Exportar TMDL atualizado**
  - [ ] TMDL exportado do modelo após criação
  - [ ] Arquivo salvo em `golden-dataset-tmdl/`

- [ ] **Verificar comentários no TMDL**
  - [ ] Abrir arquivo TMDL em editor de texto
  - [ ] Localizar cada medida migrada
  - [ ] Confirmar que comentários DAX estão presentes
  - [ ] Confirmar que comentários estão completos

- [ ] **Validação automática em TMDL**
  - [ ] Script de validação executado no TMDL
  - [ ] Todas as medidas migradas possuem documentação
  - [ ] Nenhuma violação de padrão detectada

### 4.3 Testes de Performance

- [ ] **Métricas de execução**
  - [ ] Query DAX executada com `GetExecutionMetrics`
  - [ ] Tempo de execução aceitável (< 2 segundos ideal)
  - [ ] Sem gargalos identificados

- [ ] **Análise SE vs FE**
  - [ ] Storage Engine sendo utilizado apropriadamente
  - [ ] Formula Engine não sobrecarregado
  - [ ] Sem iteradores desnecessários

### 4.4 Documentação Final

- [ ] **Relatório de migração atualizado**
  - [ ] `New-MeasureMigrationReport` executado
  - [ ] Relatório markdown gerado
  - [ ] Relatório salvo em `validation/results/`

- [ ] **Checklist de migração atualizado**
  - [ ] Plano de migração marcado como concluído
  - [ ] Medidas marcadas como ✅ MIGRADAS
  - [ ] Data de conclusão registrada

- [ ] **Commit e push**
  - [ ] Arquivos TMDL atualizados commitados
  - [ ] Relatórios commitados
  - [ ] Checklists atualizados commitados
  - [ ] Mensagem de commit descritiva

---

## 📊 RESUMO DE QUALIDADE

### Métricas de Qualidade

| Métrica | Meta | Real | Status |
|---------|------|------|--------|
| Medidas com documentação | 100% | ___% | ⬜ |
| Validações passando | 100% | ___% | ⬜ |
| Peer reviews aprovados | 100% | ___% | ⬜ |
| Testes funcionais OK | 100% | ___% | ⬜ |
| Performance aceitável | 100% | ___% | ⬜ |

### Score de Qualidade

**Total de checks:** ___ / ___
**Percentual:** ___%

- ✅ **100%**: Excelente - Pronto para produção
- ⚠️ **90-99%**: Bom - Revisar itens pendentes
- ❌ **< 90%**: Insuficiente - Correções necessárias

---

## 🚨 PROBLEMAS ENCONTRADOS

**Se algum item falhou, documente aqui:**

| # | Problema | Severidade | Ação Corretiva | Responsável | Status |
|---|----------|------------|----------------|-------------|--------|
| 1 | | 🔴/🟡/🟢 | | | ⬜ |
| 2 | | 🔴/🟡/🟢 | | | ⬜ |
| 3 | | 🔴/🟡/🟢 | | | ⬜ |

**Legenda de Severidade:**
- 🔴 **CRÍTICO:** Bloqueia produção
- 🟡 **MÉDIO:** Deve ser corrigido em breve
- 🟢 **BAIXO:** Melhoria futura

---

## ✍️ APROVAÇÕES

### Aprovação Técnica

- [ ] **Desenvolvedor:** _____________
  - **Data:** _____________
  - **Assinatura:** _____________

- [ ] **Revisor:** _____________
  - **Data:** _____________
  - **Assinatura:** _____________

### Aprovação de Qualidade

- [ ] **QA/Validador:** _____________
  - **Data:** _____________
  - **Assinatura:** _____________

### Aprovação Final

- [ ] **Tech Lead:** _____________
  - **Data:** _____________
  - **Assinatura:** _____________

---

## 📎 ANEXOS

### Links Importantes

- [Padrão de Comentários DAX](../best-practices/dax-comments.md)
- [Convenções de Nomenclatura](../best-practices/naming-conventions.md)
- [Padrões DAX](../best-practices/dax-patterns.md)
- [Agente DAX Specialist](../.agents/agents/dax-specialist.md)
- [Medidas Corrigidas (Exemplo)](../validation/results/medidas-corrigidas-com-documentacao.md)
- [Análise de Causa Raiz](../validation/results/analise-causa-raiz-falta-documentacao.md)

### Ferramentas

- [MeasureMigrationTools.ps1](../scripts/MeasureMigrationTools.ps1)
- [Example-UseMigrationTools.ps1](../scripts/Example-UseMigrationTools.ps1)
- [Update-MeasuresWithDocumentation.ps1](../scripts/Update-MeasuresWithDocumentation.ps1)

---

## 📝 NOTAS ADICIONAIS

```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

---

**Versão:** 1.0
**Data de Criação:** 2026-02-03
**Última Atualização:** 2026-02-03
**Responsável:** Data Team - Quality Assurance

---

## 🎯 LEMBRE-SE

> **"Documentação não é opcional. É parte fundamental da qualidade do código."**

> **"Um código sem documentação é um débito técnico esperando para acontecer."**

> **"Documente pensando em quem vai ler daqui a 6 meses - pode ser você mesmo!"**

✅ **Use este checklist em TODAS as migrações futuras!**
