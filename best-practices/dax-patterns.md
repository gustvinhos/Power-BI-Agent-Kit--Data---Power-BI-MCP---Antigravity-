# Padrões DAX - Best Practices

Coleção de padrões DAX otimizados e melhores práticas para medidas Power BI.

---

## Princípios Fundamentais

### 1. Use Variáveis para Performance e Legibilidade
✅ **BOM:**
```dax
Total Sales YTD = 
VAR CurrentYTD = TOTALYTD([Total Sales], 'Date'[Date])
VAR PreviousYTD = CALCULATE([Total Sales YTD], SAMEPERIODLASTYEAR('Date'[Date]))
VAR Result = DIVIDE(CurrentYTD - PreviousYTD, PreviousYTD)
RETURN Result
```

❌ **RUIM:**
```dax
Total Sales YTD = 
DIVIDE(
    TOTALYTD([Total Sales], 'Date'[Date]) - CALCULATE(TOTALYTD([Total Sales], 'Date'[Date]), SAMEPERIODLASTYEAR('Date'[Date])),
    CALCULATE(TOTALYTD([Total Sales], 'Date'[Date]), SAMEPERIODLASTYEAR('Date'[Date]))
)
```

### 2. Prefira Agregadores a Iteradores
✅ **MELHOR:**
```dax
Total Sales = SUM(Sales[Amount])
```

❌ **MENOS EFICIENTE:**
```dax
Total Sales = SUMX(Sales, Sales[Amount])
```

> **Nota**: Use iteradores apenas quando necessário (cálculos linha a linha).

### 3. Use CALCULATE Explicitamente para Clareza
✅ **BOM:**
```dax
Sales Last Year = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('Date'[Date])
)
```

---

## Padrões de Time Intelligence

### Year-to-Date (YTD)
```dax
Total Sales YTD = 
TOTALYTD(
    [Total Sales],
    'Date'[Date]
)
```

### Month-to-Date (MTD)
```dax
Total Sales MTD = 
TOTALMTD(
    [Total Sales],
    'Date'[Date]
)
```

### Quarter-to-Date (QTD)
```dax
Total Sales QTD = 
TOTALQTD(
    [Total Sales],
    'Date'[Date]
)
```

### Previous Year (PY)
```dax
Sales PY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('Date'[Date])
)
```

### Previous Month (PM)
```dax
Sales PM = 
CALCULATE(
    [Total Sales],
    DATEADD('Date'[Date], -1, MONTH)
)
```

### Previous Quarter (PQ)
```dax
Sales PQ = 
CALCULATE(
    [Total Sales],
    DATEADD('Date'[Date], -1, QUARTER)
)
```

### Year-over-Year Growth (YoY)
```dax
YoY Growth % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR GrowthRate = DIVIDE(CurrentSales - PreviousSales, PreviousSales)
RETURN GrowthRate
```

### Month-over-Month Growth (MoM)
```dax
MoM Growth % = 
VAR CurrentMonth = [Total Sales]
VAR PreviousMonth = [Sales PM]
RETURN DIVIDE(CurrentMonth - PreviousMonth, PreviousMonth)
```

---

## Padrões de Comparação

### Versus Budget/Target
```dax
Variance vs Budget = [Total Sales] - [Budget]

Variance vs Budget % = 
DIVIDE(
    [Total Sales] - [Budget],
    [Budget]
)

Achievement % = 
DIVIDE(
    [Total Sales],
    [Budget]
)
```

### Versus Previous Period (Genérico)
```dax
Sales vs Previous Period = 
VAR CurrentPeriod = [Total Sales]
VAR PreviousPeriod = 
    CALCULATE(
        [Total Sales],
        DATEADD('Date'[Date], -1, MONTH) // ou QUARTER, YEAR
    )
RETURN CurrentPeriod - PreviousPeriod
```

---

## Padrões de Percentual

### Percentual do Total (% of Total)
```dax
Sales % of Total = 
DIVIDE(
    [Total Sales],
    CALCULATE(
        [Total Sales],
        ALL(DimProduct[ProductName])
    )
)
```

### Percentual do Total Geral (% of Grand Total)
```dax
Sales % of Grand Total = 
DIVIDE(
    [Total Sales],
    CALCULATE(
        [Total Sales],
        ALL(FactSales)
    )
)
```

### Percentual com Contexto Específico
```dax
Sales % of Category = 
DIVIDE(
    [Total Sales],
    CALCULATE(
        [Total Sales],
        ALLEXCEPT(DimProduct, DimProduct[Category])
    )
)
```

---

## Padrões de Ranking

### Ranking Simples
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

### Top N com Outros (Others)
```dax
Top 10 Products = 
VAR CurrentProduct = SELECTEDVALUE(DimProduct[ProductName])
VAR RankValue = [Product Rank]
VAR Result = 
    IF(
        RankValue <= 10,
        CurrentProduct,
        "Others"
    )
RETURN Result
```

### Top N Sales (Medida)
```dax
Top 10 Sales = 
CALCULATE(
    [Total Sales],
    TOPN(
        10,
        ALL(DimProduct[ProductName]),
        [Total Sales],
        DESC
    )
)
```

---

## Padrões de Contagem

### Count Distinct (Contagem Única)
```dax
Customer Count = DISTINCTCOUNT(FactSales[CustomerKey])
```

### Count with Conditions
```dax
Active Customers = 
CALCULATE(
    DISTINCTCOUNT(Sales[CustomerKey]),
    DimCustomer[IsActive] = TRUE
)
```

### Count Non-Blank
```dax
Products with Sales = 
COUNTROWS(
    FILTER(
        VALUES(DimProduct[ProductKey]),
        NOT(ISBLANK([Total Sales]))
    )
)
```

---

## Padrões ABC / Pareto

### ABC Classification
```dax
ABC Class = 
VAR CurrentRank = [Product Rank]
VAR TotalProducts = COUNTROWS(ALL(DimProduct[ProductName]))
VAR ClassA = TotalProducts * 0.2  // Top 20%
VAR ClassB = TotalProducts * 0.5  // Next 30%
VAR Result = 
    SWITCH(
        TRUE(),
        CurrentRank <= ClassA, "A",
        CurrentRank <= ClassB, "B",
        "C"
    )
RETURN Result
```

### Pareto 80/20
```dax
Cumulative Sales % = 
VAR CurrentProduct = SELECTEDVALUE(DimProduct[ProductName])
VAR ProductsUpToCurrent = 
    FILTER(
        ALL(DimProduct[ProductName]),
        [Product Rank] <= [Product Rank]
    )
VAR CumulativeSales = 
    CALCULATE(
        [Total Sales],
        ProductsUpToCurrent
    )
VAR TotalSales = 
    CALCULATE(
        [Total Sales],
        ALL(DimProduct[ProductName])
    )
RETURN DIVIDE(CumulativeSales, TotalSales)
```

---

## Padrões de Running Total

### Running Total Simples
```dax
Running Total Sales = 
CALCULATE(
    [Total Sales],
    FILTER(
        ALL('Date'[Date]),
        'Date'[Date] <= MAX('Date'[Date])
    )
)
```

### Running Total com Reset (por Ano)
```dax
Running Total by Year = 
CALCULATE(
    [Total Sales],
    FILTER(
        ALL('Date'[Date]),
        'Date'[Date] <= MAX('Date'[Date]) &&
        'Date'[Year] = MAX('Date'[Year])
    )
)
```

---

## Padrões de Média

### Média Simples
```dax
Average Sales = AVERAGE(Sales[Amount])
```

### Média Ponderada
```dax
Weighted Average Price = 
DIVIDE(
    SUMX(Sales, Sales[Quantity] * Sales[Price]),
    SUM(Sales[Quantity])
)
```

### Média Móvel (Moving Average)
```dax
3-Month Moving Average = 
VAR LastVisibleDate = MAX('Date'[Date])
VAR Last3Months = 
    DATESINPERIOD(
        'Date'[Date],
        LastVisibleDate,
        -3,
        MONTH
    )
RETURN
    CALCULATE(
        AVERAGE([Total Sales]),
        Last3Months
    )
```

---

## Padrões de Filtro Dinâmico

### Filtro por Seleção de Parâmetro
```dax
Dynamic Measure = 
VAR SelectedMetric = SELECTEDVALUE(ParameterTable[Metric])
VAR Result = 
    SWITCH(
        SelectedMetric,
        "Sales", [Total Sales],
        "Profit", [Total Profit],
        "Quantity", [Total Quantity],
        BLANK()
    )
RETURN Result
```

### Período Dinâmico
```dax
Selected Period Sales = 
VAR PeriodSelection = SELECTEDVALUE(PeriodParameter[Period])
VAR Result = 
    SWITCH(
        PeriodSelection,
        "MTD", [Total Sales MTD],
        "QTD", [Total Sales QTD],
        "YTD", [Total Sales YTD],
        [Total Sales]
    )
RETURN Result
```

---

## Padrões de Texto

### Concatenação Condicional
```dax
Product Label = 
VAR ProductName = DimProduct[ProductName]
VAR Category = DimProduct[Category]
RETURN ProductName & " (" & Category & ")"
```

### Lista de Valores (Comma-Separated)
```dax
Selected Products = 
CONCATENATEX(
    VALUES(DimProduct[ProductName]),
    DimProduct[ProductName],
    ", ",
    DimProduct[ProductName],
    ASC
)
```

---

## Padrões de Tratamento de Erro

### DIVIDE Seguro
✅ **BOM:**
```dax
Profit Margin % = 
DIVIDE(
    [Total Profit],
    [Total Sales],
    0  // Valor alternativo se divisão por zero
)
```

❌ **EVITAR:**
```dax
Profit Margin % = [Total Profit] / [Total Sales]  // Pode gerar erro!
```

### IF com ISBLANK
```dax
Sales or Zero = 
IF(
    ISBLANK([Total Sales]),
    0,
    [Total Sales]
)
```

### COALESCE (Primeiro Não-Vazio)
```dax
Best Available Sales = 
COALESCE(
    [Actual Sales],
    [Estimated Sales],
    [Budget Sales],
    0
)
```

---

## Padrões Avançados

### Same Period Last Year com Fallback
```dax
Sales PY Safe = 
VAR Result = 
    CALCULATE(
        [Total Sales],
        SAMEPERIODLASTYEAR('Date'[Date])
    )
RETURN
    IF(
        ISBLANK(Result),
        0,
        Result
    )
```

### All Periods Until Current
```dax
All Time Sales = 
CALCULATE(
    [Total Sales],
    FILTER(
        ALL('Date'),
        'Date'[Date] <= MAX('Date'[Date])
    )
)
```

### First/Last Non-Blank Value
```dax
Last Known Price = 
LASTNONBLANK(
    VALUES(DimProduct[Price]),
    CALCULATE(SUM(DimProduct[Price]))
)
```

---

## Anti-Padrões (O que EVITAR)

### ❌ Usar FILTER sobre ALL sem necessidade
```dax
// RUIM - muito lento
Bad Measure = 
CALCULATE(
    SUM(Sales[Amount]),
    FILTER(
        ALL(DimProduct),
        DimProduct[Category] = "Electronics"
    )
)

// BOM - usa contexto de filtro diretamente
Good Measure = 
CALCULATE(
    SUM(Sales[Amount]),
    DimProduct[Category] = "Electronics"
)
```

### ❌ Iteradores desnecessários
```dax
// RUIM
Bad Sum = SUMX(Sales, Sales[Amount])

// BOM
Good Sum = SUM(Sales[Amount])
```

### ❌ Múltiplas subconsultas idênticas
```dax
// RUIM - calcula Sales PY 3 vezes!
Bad Growth = 
DIVIDE(
    [Total Sales] - CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date])),
    CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date]))
)

// BOM - usa variável
Good Growth = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
RETURN DIVIDE(CurrentSales - PreviousSales, PreviousSales)
```

---

## Checklist de Qualidade DAX

Ao criar/revisar medidas:

- [ ] Usa variáveis para valores reutilizados
- [ ] Usa DIVIDE em vez de `/` para evitar erros
- [ ] Prefere agregadores (SUM, COUNT) a iteradores (SUMX, COUNTX)
- [ ] Nomes descritivos e formatação consistente
- [ ] Comentários para lógica complexa
- [ ] Tratamento de BLANK/NULL apropriado
- [ ] Performance testada com DAX Studio ou métricas
- [ ] Sem cálculos redundantes
- [ ] Indentação e formatação adequadas

---

## Recursos para Aprofundamento

- **DAX.Guide**: Referência completa de funções DAX
- **SQLBI**: Padrões avançados e otimização
- **DAX Studio**: Ferramenta de análise de performance
- **Tabular Editor**: Melhor editor para DAX
