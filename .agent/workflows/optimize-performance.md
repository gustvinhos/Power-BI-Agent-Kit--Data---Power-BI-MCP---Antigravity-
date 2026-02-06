---
description: Otimizar performance de modelo e queries lentas
---

# Workflow: Otimizar Performance

Este workflow diagnostica e corrige problemas de performance em modelos Power BI.

## Agentes Envolvidos

- [performance-optimizer](../../agents/development/performance-optimizer.md) - Análise e otimização de performance
- [dax-specialist](../../agents/development/dax-specialist.md) - Otimização de medidas DAX
- [data-modeler](../../agents/development/data-modeler.md) - Otimização de estrutura de tabelas
- [relationship-architect](../../agents/development/relationship-architect.md) - Otimização de relacionamentos
- [quality-validator](../../agents/development/quality-validator.md) - Validação pós-otimização

## Pré-requisitos
- Conexão ativa com modelo
- Saber quais queries/medidas estão lentas
- Tempo estimado: 30-90 minutos

## Passos

### 1. Estabelecer Baseline (performance-optimizer)

**1.1. Obter estatísticas do modelo:**
```json
{
  "operation": "GetStats"
}
```

Anote:
- Tamanho do modelo (MB/GB)
- Tabelas maiores
- Número de colunas
- Número de relacionamentos

**1.2. Identificar queries lentas:**
Liste as 5-10 medidas mais críticas/usadas.

**1.3. Medir performance atual:**
Para cada medida:
```json
{
  "operation": "Execute",
  "query": "EVALUATE ROW(\"Result\", [Nome da Medida])",
  "getExecutionMetrics": true,
  "executionMetricsOnly": true
}
```

**Capture:**
- Duration (total time)
- SE Time (Storage Engine)
- FE Time (Formula Engine)
- SE/FE Ratio

### 2. Classificar Problemas (performance-optimizer)

**2.1. Performance de Query:**
- Duration > 5s: CRÍTICO ❌
- Duration 1-5s: ALTO ⚠️
- Duration 0.5-1s: MÉDIO 📝
- Duration < 0.5s: BOM ✅

**2.2. SE vs FE:**
- FE > SE: Problema DAX (otimizar medida)
- SE >> FE: Problema modelo (colunas, tabelas)
- Ambos lentos: Problema fundamental (dados, hardware)

**2.3. Tamanho de Modelo:**
- < 500MB: Excelente ✅
- 500MB - 2GB: Aceitável 📝
- 2GB - 5GB: Alto ⚠️
- > 5GB: Crítico ❌

### 3. Otimizar DAX (dax-specialist)

**Para medidas com FE > SE:**

**3.1. Identificar problemas comuns:**
- [ ] Usa FILTER(ALL(...)) em tabelas grandes?
- [ ] Cálculos repetidos sem variáveis?
- [ ] Iteradores quando agregadores serviriam?
- [ ] Divisão sem DIVIDE?
- [ ] Muitas chamadas aninhadas?

**3.2. Aplicar otimizações:**

**Remover FILTER(ALL(...)):**
```dax
// ANTES (LENTO)
Category Sales = 
CALCULATE(
    [Total Sales],
    FILTER(ALL(DimProduct), DimProduct[Category] = "Electronics")
)

// DEPOIS (RÁPIDO)
Category Sales = 
CALCULATE(
    [Total Sales],
    DimProduct[Category] = "Electronics"
)
```

**Adicionar variáveis:**
```dax
// ANTES (LENTO - calcula [Sales PY] 2x)
Growth = DIVIDE([Sales] - [Sales PY], [Sales PY])

// DEPOIS (RÁPIDO - calcula 1x)
Growth = 
VAR Current = [Sales]
VAR Previous = [Sales PY]
RETURN DIVIDE(Current - Previous, Previous)
```

**Trocar iterador por agregador:**
```dax
// ANTES (LENTO)
Total = SUMX(Sales, Sales[Amount])

// DEPOIS (RÁPIDO - se possível)
Total = SUM(Sales[Amount])
```

### 4. Otimizar Modelo (data-modeler)

**Para modelos grandes (>1GB):**

**4.1. Identificar colunas de alta cardinalidade:**
```dax
// Criar medida temporária para testar
Column Cardinality = 
DIVIDE(
    DISTINCTCOUNT(Table[Column]),
    COUNTROWS(Table)
)
// Resultado > 0.9 = muito alta
```

**4.2. Remover colunas não usadas:**
```json
{
  "operation": "Delete",
  "tableName": "DimProduct",
  "columnName": "UnusedColumn"
}
```

**4.3. Otimizar data types:**
- Text → Integer (chaves numéricas)
- DateTime → Date (se hora não necessária)
- Decimal → Fixed Decimal
- High precision → Lower precision

**4.4. Eliminar colunas calculadas desnecessárias:**
```json
{
  "operation": "List",
  "tableName": "DimProduct"
}
```

Para cada calculated column:
- Pode ser medida? → Converta
- Pode ser Power Query? → Mova
- Realmente necessária? → Delete

### 5. Otimizar Relacionamentos (relationship-architect)

**5.1. Verificar bidirectional:**
```json
{
  "operation": "List"
}
```

Para cada bidirectional:
- Realmente necessário?
- Pode substituir por DAX?

```json
{
  "operation": "Update",
  "relationshipName": "...",
  "relationshipUpdate": {
    "crossFilteringBehavior": "OneDirection"
  }
}
```

**5.2. Verificar many-to-many:**
- Pode usar bridge table?
- Impacto na performance justifica?

### 6. Comprimir Modelo (data-modeler)

**6.1. Para colunas de texto longas:**
Considere criar surrogates keys numéricas.

**6.2. Para datas com timestamp:**
Separe Date (comprime bem) de Time (comprime mal).

**6.3. Para colunas esparsas:**
Considere preencher NULLs com valores default.

### 7. Re-testar Performance

**7.1. Obter novas estatísticas:**
```json
{
  "operation": "GetStats"
}
```

**7.2. Re-executar queries:**
```json
{
  "operation": "Execute",
  "query": "EVALUATE ROW(\"Result\", [Medida Otimizada])",
  "getExecutionMetrics": true
}
```

**7.3. Comparar:**
```markdown
| Medida | Antes | Depois | Melhoria |
|--------|-------|--------|----------|
| Total Sales | 5.2s | 0.8s | 6.5x ✅ |
| Growth % | 3.1s | 0.5s | 6.2x ✅ |
```

### 8. Documentar Otimizações (documentation-expert)

**8.1. Criar relatório:**
```markdown
# Relatório de Otimização

**Data:** 2025-02-05
**Modelo:** vendas-v3

## Baseline
- Tamanho: 2.5 GB
- Medidas lentas: 8
- Tempo médio: 4.2s

## Otimizações Aplicadas
1. Removidas 15 colunas não usadas (-300MB)
2. Convertidas 5 calculated columns em medidas (-150MB)
3. Refatoradas 8 medidas com variáveis
4. Removido 1 relacionamento bidirectional

## Resultados
- Novo tamanho: 2.0 GB (-20%)
- Tempo médio: 0.6s (-86%)
- Maior melhoria: 8.5x em "Complex Growth"

## Medidas Otimizadas
- Total Sales: 5.2s → 0.8s
- Growth %: 3.1s → 0.5s
...
```

**8.2. Atualizar annotations nas medidas otimizadas:**
```json
{
  "operation": "Update",
  "measureName": "Total Sales",
  "updateDefinition": {
    "annotations": [
      {"key": "Optimized", "value": "true"},
      {"key": "OptimizationDate", "value": "2025-02-05"},
      {"key": "ImprovementFactor", "value": "6.5x"}
    ]
  }
}
```

### 9. Validar Qualidade (quality-validator)

Após otimizações, garantir que:
- [ ] Resultados de medidas ainda corretos?
- [ ] Relacionamentos funcionando?
- [ ] Sem quebra de relatórios?

Execute audit completo para confirmar.

### 10. Estabelecer Monitoramento

**10.1. Definir thresholds:**
```markdown
Limites aceitáveis:
- Query duration: < 1s
- Model size: < 2GB
- SE/FE ratio: > 3:1
```

**10.2. Agendar revisões:**
- Mensal: Revisar tamanho do modelo
- Trimestral: Re-testar medidas críticas
- Após mudanças: Validar performance

## Checklist Final

### Diagnóstico
- [ ] Baseline estabelecido
- [ ] Queries lentas identificadas
- [ ] Problemas classificados
- [ ] Métricas capturadas

### Otimização DAX
- [ ] FILTER(ALL(...)) removidos
- [ ] Variáveis adicionadas
- [ ] Agregadores em vez de iteradores
- [ ] DIVIDE usado

### Otimização Modelo
- [ ] Colunas não usadas removidas
- [ ] Data types otimizados
- [ ] Calculated columns minimizadas
- [ ] Alta cardinalidade tratada

### Validação
- [ ] Performance testada novamente
- [ ] Melhoria medida
- [ ] Qualidade validada
- [ ] Resultados consistentes

### Documentação
- [ ] Relatório criado
- [ ] Annotations atualizadas
- [ ] Thresholds definidos

## Tabela de Quick Wins

| Problema | Solução Rápida | Ganho Esperado |
|----------|----------------|----------------|
| FILTER(ALL(...)) | Remover, usar filtro direto | 5-10x |
| Cálculos repetidos | Adicionar VAR | 2-3x |
| SUMX desnecessário | Trocar por SUM | 3-5x |
| Calculated columns | Converter em measures | 20-30% tamanho |
| Colunas não usadas | Deletar | 10-20% tamanho |
| Bidirectional | Trocar por Single | 10-30% queries |

## Dicas Avançadas

**Para modelos muito grandes (>5GB):**
- Considere incremental refresh
- Avalie partitioning
- Revise data retention policy

**Para queries muito complexas:**
- Quebre em medidas helper
- Use calculation groups
- Considere aggregations

**Quando tudo falha:**
- Revise design do modelo (talvez precise reestruturação)
- Considere pré-agregação na fonte
- Avalie hardware (RAM, CPU)

---

**Tempo estimado:** 30-90 minutos
**Ganho típico:** 3-10x em queries, 10-30% em tamanho
