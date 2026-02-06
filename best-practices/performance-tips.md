# Dicas de Performance - Power BI

Guia prático para otimizar performance de modelos e consultas DAX.

---

## Princípios de Performance

### A Regra Fundamental
> **Meça antes de otimizar**

Use ferramentas para identificar gargalos:
- **Performance Analyzer** (Power BI Desktop)
- **DAX Studio** (análise detalhada de queries)
- **Tabular Editor** (estatísticas de modelo)

---

## DAX Performance

### 1. Use Variáveis
Variáveis eliminam cálculos redundantes e melhoram legibilidade.

❌ **LENTO** (calcula Sales PY 3 vezes):
```dax
Growth = 
DIVIDE(
    [Total Sales] - CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date])),
    CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date]))
)
```

✅ **RÁPIDO** (calcula 1 vez):
```dax
Growth = 
VAR Current = [Total Sales]
VAR Previous = CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date]))
RETURN DIVIDE(Current - Previous, Previous)
```

### 2. Prefira Agregadores a Iteradores

❌ **LENTO**:
```dax
Total = SUMX(Sales, Sales[Amount])
```

✅ **RÁPIDO**:
```dax
Total = SUM(Sales[Amount])
```

**Quando usar iteradores:**
- Apenas quando cálculo linha-a-linha é necessário
- Exemplo: `SUMX(Sales, Sales[Quantity] * Sales[Price])`

### 3. Evite FILTER sobre ALL

❌ **MUITO LENTO**:
```dax
Electronics Sales = 
CALCULATE(
    [Total Sales],
    FILTER(ALL(Product), Product[Category] = "Electronics")
)
```

✅ **MUITO RÁPIDO**:
```dax
Electronics Sales = 
CALCULATE(
    [Total Sales],
    Product[Category] = "Electronics"
)
```

### 4. Use KEEPFILTERS quando Apropriado

```dax
Safe Filter = 
CALCULATE(
    [Total Sales],
    KEEPFILTERS(Product[Category] = "Electronics")
)
```

### 5. Minimize Uso de Colunas Calculadas

❌ **PREFIRA EVITAR** (ocupa memória):
```dax
// Calculated Column
Profit = Sales[Revenue] - Sales[Cost]
```

✅ **MELHOR** (calculado em query time):
```dax
// Measure
Total Profit = SUM(Sales[Revenue]) - SUM(Sales[Cost])
```

**Quando usar Calculated Columns:**
- Categorização/Agrupamento fixo
- Sort By em dimensões
- Quando valor não varia com contexto

### 6. Evite Funções Caras

**Funções Lentas:**
- `FILTER(ALL(...))` sobre tabelas grandes
- `EARLIER()` (legado, use variáveis)
- `CALCULATE()` excessivamente aninhado

**Funções Rápidas:**
- `SUM`, `COUNT`, `MIN`, `MAX`
- `VALUES`, `DISTINCT`
- `CALCULATE` com filtros diretos

---

## Modelagem para Performance

### 1. Reduza Cardinalidade

**Cardinalidade** = número de valores únicos em uma coluna.

❌ **ALTA cardinalidade** (compressão ruim):
```
TransactionID: 10.000.000 linhas, 10.000.000 valores únicos
```

✅ **BAIXA cardinalidade** (compressão ótima):
```
Category: 10.000.000 linhas, 5 valores únicos
```

**Dicas:**
- Remova colunas de ID quando não necessárias
- Agrupe valores raros em "Others"
- Use Date em vez de DateTime quando hora não importa

### 2. Escolha Tipos de Dados Corretos

**Ordem de eficiência (menor → maior):**
1. **Integer** (mais eficiente)
2. **Decimal/Currency**
3. **Boolean**
4. **Date**
5. **String** (menos eficiente)

❌ **RUIM**:
```
OrderID: Text "ORD-00001"
Amount: Text "1234.56"
Date: Text "2024-01-15"
```

✅ **BOM**:
```
OrderID: Integer 1
Amount: Currency 1234.56
Date: Date 2024-01-15
```

### 3. Remova Colunas Não Usadas

Cada coluna, mesmo não usada em relatórios:
- Ocupa memória
- É carregada no refresh
- Afeta compressão

**No Power Query:**
```m
// Remove colunas desnecessárias
= Table.SelectColumns(Source, {"Column1", "Column2", "Column3"})
```

### 4. Evite Relacionamentos Bidirecionais

❌ **LENTO** (ambiguidade, caminhos múltiplos):
```
DimProduct <─────> FactSales
```

✅ **RÁPIDO** (caminho único e claro):
```
DimProduct ──────> FactSales
```

**Quando bidirecional é necessário:**
- Use com moderação
- Teste impacto na performance
- Considere alternativas DAX:
```dax
// Em vez de bidirecional
Products with Sales = 
CALCULATE(
    DISTINCTCOUNT(Product[ProductKey]),
    FactSales
)
```

### 5. Use Import Mode (quando possível)

**Import Mode:**
- Dados em memória (muito rápido)
- Compressão VertiPaq (10-20x menor)
- Todas as funções DAX disponíveis

**DirectQuery Mode:**
- Consulta banco de dados em tempo real (mais lento)
- Dados sempre atualizados
- Limitações em DAX

**Composite Models:**
- Melhor dos dois mundos
- Dimensões em Import, Fatos em DirectQuery
- Agregações para acelerar

---

## Storage Engine vs Formula Engine

### Storage Engine (SE)
- Extremamente rápido (paralelo, comprimido)
- Queries SQL-like em VertiPaq
- **Objetivo**: Maximize uso do SE

### Formula Engine (FE)
- Mais lento (single-threaded)
- Processa DAX complexo
- **Objetivo**: Minimize uso do FE

### Como Identificar (DAX Studio)

**Bom** (SE doing heavy work):
```
SE CPU Time: 1200ms
FE CPU Time: 50ms
```

**Ruim** (FE doing heavy work):
```
SE CPU Time: 50ms
FE CPU Time: 5000ms
```

### Otimizar para SE

✅ **SE-friendly:**
- Filtros simples
- Agregações básicas
- JOINs (relacionamentos)

❌ **Força FE:**
- `FILTER()` com lógica complexa
- Iteradores sobre tabelas grandes
- Cálculos linha-a-linha

---

## Query Folding (Power Query)

### Conceito
**Query Folding** = transformações executadas no banco de origem (não no Power BI).

### Vantagens
- Muito mais rápido
- Aproveita índices do banco
- Menos memória no Power BI

### Identificar Folding

**Power Query Editor:**
- Right-click no step → "View Native Query"
- Se mostrar SQL = folding OK ✅
- Se mostrar erro = folding quebrado ❌

### Operações que Mantêm Folding
✅ Filtros simples
✅ Select columns
✅ Sort
✅ Join/Merge
✅ Group By
✅ Aggregate

### Operações que Quebram Folding
❌ Adicionar colunas personalizadas (M code)
❌ Funções específicas do Power Query
❌ Transformações complexas

**Dica:** Faça transformações complexas no banco (view SQL).

---

## Agregações (Aggregations)

### Conceito
Tabela pré-agregada que acelera queries de alto nível.

### Exemplo
```
FactSales (detalhe)
├─ 100 milhões de linhas
└─ Muito lento para totais anuais

AggSales (agregada)
├─ 10 mil linhas (por dia-produto)
└─ Muito rápido para totais anuais!
```

### Configuração
1. Criar tabela agregada no Power Query
2. Ocultar tabela agregada do usuário
3. Configurar aggregation settings no Power BI
4. Power BI usa automaticamente quando possível

**Ganho típico:** 10-100x mais rápido em queries agregadas

---

## Particionamento

### Conceito
Dividir tabelas grandes em "fatias" menores.

### Benefícios
- Refresh mais rápido (apenas partições alteradas)
- Melhor gerenciamento de dados históricos
- Possível paralelização

### Exemplo: Partições por Mês
```
FactSales_2024_01
FactSales_2024_02
FactSales_2024_03
...
```

**Requer:** Premium capacity ou XMLA endpoint

---

## Incremental Refresh

### Conceito
Refresh apenas dados novos/alterados, mantém histórico.

### Configuração
1. Parâmetros `RangeStart` e `RangeEnd` no Power Query
2. Filtrar dados usando parâmetros
3. Configurar política de refresh incremental
4. Publicar no serviço

### Exemplo
```
Manter: 5 anos de dados
Refresh: últimos 10 dias
```

**Resultado:** Refresh de minutos em vez de horas!

---

## Dicas de Visualização

### 1. Limite Visuais por Página
- **Máximo recomendado**: 10-15 visuais
- Cada visual = query ao modelo
- Muitos visuais = página lenta

### 2. Evite Tabelas com Muitas Linhas
- Tabelas com 1000+ linhas são lentas
- Use visuais agregados
- Aplique filtros ou TopN

### 3. Use Slicers com Cuidado
- Cada slicer = query adicional
- Use dropdown em vez de list quando possível
- Considere sync slicers (Premium)

### 4. Desabilite Auto Date/Time
- **Configuração**: Options → Data Load → Auto Date/Time → OFF
- Cria tabelas ocultas para cada coluna de data
- Aumenta tamanho do modelo desnecessariamente
- **Use sua própria tabela de datas!**

---

## Compressão VertiPaq

### Como VertiPaq Funciona
- Compressão colunar (não linha)
- Dictionary encoding para baixa cardinalidade
- Run-length encoding para valores repetidos

### Otimizar Compressão

✅ **Maximize valores repetidos:**
```
Category: [A, A, A, B, B, B, C, C, C]
Compressão: Excelente
```

❌ **Minimize valores únicos:**
```
TransactionID: [1, 2, 3, 4, 5, 6, 7, 8, 9]
Compressão: Ruim
```

### Dicas
- Normalize texto (mesmo case, trim)
- Remova espaços desnecessários
- Use códigos/IDs em vez de textos longos
- Ordene dados antes de importar (melhor run-length)

---

## Refresh Performance

### 1. Refresh em Paralelo
- Power Query pode processar queries em paralelo
- **Configuração**: Options → Global → Data Load → Max parallel queries
- Padrão: 6 (aumente se servidor suportar)

### 2. Desabilite Refresh para Tabelas Estáticas
- Dimensões que não mudam (ex: DimDate)
- Right-click table → Disable refresh

### 3. Use Dataflows (Power BI Service)
- Refresh de dados centralizado
- Reuso entre múltiplos datasets
- Refresh pode ser agendado independentemente

---

## Monitoramento e Análise

### Ferramentas Essenciais

#### 1. Performance Analyzer (Power BI Desktop)
- View → Performance Analyzer
- Mostra tempo de cada visual
- Identifica visuais lentos

#### 2. DAX Studio (Externo)
- Análise detalhada de queries DAX
- SE vs FE metrics
- Query plans
- Server timings

**Download:** https://daxstudio.org/

#### 3. Tabular Editor 2 (Externo)
- Estatísticas de modelo
- Tamanho de tabelas/colunas
- Cardinalidade
- Best Practices Analyzer

**Download:** https://tabulareditor.com/

---

## Métricas Importantes

### Modelo
- **Tamanho total**: Quanto menor, melhor
- **Cardinalidade**: Baixa é melhor
- **Número de colunas**: Apenas necessárias

### Queries
- **SE CPU Time**: Quanto mais, melhor (trabalho em SE)
- **FE CPU Time**: Quanto menos, melhor (trabalho em FE)
- **Duration**: Tempo total (< 1s = bom)

### Refresh
- **Tempo total**: Quanto menor, melhor
- **Memória usada**: Pico de uso durante refresh

---

## Checklist de Otimização

**Modelagem:**
- [ ] Apenas colunas necessárias
- [ ] Tipos de dados otimizados
- [ ] Cardinalidade minimizada
- [ ] Relacionamentos single-direction
- [ ] Import mode quando possível
- [ ] Auto Date/Time desabilitado

**DAX:**
- [ ] Variáveis para valores reutilizados
- [ ] Agregadores em vez de iteradores
- [ ] DIVIDE em vez de `/`
- [ ] Evitar FILTER(ALL(...))
- [ ] Medidas em vez de calculated columns

**Power Query:**
- [ ] Query folding mantido
- [ ] Transformações no banco quando possível
- [ ] Colunas removidas early
- [ ] Tipos de dados definidos

**Visuais:**
- [ ] Máximo 10-15 por página
- [ ] Tabelas com poucas linhas
- [ ] Filtros aplicados

**Avançado:**
- [ ] Agregações configuradas (se aplicável)
- [ ] Incremental refresh (se aplicável)
- [ ] Particionamento (Premium)

---

## Anti-Padrões de Performance

❌ **Evite:**
1. Calculated columns quando measures servem
2. Bi-directional relationships desnecessários
3. FILTER(ALL(...)) em tabelas grandes
4. Múltiplos CALCULATE aninhados sem necessidade
5. Importar colunas "por via das dúvidas"
6. DateTime quando apenas Date é necessário
7. Text em vez de Integer/Date
8. Tabelas desnormalizadas em excesso (redundância extrema)
9. Muitos visuais por página
10. Slicers sem necessidade

---

## Metas de Performance

### Excelente
- Tempo de refresh: < 5 min
- Tamanho do modelo: < 500 MB
- Query duration: < 500ms
- Visuais carregam: < 1s

### Aceitável
- Tempo de refresh: < 30 min
- Tamanho do modelo: < 2 GB
- Query duration: < 2s
- Visuais carregam: < 3s

### Problemas
- Tempo de refresh: > 1h
- Tamanho do modelo: > 5 GB
- Query duration: > 5s
- Visuais carregam: > 5s

---

## Recursos

- **DAX Studio**: Análise de performance
- **Tabular Editor**: Otimização de modelo
- **SQLBI Articles**: Performance best practices
- **Power BI Performance Best Practices** (Microsoft Docs)
