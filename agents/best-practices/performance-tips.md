# Performance Tips - Power BI Best Practices

Dicas de performance para modelos e queries DAX em Power BI.

## Métricas de Performance

### Storage Engine (SE) vs Formula Engine (FE)

**Storage Engine (SE)**:
- Processa queries no cache VertiPaq
- Multi-threaded (paralelo)
- Muito rápido
- ✅ Queremos maximizar

**Formula Engine (FE)**:
- Executa cálculos DAX
- Single-threaded (sequencial)
- Mais lento
- ❌ Queremos minimizar

**Proporção Ideal**: SE fazendo 90%+ do trabalho

### Targets de Performance

| Métrica | Excelente | Aceitável | Problemático |
|---------|-----------|-----------|--------------|
| Query Duration | <500ms | <2s | >5s |
| Model Size | <500MB | <2GB | >5GB |
| Refresh Time | <5min | <30min | >1h |
| SE/FE Ratio | >10:1 | >3:1 | <1:1 |

## Otimizações de DAX

### Alta Prioridade

#### 1. Evite FILTER(ALL(...)) em Tabelas Grandes

❌ **MUITO LENTO**:
```dax
Category Sales = 
CALCULATE(
    [Total Sales],
    FILTER(ALL(DimProduct), DimProduct[Category] = "Electronics")
)
```

✅ **MUITO RÁPIDO**:
```dax
Category Sales = 
CALCULATE(
    [Total Sales],
    DimProduct[Category] = "Electronics"
)
```

**Por quê?** FILTER(ALL(...)) materializa toda a tabela no FE.

#### 2. Use Variáveis para Cálculos Repetidos

❌ **LENTO** (calcula [Sales PY] duas vezes):
```dax
Growth = DIVIDE([Total Sales] - [Sales PY], [Sales PY])
```

✅ **RÁPIDO** (calcula uma vez):
```dax
Growth = 
VAR Current = [Total Sales]
VAR Previous = [Sales PY]
RETURN DIVIDE(Current - Previous, Previous)
```

#### 3. Prefira Agregadores a Iteradores

❌ **LENTO** (row-by-row no FE):
```dax
Total = SUMX(FactSales, FactSales[Amount])
```

✅ **RÁPIDO** (agregação no SE):
```dax
Total = SUM(FactSales[Amount])
```

**Use iteradores apenas quando necessário** (cálculos linha a linha).

### Média Prioridade

#### 4. Cuidado com DISTINCTCOUNT

DISTINCTCOUNT pode ser lento em colunas de alta cardinalidade.

**Alternativas**:
- Use COUNTROWS(VALUES(...)) em alguns casos
- Considere pré-agregação

#### 5. Minimize Conversões de Tipo

Evite comparar tipos diferentes:
```dax
-- LENTO (conversão implícita)
FILTER(Sales, Sales[DateText] = "2024-01-01")

-- RÁPIDO (tipos iguais)
FILTER(Sales, Sales[Date] = DATE(2024, 1, 1))
```

#### 6. Use TREATAS em vez de FILTER para Virtual Relationships

✅ **MELHOR**:
```dax
CALCULATE(
    [Measure],
    TREATAS(VALUES(Table1[Column]), Table2[Column])
)
```

## Otimizações de Modelo

### Alta Prioridade

#### 1. Remova Colunas Não Utilizadas

Cada coluna consome memória. No Power Query:
- Selecione apenas colunas necessárias
- Delete colunas que não serão usadas

**Impacto**: Pode reduzir tamanho em 20-50%

#### 2. Use Data Types Corretos

| Tipo Usado | Tipo Ideal | Compressão |
|------------|------------|------------|
| Text "12345" | Integer 12345 | 10-20x melhor |
| Decimal Precision | Fixed Decimal | 2x melhor |
| DateTime | Date only | 2x melhor |

#### 3. Minimize Calculated Columns

Calculated columns:
- Ocupam memória permanente
- Recalculam em cada refresh
- Não se beneficiam de lazy evaluation

**Substitua por**:
- Colunas no Power Query (preferível)
- Medidas (quando agregação)

#### 4. Reduza Cardinalidade

Alta cardinalidade = má compressão.

**Estratégias**:
- Remova timestamps desnecessários (use só Date)
- Agrupe valores raros em "Outros"
- Use IDs numéricos em vez de texto

**Verificar cardinalidade**:
```dax
Cardinality Check = 
DIVIDE(
    DISTINCTCOUNT(Table[Column]),
    COUNTROWS(Table)
)
-- > 0.9 = muito alta!
```

### Média Prioridade

#### 5. Minimize Bidirectional Relationships

Problemas:
- Caminhos de filtro ambíguos
- Performance degradada
- Resultados inesperados

**Alternativa DAX**:
```dax
Products with Sales = 
CALCULATE(
    DISTINCTCOUNT(DimProduct[ProductKey]),
    FactSales
)
```

#### 6. Evite Many-to-Many (M:N)

Use bridge tables quando possível:
```
DimA (1) → BridgeAB (N) ← (1) DimB
```

#### 7. Limite Snowflake Depth

Máximo 2 níveis de snowflake:
```
DimSubcategory → DimCategory → [STOP]
```

Mais que isso: desnormalize.

## Query Folding (Power Query)

### O que é?

Query folding = Power Query envia transformações para a fonte.

**Com folding**: Fonte filtra/processa → dados reduzidos → Power BI
**Sem folding**: Todos dados → Power BI → processa localmente

### Operações que Mantêm Folding

✅ Mantêm:
- Remove Columns
- Filter Rows
- Sort
- Rename Columns
- Change Type
- Group By
- Merge/Join (geralmente)

### Operações que Quebram Folding

❌ Quebram:
- Custom columns com M complexo
- Algunso pivots
- Transformações de texto complexas
- Funções não-nativas

### Como Verificar

No Power Query Editor:
1. Right-click no step
2. "View Native Query"
3. Se mostra SQL = folding ✅
4. Se erro/greyed out = no folding ❌

**Dica**: Faça transformações complexas como Views no banco.

## Refresh Performance

### Incremental Refresh

Para tabelas grandes (>1M rows):
- Importa apenas dados novos/alterados
- Mantém histórico sem reprocessar

**Configuração típica**:
- Keep: 5 anos
- Refresh: últimos 10 dias

### Partitioning

Dividir tabelas grandes em partições:
- Por mês/ano
- Refresh só partições alteradas
- Refresh paralelo possível

## Monitoramento

### DAX Query Metrics

Use `dax_query_operations` com `GetExecutionMetrics: true`:
- Duration
- SE Time vs FE Time
- Rows Scanned
- Cache Hits

### Model Statistics

Use `model_operations: GetStats`:
- Table sizes
- Row counts
- Column cardinality
- Relationship count

## Diagnóstico de Problemas

### Query Lenta

1. **Capture métricas** (GetExecutionMetrics)
2. **Identifique gargalo**:
   - FE > SE? → Problema DAX
   - SE lento? → Problema modelo
   - Ambos? → Problema fundamental

3. **Priorize fixes** por impacto

### Modelo Grande

1. **Identifique tabelas maiores** (GetStats)
2. **Verifique colunas de alta cardinalidade**
3. **Remova colunas não usadas**
4. **Revise calculated columns**

### Refresh Lento

1. **Verifique query folding**
2. **Considere incremental refresh**
3. **Otimize queries na fonte**
4. **Reduza transformações em M**

## Checklist de Performance

### Antes de Publicar

#### DAX
- [ ] Sem FILTER(ALL(...)) em tabelas grandes?
- [ ] Variáveis usadas para cálculos repetidos?
- [ ] Agregadores em vez de iteradores?
- [ ] DIVIDE em vez de divisão direta?

#### Modelo
- [ ] Apenas colunas necessárias?
- [ ] Data types otimizados?
- [ ] Minimal calculated columns?
- [ ] Sem bidirectional desnecessário?
- [ ] Cardinality sob controle?

#### Refresh
- [ ] Query folding funcionando?
- [ ] Incremental refresh configurado?
- [ ] Partitioning se >10M rows?

## Benchmarks de Referência

### Tamanho de Modelo (Compressed)

| Rows | Size Esperado |
|------|---------------|
| 1M | 10-50 MB |
| 10M | 100-500 MB |
| 100M | 1-5 GB |

Se muito maior: investigar colunas de alta cardinalidade.

### Tempo de Query

| Complexidade | Target |
|--------------|--------|
| Medida simples | <100ms |
| Time intelligence | <300ms |
| Ranking/TopN | <500ms |
| Cálculo complexo | <1s |

Se muito maior: investigar DAX ou modelo.

---

**Lembre-se**: Performance é um processo contínuo. Meça, identifique, otimize, repita.
