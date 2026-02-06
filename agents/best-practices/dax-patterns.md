# DAX Patterns - Power BI Best Practices

Padrões DAX comprovados para medidas eficientes e manuteníveis.

## Princípios Fundamentais

### 1. Sempre Use Variáveis
Variáveis (VAR) melhoram:
- **Performance**: Calcular uma vez, usar várias vezes
- **Legibilidade**: Nomes descritivos intermediários
- **Debugging**: Facilita isolamento de problemas

✅ **BOM:**
```dax
Sales Growth % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = CurrentSales - PreviousSales
VAR GrowthPct = DIVIDE(Growth, PreviousSales)
RETURN GrowthPct
```

❌ **RUIM:**
```dax
Sales Growth % = 
DIVIDE(
    [Total Sales] - [Sales PY],
    [Sales PY]
)
-- Calcula [Sales PY] duas vezes!
```

### 2. Prefira Agregadores a Iteradores

**Agregadores** (SUM, COUNT, AVERAGE) são mais rápidos porque o Storage Engine faz o trabalho.

**Iteradores** (SUMX, COUNTX, AVERAGEX) processam linha a linha no Formula Engine.

✅ **RÁPIDO:**
```dax
Total Sales = SUM(FactSales[SalesAmount])
```

❌ **LENTO:**
```dax
Total Sales = SUMX(FactSales, FactSales[SalesAmount])
```

**Use iteradores apenas quando necessário:**
```dax
Revenue = SUMX(FactSales, FactSales[Quantity] * FactSales[UnitPrice])
```

### 3. Use DIVIDE, Nunca `/`

DIVIDE trata divisão por zero automaticamente.

✅ **SEGURO:**
```dax
Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0)
```

❌ **ARRISCADO:**
```dax
Profit Margin % = [Total Profit] / [Total Revenue]
-- Erro se [Total Revenue] = 0!
```

### 4. Evite FILTER(ALL(...)) em Tabelas Grandes

Este é um dos piores anti-patterns de performance.

❌ **MUITO LENTO:**
```dax
Electronics Sales = 
CALCULATE(
    [Total Sales],
    FILTER(
        ALL(DimProduct),
        DimProduct[Category] = "Electronics"
    )
)
```

✅ **MUITO RÁPIDO:**
```dax
Electronics Sales = 
CALCULATE(
    [Total Sales],
    DimProduct[Category] = "Electronics"
)
```

## Padrões de Time Intelligence

### Configuração Prévia
Time intelligence requer uma Date Table marcada:
- Coluna de datas contínua
- Marcada como Date Table
- Relacionada à tabela fato

### Year-to-Date (YTD)
```dax
Sales YTD = 
TOTALYTD([Total Sales], DimDate[Date])
```

### Month-to-Date (MTD)
```dax
Sales MTD = 
TOTALMTD([Total Sales], DimDate[Date])
```

### Quarter-to-Date (QTD)
```dax
Sales QTD = 
TOTALQTD([Total Sales], DimDate[Date])
```

### Prior Year (Ano Anterior)
```dax
Sales PY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```

### Prior Month (Mês Anterior)
```dax
Sales PM = 
CALCULATE(
    [Total Sales],
    DATEADD(DimDate[Date], -1, MONTH)
)
```

### Year-over-Year Growth
```dax
YoY Growth % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
RETURN
DIVIDE(
    CurrentSales - PreviousSales,
    PreviousSales
)
```

### YTD do Ano Anterior
```dax
Sales PY YTD = 
CALCULATE(
    [Sales YTD],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```

## Padrões de Percentual

### % do Total Geral
```dax
Sales % of Grand Total = 
DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], ALL(FactSales))
)
```

### % da Categoria
```dax
Sales % of Category = 
DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], ALLEXCEPT(DimProduct, DimProduct[Category]))
)
```

### % de Linha por Coluna
```dax
Sales % Row = 
DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], ALLSELECTED(DimProduct))
)
```

## Padrões de Ranking

### Ranking Básico
```dax
Product Rank = 
RANKX(
    ALL(DimProduct[ProductName]),
    [Total Sales],
    ,
    DESC,
    DENSE
)
```

Opções de ranking:
- `SKIP`: Pula números após empates (1, 2, 2, 4)
- `DENSE`: Números contínuos (1, 2, 2, 3)

### Top N com "Outros"
```dax
Top 10 Product = 
IF(
    [Product Rank] <= 10,
    SELECTEDVALUE(DimProduct[ProductName]),
    "Others"
)
```

### Dynamic Top N
```dax
Sales Top N = 
VAR TopN = SELECTEDVALUE(ParamTopN[Value], 10)
RETURN
CALCULATE(
    [Total Sales],
    TOPN(TopN, ALL(DimProduct[ProductName]), [Total Sales])
)
```

## Padrões de Running Total

### Running Total Simples
```dax
Running Total Sales = 
VAR CurrentDate = MAX(DimDate[Date])
RETURN
CALCULATE(
    [Total Sales],
    DimDate[Date] <= CurrentDate,
    ALL(DimDate)
)
```

### Running Total que Reinicia por Ano
```dax
Running Total by Year = 
VAR CurrentDate = MAX(DimDate[Date])
VAR CurrentYear = YEAR(CurrentDate)
RETURN
CALCULATE(
    [Total Sales],
    DimDate[Date] <= CurrentDate,
    YEAR(DimDate[Date]) = CurrentYear,
    ALL(DimDate)
)
```

## Padrões de Média Móvel

### Média Móvel de 3 Meses
```dax
Sales 3M Avg = 
AVERAGEX(
    DATESINPERIOD(
        DimDate[Date],
        MAX(DimDate[Date]),
        -3,
        MONTH
    ),
    [Total Sales]
)
```

### Média Móvel de N Dias
```dax
Sales Moving Avg = 
VAR Days = 30
RETURN
CALCULATE(
    AVERAGEX(
        DATESINPERIOD(DimDate[Date], MAX(DimDate[Date]), -Days, DAY),
        [Total Sales]
    )
)
```

## Padrões de ABC Classification

### Classificação ABC
```dax
ABC Class = 
VAR CurrentRank = [Product Rank]
VAR TotalProducts = CALCULATE(
    DISTINCTCOUNT(DimProduct[ProductKey]),
    ALL(DimProduct)
)
VAR ClassA = TotalProducts * 0.2  -- Top 20%
VAR ClassB = TotalProducts * 0.5  -- Next 30%
RETURN
SWITCH(
    TRUE(),
    CurrentRank <= ClassA, "A",
    CurrentRank <= ClassB, "B",
    "C"
)
```

### % Cumulativo para Pareto
```dax
Cumulative % = 
VAR CurrentProduct = SELECTEDVALUE(DimProduct[ProductKey])
VAR CurrentSales = [Total Sales]
VAR TotalSales = CALCULATE([Total Sales], ALL(DimProduct))
VAR RankedProducts = 
    FILTER(
        ALL(DimProduct[ProductKey]),
        [Total Sales] >= CurrentSales
    )
VAR CumulativeSales = 
    CALCULATE([Total Sales], RankedProducts)
RETURN
DIVIDE(CumulativeSales, TotalSales)
```

## Padrões de USERELATIONSHIP

Para dimensões Role-Playing (mesma dimensão usada de formas diferentes):

```dax
Sales by Ship Date = 
CALCULATE(
    [Total Sales],
    USERELATIONSHIP(FactSales[ShipDate], DimDate[Date])
)
```

```dax
Sales by Due Date = 
CALCULATE(
    [Total Sales],
    USERELATIONSHIP(FactSales[DueDate], DimDate[Date])
)
```

## Padrões de KPI

### Target Achievement %
```dax
Target Achievement % = 
DIVIDE([Total Sales], [Sales Target])
```

### Variance vs Target
```dax
Variance vs Target = 
[Total Sales] - [Sales Target]
```

### KPI Status (Semáforo)
```dax
KPI Status = 
VAR Achievement = [Target Achievement %]
RETURN
SWITCH(
    TRUE(),
    Achievement >= 1, "🟢",      -- Verde: 100%+
    Achievement >= 0.8, "🟡",    -- Amarelo: 80-99%
    "🔴"                          -- Vermelho: <80%
)
```

## Tratamento de Blanks

### Substituir Blank por Zero
```dax
Sales No Blank = 
IF(ISBLANK([Total Sales]), 0, [Total Sales])
```

### Usar COALESCE (mais elegante)
```dax
Sales No Blank = 
COALESCE([Total Sales], 0)
```

### Retornar Blank se Sem Dados
```dax
Average Sales = 
IF(
    COUNTROWS(FactSales) = 0,
    BLANK(),
    AVERAGE(FactSales[SalesAmount])
)
```

## Performance Checklist

Antes de criar qualquer medida, verifique:

- [ ] Usei variáveis para cálculos repetidos?
- [ ] Usei agregador ao invés de iterador quando possível?
- [ ] Usei DIVIDE ao invés de `/`?
- [ ] Evitei FILTER(ALL(...)) em tabelas grandes?
- [ ] O código está legível e bem formatado?
- [ ] Adicionei comentários explicando a lógica?
- [ ] Testei com dados reais?

## Anti-Patterns Comuns

❌ **FILTER(ALL(...)) em tabela grande**
❌ **Cálculo repetido sem variável**
❌ **SUMX sem necessidade**
❌ **Divisão sem DIVIDE**
❌ **Medida sem descrição**
❌ **Lógica complexa em uma linha só**
❌ **IFERROR mascarando problemas**

---

**Lembre-se**: DAX performático é DAX legível. Invista tempo em escrever código limpo.
