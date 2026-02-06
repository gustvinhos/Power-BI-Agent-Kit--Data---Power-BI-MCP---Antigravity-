# Padrões de Comentários DAX - Power BI

Padrões obrigatórios para comentários em medidas, colunas calculadas e funções DAX.

---

## 🎯 Princípios Fundamentais

### 1. Comentários Devem Explicar "POR QUÊ", Não "O QUÊ"

❌ **RUIM:**
```dax
// Soma a coluna Amount
Total Sales = SUM(Sales[Amount])
```

✅ **BOM:**
```dax
// Calcula vendas totais para análise de performance regional
// Inclui todas as transações, exceto devoluções (filtradas na fonte)
Total Sales = SUM(Sales[Amount])
```

### 2. Use Comentários de Bloco para Medidas Complexas

✅ **BOM:**
```dax
/*
    PROPÓSITO: Calcula crescimento YoY considerando sazonalidade
    AUTOR: Data Team
    DATA: 2026-02-03
    DEPENDÊNCIAS: [Total Sales], [Sales PY]
    NOTAS: Retorna BLANK se não houver dados do ano anterior
*/
Sales Growth YoY % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = DIVIDE(CurrentSales - PreviousSales, PreviousSales)
RETURN Growth
```

---

## 📝 Estrutura de Comentários

### Template para Medidas Simples

```dax
// [EMOJI] [CATEGORIA] | [Descrição breve]
// [Regra de negócio ou contexto adicional]
MeasureName = 
EXPRESSION
```

**Exemplo:**
```dax
// 📊 MÉTRICA BASE | Soma total de vendas brutas
// Inclui todas as filiais, exceto vendas canceladas
Total Sales = 
SUM(Sales[Amount])
```

### Template para Medidas Complexas

```dax
/*
    [EMOJI] [CATEGORIA] | [Título]
    
    PROPÓSITO:
        [Explicação do objetivo de negócio]
    
    LÓGICA:
        1. [Passo 1]
        2. [Passo 2]
        3. [Passo 3]
    
    DEPENDÊNCIAS:
        - [Medida/Tabela 1]
        - [Medida/Tabela 2]
    
    NOTAS:
        - [Consideração especial 1]
        - [Consideração especial 2]
    
    AUTOR: [Nome/Equipe]
    DATA: [YYYY-MM-DD]
*/
MeasureName = 
VAR Variable1 = EXPRESSION
VAR Variable2 = EXPRESSION
RETURN
    EXPRESSION
```

**Exemplo:**
```dax
/*
    🔄 TIME INTELLIGENCE | Crescimento Year-over-Year
    
    PROPÓSITO:
        Calcula variação percentual de vendas comparando período atual
        com mesmo período do ano anterior, considerando sazonalidade.
    
    LÓGICA:
        1. Captura vendas do período atual
        2. Captura vendas do mesmo período ano anterior
        3. Calcula variação percentual usando DIVIDE para segurança
        4. Retorna BLANK se não houver dados históricos
    
    DEPENDÊNCIAS:
        - [Total Sales]: Medida base de vendas
        - [Sales PY]: Vendas do ano anterior
        - DimDate: Tabela de calendário
    
    NOTAS:
        - Usa DIVIDE para evitar erro de divisão por zero
        - Retorna BLANK (não 0%) quando não há dados PY
        - Funciona corretamente com filtros de data
    
    AUTOR: Data Team
    DATA: 2026-02-03
*/
Sales Growth YoY % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = 
    DIVIDE(
        CurrentSales - PreviousSales,
        PreviousSales
    )
RETURN
    Growth
```

---

## 🏷️ Emojis para Categorização

Use emojis no início dos comentários para identificação visual rápida:

| Emoji | Categoria | Uso |
|-------|-----------|-----|
| 📦 | MIGRADO | Medidas migradas de outro modelo |
| ✨ | NOVO | Medidas recém-criadas |
| 📊 | MÉTRICA BASE | Agregações simples (SUM, COUNT, AVG) |
| 🔄 | TIME INTELLIGENCE | Cálculos temporais (YTD, PY, MTD) |
| 🎯 | KPI | Indicadores-chave de performance |
| 📈 | COMPARAÇÃO | Variações, crescimento, vs Budget |
| 🔧 | HELPER | Medidas auxiliares (prefixo _) |
| ⚠️ | DEPRECATED | Medidas obsoletas |
| 🧮 | CÁLCULO COMPLEXO | Lógica avançada com múltiplas etapas |
| 💰 | FINANCEIRO | Medidas financeiras específicas |
| 📍 | FILTRO | Medidas que aplicam filtros específicos |

---

## 📐 Padrões por Tipo de Medida

### 1. Agregações Simples

```dax
// 📊 MÉTRICA BASE | Total de vendas brutas
// Soma todas as transações de venda, incluindo impostos
Total Sales = 
SUM(Sales[Amount])
```

### 2. Time Intelligence

```dax
// 🔄 TIME INTELLIGENCE | Vendas acumuladas no ano
// Calcula YTD usando tabela de calendário DimDate
// Respeita filtros de ano fiscal (Abril-Março)
Total Sales YTD = 
TOTALYTD(
    [Total Sales],
    DimDate[Date],
    "3/31"  -- Fim do ano fiscal
)
```

### 3. Comparações e Variações

```dax
// 📈 COMPARAÇÃO | Variação vs ano anterior
// Retorna diferença absoluta (não percentual)
// BLANK se não houver dados do ano anterior
Sales vs PY = 
VAR Current = [Total Sales]
VAR Previous = [Sales PY]
RETURN
    Current - Previous
```

### 4. KPIs

```dax
/*
    🎯 KPI | Atingimento de Meta de Vendas
    
    PROPÓSITO:
        Calcula percentual de atingimento da meta mensal de vendas.
        Usado no dashboard executivo para tracking de performance.
    
    LÓGICA:
        1. Obtém vendas realizadas do período
        2. Obtém meta definida para o período
        3. Calcula percentual de atingimento
        4. Retorna 0% se não houver meta definida
    
    REGRA DE NEGÓCIO:
        - Meta >= 100%: Verde (atingiu)
        - Meta >= 90%: Amarelo (próximo)
        - Meta < 90%: Vermelho (não atingiu)
    
    AUTOR: Sales Analytics Team
    DATA: 2026-02-03
*/
Sales Target Achievement % = 
VAR Actual = [Total Sales]
VAR Target = [Sales Target]
VAR Achievement = DIVIDE(Actual, Target, 0)
RETURN
    Achievement
```

### 5. Medidas com Filtros Específicos

```dax
// 📍 FILTRO | Vendas apenas de produtos eletrônicos
// Aplica filtro fixo na categoria, ignora seleções do usuário
Electronics Sales = 
CALCULATE(
    [Total Sales],
    Product[Category] = "Electronics"
)
```

### 6. Medidas Helper (Auxiliares)

```dax
// 🔧 HELPER | Base para cálculos de margem
// USO INTERNO: Não exibir em relatórios (isHidden = true)
// Calcula custo total para uso em outras medidas
_Total Cost = 
SUM(Sales[Cost])
```

### 7. Medidas Migradas

```dax
/*
    📦 MIGRADO DO V3 | Estoque Retroativo em Reais
    
    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela: Estoque Histórico AXIA
        Data Migração: 2026-02-03
    
    PROPÓSITO:
        Calcula valor total do estoque em períodos históricos
        para análises retroativas e comparações temporais.
    
    REGRA DE NEGÓCIO:
        Soma o custo total (CUSTO_TOTAL) de todas as linhas
        do estoque histórico no contexto de filtro atual.
    
    DEPENDÊNCIAS:
        - Estoque Histórico AXIA[CUSTO_TOTAL]
    
    NOTAS:
        - Medida idêntica à versão do V3
        - Testada e validada em 2026-02-03
*/
Estoque Retroativo (R$) = 
SUM('Estoque Histórico AXIA'[CUSTO_TOTAL])
```

### 8. Cálculos Complexos com Variáveis

```dax
/*
    🧮 CÁLCULO COMPLEXO | ABC Classification
    
    PROPÓSITO:
        Classifica produtos em categorias A, B, C baseado em
        contribuição acumulada para vendas totais (Pareto).
    
    LÓGICA:
        1. Calcula vendas do produto atual
        2. Calcula vendas totais de todos os produtos
        3. Calcula ranking do produto por vendas (DESC)
        4. Calcula vendas acumuladas até o produto atual
        5. Calcula percentual acumulado
        6. Classifica: A (0-80%), B (80-95%), C (95-100%)
    
    REGRA DE NEGÓCIO:
        - Classe A: Top produtos que representam 80% das vendas
        - Classe B: Produtos que representam 15% das vendas
        - Classe C: Produtos que representam 5% das vendas
    
    PERFORMANCE:
        - Usa variáveis para evitar recálculos
        - Otimizado para grandes volumes (testado com 100k+ produtos)
    
    AUTOR: Supply Chain Team
    DATA: 2026-02-03
*/
ABC Classification = 
VAR ProductSales = [Total Sales]
VAR TotalSales = 
    CALCULATE(
        [Total Sales],
        ALL(Product[ProductName])
    )
VAR ProductRank = 
    RANKX(
        ALL(Product[ProductName]),
        [Total Sales],
        ,
        DESC,
        DENSE
    )
VAR CumulativeSales = 
    CALCULATE(
        [Total Sales],
        FILTER(
            ALL(Product[ProductName]),
            RANKX(
                ALL(Product[ProductName]),
                [Total Sales],
                ,
                DESC,
                DENSE
            ) <= ProductRank
        )
    )
VAR CumulativePercent = DIVIDE(CumulativeSales, TotalSales)
VAR Classification = 
    SWITCH(
        TRUE(),
        CumulativePercent <= 0.80, "A",
        CumulativePercent <= 0.95, "B",
        "C"
    )
RETURN
    Classification
```

---

## 🎨 Formatação de Código

### Indentação e Espaçamento

✅ **BOM:**
```dax
Sales Growth % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = 
    DIVIDE(
        CurrentSales - PreviousSales,
        PreviousSales
    )
RETURN
    Growth
```

❌ **RUIM:**
```dax
Sales Growth % = VAR CurrentSales=[Total Sales] VAR PreviousSales=[Sales PY] RETURN DIVIDE(CurrentSales-PreviousSales,PreviousSales)
```

### Comentários em Variáveis

```dax
Sales Analysis = 
-- Vendas do período atual
VAR CurrentSales = [Total Sales]

-- Vendas do mesmo período ano anterior
VAR PreviousSales = [Sales PY]

-- Calcula crescimento percentual (seguro contra divisão por zero)
VAR Growth = DIVIDE(CurrentSales - PreviousSales, PreviousSales)

RETURN
    Growth
```

---

## 📋 Checklist de Comentários

Antes de finalizar uma medida, verifique:

- [ ] Comentário de cabeçalho com emoji e categoria
- [ ] Descrição do propósito de negócio
- [ ] Regra de negócio explicada (se não óbvia)
- [ ] Dependências listadas (tabelas, colunas, medidas)
- [ ] Notas sobre edge cases (BLANK, zero, etc.)
- [ ] Autor e data (para medidas complexas)
- [ ] Comentários em variáveis (se múltiplas)
- [ ] Explicação de funções não-óbvias
- [ ] Informação de migração (se aplicável)

---

## 🚫 O Que NÃO Comentar

### Evite Comentários Óbvios

❌ **RUIM:**
```dax
// Soma a coluna Amount
Total Sales = SUM(Sales[Amount])
```

✅ **BOM:**
```dax
// 📊 MÉTRICA BASE | Vendas brutas totais (inclui impostos)
Total Sales = SUM(Sales[Amount])
```

### Evite Comentários Redundantes

❌ **RUIM:**
```dax
// Divide CurrentSales por PreviousSales
VAR Growth = DIVIDE(CurrentSales, PreviousSales)
```

✅ **BOM:**
```dax
// Calcula taxa de crescimento (usa DIVIDE para segurança)
VAR Growth = DIVIDE(CurrentSales, PreviousSales)
```

---

## 🔄 Manutenção de Comentários

### Quando Atualizar Comentários

1. **Mudança de lógica** - Sempre atualize se a fórmula mudar
2. **Mudança de regra de negócio** - Documente a mudança
3. **Descoberta de edge case** - Adicione nota
4. **Otimização de performance** - Documente a melhoria

### Versionamento

Para mudanças significativas, adicione histórico:

```dax
/*
    HISTÓRICO DE MUDANÇAS:
    
    v1.0 (2025-01-15):
        - Criação inicial
        - Lógica básica de YoY
    
    v1.1 (2025-06-20):
        - Adicionado tratamento para ano bissexto
        - Otimização com variáveis
    
    v2.0 (2026-02-03):
        - Migrado do V3 para Golden Dataset
        - Adicionadas annotations completas
*/
```

---

## 📚 Exemplos Completos

### Exemplo 1: Medida Simples Documentada

```dax
// 📊 MÉTRICA BASE | Quantidade total de pedidos
// Conta linhas únicas da tabela de pedidos
// Usado como denominador em cálculos de ticket médio
Total Orders = 
COUNTROWS(Orders)
```

### Exemplo 2: Medida Complexa Documentada

```dax
/*
    🔄 TIME INTELLIGENCE | Média Móvel 3 Meses
    
    PROPÓSITO:
        Calcula média móvel de vendas dos últimos 3 meses
        para suavizar variações sazonais e identificar tendências.
    
    LÓGICA:
        1. Identifica os últimos 3 meses a partir do contexto atual
        2. Calcula média de vendas mensais nesse período
        3. Retorna BLANK se houver menos de 3 meses de dados
    
    DEPENDÊNCIAS:
        - [Total Sales]: Medida base de vendas
        - DimDate: Tabela de calendário (marcada como Date Table)
    
    REGRA DE NEGÓCIO:
        - Requer mínimo de 3 meses de dados
        - Considera apenas meses completos
        - Ignora mês atual se incompleto
    
    PERFORMANCE:
        - Otimizado com variáveis
        - Testado com datasets de 5+ anos
    
    NOTAS:
        - Retorna BLANK (não 0) se dados insuficientes
        - Funciona corretamente com filtros de ano/trimestre
        - Não considera meses sem vendas (usa AVERAGE, não AVERAGEX)
    
    AUTOR: Analytics Team
    DATA: 2026-02-03
*/
Sales 3M Moving Average = 
VAR CurrentDate = MAX(DimDate[Date])
VAR Last3Months = 
    DATESINPERIOD(
        DimDate[Date],
        CurrentDate,
        -3,
        MONTH
    )
VAR MonthCount = 
    CALCULATE(
        DISTINCTCOUNT(DimDate[YearMonth]),
        Last3Months
    )
VAR Average3M = 
    CALCULATE(
        AVERAGE(DimDate[MonthNumber]),  -- Placeholder, ajustar lógica
        Last3Months
    )
RETURN
    IF(
        MonthCount >= 3,
        Average3M,
        BLANK()
    )
```

---

## ✅ Resumo de Boas Práticas

1. ✅ **Use emojis** para categorização visual
2. ✅ **Explique "POR QUÊ"**, não "O QUÊ"
3. ✅ **Documente regras de negócio** em linguagem natural
4. ✅ **Liste dependências** (tabelas, colunas, medidas)
5. ✅ **Comente edge cases** (BLANK, zero, divisão por zero)
6. ✅ **Use comentários de bloco** para medidas complexas
7. ✅ **Comente variáveis** quando não óbvias
8. ✅ **Mantenha comentários atualizados** com o código
9. ✅ **Adicione autor e data** para rastreabilidade
10. ✅ **Documente migrações** com origem e data

---

**Lembre-se:** Comentários são para humanos, não para máquinas. Escreva pensando em quem vai ler daqui a 6 meses! 🚀
