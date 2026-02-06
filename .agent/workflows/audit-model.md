---
description: Auditar modelo Power BI completo (qualidade e performance)
---

# Workflow: Auditoria Completa de Modelo

Este workflow executa uma auditoria completa do modelo Power BI, validando qualidade, performance e best practices.

## Agentes Envolvidos

- [model_operations](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/data-modeler.md) - Verificação de estrutura do modelo
- [quality-validator](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/quality-validator.md) - Auditoria de nomenclatura e validação de qualidade
- [relationship-architect](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/relationship-architect.md) - Validação de relacionamentos
- [dax-specialist](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/dax-specialist.md) - Auditoria de medidas
- [performance-optimizer](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/performance-optimizer.md) - Testes de performance
- [data-modeler](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/data-modeler.md) - Verificação de colunas calculadas

## Pré-requisitos
- Conexão ativa com modelo Power BI
- Tempo estimado: 15-30 minutos

## Passos

### 1. Verificar Estrutura do Modelo (model_operations)

// turbo
Execute:
```json
{
  "operation": "Get"
}
```

Anote:
- Número de tabelas
- Número de medidas
- Número de relacionamentos
- Compatibility level

### 2. Obter Estatísticas (model_operations)

// turbo
Execute:
```json
{
  "operation": "GetStats"
}
```

Verifique:
- Tamanho do modelo (< 2GB é ideal)
- Tabelas maiores
- Colunas de alta cardinalidade

### 3. Auditoria de Nomenclatura (quality-validator)

Use o agente quality-validator para verificar:

**Tabelas:**
- [ ] Fatos têm prefixo `Fact`?
- [ ] Dimensões têm prefixo `Dim`?
- [ ] Nomes descritivos?

**Colunas:**
- [ ] Chaves terminam com `Key` ou `ID`?
- [ ] Datas terminam com `Date`?
- [ ] Booleans começam com `Is/Has/Should`?

**Medidas:**
- [ ] Em Title Case?
- [ ] Todas têm description?
- [ ] Organizadas em display folders?
- [ ] Time intelligence usa sufixos (YTD, PY, etc)?

### 4. Validar Relacionamentos (relationship-architect)

// turbo
Liste todos os relacionamentos:
```json
{
  "operation": "List"
}
```

Verifique:
- [ ] Maioria é 1:N (One-to-Many)?
- [ ] Direção é Single (não Both)?
- [ ] Sem circular dependencies?
- [ ] Role-playing dimensions configuradas?

### 5. Validar Date Table (quality-validator)

Verifique se existe tabela de datas:
- [ ] Tabela DimDate existe?
- [ ] Está marcada como Date Table?
- [ ] Contém Year, Quarter, Month, Day?
- [ ] Relacionada às facts por datas?

### 6. Auditar Medidas (dax-specialist)

Para cada medida crítica:
- [ ] Usa variáveis (VAR)?
- [ ] Tem description completa?
- [ ] Tem format string?
- [ ] Annotations presentes?
- [ ] Evita anti-patterns (FILTER(ALL(...)), etc)?

### 7. Performance Check (performance-optimizer)

**7.1. Identificar medidas mais usadas**
Liste as 5-10 medidas principais do modelo

**7.2. Testar performance de cada uma**
```json
{
  "operation": "Execute",
  "query": "EVALUATE ROW(\"Result\", [Nome da Medida])",
  "getExecutionMetrics": true,
  "executionMetricsOnly": true
}
```

**7.3. Analisar métricas**
- Duration < 500ms? ✅
- SE/FE ratio > 3:1? ✅
- Se não, precisa otimização

### 8. Verificar Colunas Calculadas (data-modeler)

Liste colunas calculadas:
```json
{
  "operation": "List"
}
```

Para cada calculated column:
- [ ] Realmente necessária?
- [ ] Pode ser substituída por medida?
- [ ] Pode ser feita no Power Query?

### 9. Gerar Relatório de Qualidade

**Calcular Score:**
```
Nomenclatura:        /25 pontos
Relacionamentos:     /20 pontos
Medidas:             /25 pontos
Performance:         /20 pontos
Documentação:        /10 pontos
---
TOTAL:              /100 pontos
```

**Classificação:**
- 90-100: Excelente ✅
- 75-89: Bom ⚠️
- 60-74: Precisa melhorias ⚠️
- <60: Crítico ❌

### 10. Priorizar Issues (quality-validator)

Liste issues encontrados por prioridade:

**CRITICAL (resolver imediatamente):**
- Circular dependencies
- Bidirectional desnecessário
- Medidas muito lentas (>5s)
- Tabelas sem relacionamento

**HIGH (resolver em breve):**
- Nomenclatura inconsistente
- Medidas sem description
- Colunas calculadas desnecessárias
- Performance moderada (1-5s)

**MEDIUM (backlog):**
- Falta de display folders
- Annotations incompletas
- Documentação faltando

**LOW (nice to have):**
- Pequenas inconsistências
- Otimizações incrementais

## Checklist Final

- [ ] Estrutura de modelo obtida
- [ ] Estatísticas analisadas
- [ ] Nomenclatura validada
- [ ] Relacionamentos verificados
- [ ] Date table confirmada
- [ ] Medidas auditadas
- [ ] Performance testada
- [ ] Colunas calculadas revisadas
- [ ] Score calculado
- [ ] Issues priorizados
- [ ] Relatório gerado

## Output Esperado

Ao final, você deve ter:

1. **Relatório de Auditoria** com:
   - Score geral (/100)
   - Issues encontrados (por prioridade)
   - Recomendações específicas
   - Métricas de performance

2. **Action Plan** com:
   - Issues críticos para resolver primeiro
   - Estimativa de tempo
   - Ordem de execução

## Exemplo de Relatório

```markdown
# Auditoria - Modelo Vendas

**Score:** 78/100 (Bom ⚠️)

## Issues Encontrados

### CRITICAL
- ❌ Relacionamento Many-to-Many sem justificativa (Product <-> Category)

### HIGH
- ⚠️ 15 medidas sem description
- ⚠️ Medida "Sales Total Complex" demora 3.5s

### MEDIUM
- 📝 Apenas 30% das medidas em display folders

## Recomendações

1. Substituir M:N por bridge table
2. Adicionar descriptions usando documentation-expert
3. Otimizar "Sales Total Complex" usando performance-optimizer
4. Organizar medidas em pastas
```

---

**Tempo estimado:** 15-30 minutos
**Frequência recomendada:** Mensal ou após mudanças grandes
