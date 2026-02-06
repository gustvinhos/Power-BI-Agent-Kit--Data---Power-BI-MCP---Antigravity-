# Princípios de Modelagem - Power BI

Princípios fundamentais para criação de modelos semânticos robustos e escaláveis.

---

## Star Schema Design

### Conceito Fundamental
O **Star Schema** é o padrão ouro para modelagem dimensional no Power BI:
- **Centro**: Tabelas de Fato (Facts) - contêm métricas/medidas
- **Pontas**: Tabelas de Dimensão (Dimensions) - contêm contexto descritivo

### Estrutura Típica
```
        DimProduct
             │
             │
        DimCustomer ─── FactSales ─── DimDate
                            │
                            │
                       DimGeography
```

### Características

#### Tabelas de Fato (Fact Tables)
- Contêm valores numéricos (vendas, quantidade, custo)
- Alto volume de linhas
- Chaves estrangeiras para dimensões
- Grão definido (nível de detalhe)
- Prefixo: `Fact` ou `F_`

**Exemplo:**
```
FactSales
├─ OrderKey (PK)
├─ ProductKey (FK)
├─ CustomerKey (FK)
├─ DateKey (FK)
├─ SalesAmount
├─ Quantity
├─ UnitPrice
└─ TotalCost
```

#### Tabelas de Dimensão (Dimension Tables)
- Contêm atributos descritivos
- Menor volume de linhas
- Desnormalizadas (podem ter redundância)
- Chave primária única
- Prefixo: `Dim` ou `D_`

**Exemplo:**
```
DimProduct
├─ ProductKey (PK)
├─ ProductName
├─ Category
├─ Subcategory
├─ Brand
├─ Color
└─ Size
```

---

## Snowflake Schema

### Conceito
Variação do Star Schema onde dimensões são **normalizadas** (divididas em sub-dimensões).

### Estrutura
```
DimProduct
    │
    └── DimCategory
            │
            └── DimSubcategory
```

### Quando Usar
✅ **Use quando:**
- Redução de redundância é crítica
- Dimensões muito grandes precisam ser quebradas
- Dimensões compartilhadas entre vários fatos

❌ **Evite quando:**
- Performance é prioridade (mais JOINs = mais lento)
- Simplicidade é importante
- Modelo para usuários finais (mais complexo)

> **Recomendação**: Prefira Star Schema na maioria dos casos Power BI

---

## Granularidade (Grain)

### Definição
**Granularidade** é o nível de detalhe de uma tabela de fato.

### Exemplos de Grão
- **Transação individual**: Cada linha = 1 venda
- **Diário por produto**: Cada linha = Total de vendas de 1 produto em 1 dia
- **Mensal por cliente**: Cada linha = Total de vendas de 1 cliente em 1 mês

### Regra de Ouro
> **Todas as linhas de uma tabela de fato devem ter o MESMO grão**

✅ **BOM:**
```
FactSales (Grão: 1 linha = 1 item em 1 pedido)
├─ OrderKey
├─ OrderLineNumber
├─ ProductKey
├─ Quantity
└─ Amount
```

❌ **RUIM:**
```
FactSales (Grão MISTO - NÃO FAÇA!)
├─ Linha 1: Total do pedido 001
├─ Linha 2: Item 1 do pedido 001
├─ Linha 3: Item 2 do pedido 001
└─ [Grão inconsistente!]
```

---

## Relacionamentos

### Tipos de Cardinalidade

#### One-to-Many (1:N) - MAIS COMUM
```
DimProduct (1) ────────> (N) FactSales
ProductKey         ProductKey
```
- **Uso**: Relacionamento padrão dimensão → fato
- **Lado 1**: Dimensão (valores únicos)
- **Lado N**: Fato (valores repetidos)

#### Many-to-One (N:1)
```
FactSales (N) ────────> (1) DimDate
DateKey          DateKey
```
- Mesmo que 1:N, apenas perspectiva diferente
- Power BI trata como 1:N automaticamente

#### Many-to-Many (N:N)
```
FactSales (N) ────────> (N) DimSalesperson
```
- **Uso**: Casos especiais (ex: múltiplos vendedores por venda)
- **Atenção**: Pode causar ambiguidade e lentidão
- **Solução**: Geralmente requer tabela bridge

#### One-to-One (1:1)
- **Raro** em modelos dimensionais
- **Uso**: Tabelas que deveriam estar juntas (avaliar merge)

### Direção de Filtro

#### Single Direction (Padrão)
```
DimProduct ───────> FactSales
         (filtro apenas →)
```
- **Uso**: 99% dos casos
- **Comportamento**: Filtro flui da dimensão para o fato

#### Both Directions (Bidirecional)
```
DimProduct <──────> FactSales
         (filtro ↔)
```
- **Cuidado**: Pode causar ambiguidade
- **Uso legítimo**: Casos específicos (ex: calcular produtos com vendas)

❌ **Evite** bidirecional quando possível - use medidas DAX alternativas

### Relacionamentos Ativos vs Inativos

#### Ativo
- Apenas **1 relacionamento ativo** por par de tabelas
- Aplicado automaticamente a medidas

#### Inativo
- Usados para role-playing dimensions
- Ativados via `USERELATIONSHIP()` no DAX

**Exemplo:**
```
FactSales ─────────> DimDate (ativo)
OrderDate     Date

FactSales - - - - -> DimDate (inativo)
ShipDate      Date
```

**DAX para usar inativo:**
```dax
Shipped Sales = 
CALCULATE(
    [Total Sales],
    USERELATIONSHIP(FactSales[ShipDate], DimDate[Date])
)
```

---

## Normalização vs Desnormalização

### Normalização (Relacional)
✅ **Vantagens:**
- Sem redundância de dados
- Atualizações em um único lugar
- Menor tamanho de armazenamento

❌ **Desvantagens:**
- Mais JOINs = mais lento
- Mais complexo para análise

### Desnormalização (Dimensional)
✅ **Vantagens:**
- Performance superior em queries analíticas
- Modelo mais simples e intuitivo
- Menos JOINs necessários

❌ **Desvantagens:**
- Redundância de dados (aceita em BI!)
- Maior tamanho (geralmente aceitável)

> **Regra Power BI**: Desnormalize dimensões, normalize fatos

**Exemplo - Desnormalizar Produto:**
```
DimProduct (Desnormalizado para Performance)
├─ ProductKey
├─ ProductName
├─ Category        ← Redundante, mas OK!
├─ CategoryCode    ← Redundante, mas OK!
├─ Subcategory     ← Redundante, mas OK!
└─ Brand           ← Redundante, mas OK!
```

---

## Date Table (Tabela de Datas)

### Importância
**Toda** modelo Power BI deve ter uma tabela de datas dedicada.

### Características Essenciais
- Contém **todas** datas no período de análise
- Colunas calculadas para Year, Quarter, Month, etc.
- Marcada como "Tabela de Datas" no Power BI
- Relacionada a todas as colunas de data nas tabelas de fato

### Exemplo de Estrutura
```dax
DimDate = 
ADDCOLUMNS(
    CALENDAR(DATE(2020, 1, 1), DATE(2030, 12, 31)),
    "Year", YEAR([Date]),
    "Quarter", "Q" & FORMAT([Date], "Q"),
    "Month", FORMAT([Date], "MMMM"),
    "MonthNumber", MONTH([Date]),
    "Day", DAY([Date]),
    "DayOfWeek", FORMAT([Date], "dddd"),
    "IsWeekend", WEEKDAY([Date]) IN {1, 7},
    "YearMonth", FORMAT([Date], "YYYY-MM"),
    "YearQuarter", FORMAT([Date], "YYYY") & " Q" & FORMAT([Date], "Q")
)
```

### Time Intelligence
Tabela de datas é **obrigatória** para:
- TOTALYTD
- SAMEPERIODLASTYEAR
- DATEADD
- PARALLELPERIOD
- etc.

---

## Role-Playing Dimensions

### Conceito
Uma dimensão usada em **múltiplos contextos** no mesmo fato.

### Exemplo Clássico: Datas
```
FactSales ─────────> DimDate (OrderDate) [ativo]
          - - - - -> DimDate (ShipDate)  [inativo]
          - - - - -> DimDate (DueDate)   [inativo]
```

### Abordagens

#### Abordagem 1: Relacionamentos Inativos (Recomendado)
- 1 DimDate com múltiplos relacionamentos
- Usa `USERELATIONSHIP()` em medidas

✅ **Vantagens:**
- Modelo mais simples
- Menos tabelas

❌ **Desvantagens:**
- Requer medidas específicas para cada role

#### Abordagem 2: Múltiplas Views (Alternativa)
- Duplicar DimDate → DimOrderDate, DimShipDate
- Relacionamentos ativos para cada

✅ **Vantagens:**
- Mais intuitivo para usuários finais
- Filtros independentes

❌ **Desvantagens:**
- Duplicação de tabelas
- Modelo maior

> **Recomendação**: Use Abordagem 1 (relacionamentos inativos) na maioria dos casos

---

## Slowly Changing Dimensions (SCD)

### Conceito
Dimensões que mudam ao longo do tempo (ex: cliente muda de endereço).

### Tipos

#### Type 0: Valores Fixos
- Nunca mudam
- Ex: Data de nascimento

#### Type 1: Sobrescrever (SCD1)
- Valor antigo é perdido
- Sempre mostra valor atual
- **Uso**: Quando histórico não importa

**Exemplo:**
```
Cliente mudou de "SP" para "RJ" → apenas "RJ" fica registrado
```

#### Type 2: Nova Linha (SCD2) - MAIS COMUM
- Mantém histórico completo
- Adiciona nova linha para cada mudança
- Usa colunas `ValidFrom` e `ValidTo`

**Exemplo:**
```
DimCustomer
├─ CustomerKey (PK surrogate)
├─ CustomerID (Business Key)
├─ Name
├─ State
├─ ValidFrom
├─ ValidTo
└─ IsCurrent

Linhas:
1 | 001 | João | SP | 2020-01-01 | 2023-05-31 | FALSE
2 | 001 | João | RJ | 2023-06-01 | 9999-12-31 | TRUE
```

#### Type 3: Colunas Antigas (SCD3)
- Mantém apenas valor anterior
- Colunas `Previous_` e `Current_`

---

## Bridge Tables (Tabelas Ponte)

### Quando Usar
Resolver relacionamentos Many-to-Many sem usar M:N direto.

### Exemplo: Produto com Múltiplas Categorias
```
DimProduct ─> BridgeProductCategory <─ DimCategory
```

**BridgeProductCategory:**
```
ProductKey | CategoryKey
-----------+------------
     1     |      1
     1     |      3
     2     |      2
```

---

## Calculated Tables

### Quando Usar
✅ **Use para:**
- Tabelas de parâmetros
- Tabelas de datas
- Tabelas de suporte (ex: ranges)

❌ **Evite para:**
- Substituir transformações do Power Query (faça em M, não DAX)
- Duplicar dados que já existem

### Exemplo: Tabela de Parâmetros
```dax
TopNParameter = 
DATATABLE(
    "Label", STRING,
    "Value", INTEGER,
    {
        {"Top 5", 5},
        {"Top 10", 10},
        {"Top 20", 20},
        {"Top 50", 50}
    }
)
```

---

## Calculated Columns vs Measures

### Calculated Columns
- Calculadas em **refresh** time
- Armazenadas no modelo (ocupam espaço)
- Usam contexto de linha (row context)
- **Use para**: Categorização, flags, derivações simples

**Exemplo:**
```dax
AgeGroup = 
SWITCH(
    TRUE(),
    Customer[Age] < 18, "Youth",
    Customer[Age] < 65, "Adult",
    "Senior"
)
```

### Measures
- Calculadas em **query** time
- Não armazenadas (não ocupam espaço no disco)
- Usam contexto de filtro (filter context)
- **Use para**: Agregações, cálculos dinâmicos, KPIs

**Exemplo:**
```dax
Total Sales = SUM(Sales[Amount])
```

> **Regra**: Prefira **measures** sempre que possível

---

## Otimização de Modelo

### Reduzir Cardinalidade
- Quanto menos valores únicos, melhor a compressão
- Evite colunas com valores muito únicos se não necessário
- Exemplo: Prefira `Date` a `DateTime` quando hora não importa

### Eliminar Colunas Desnecessárias
- Remova colunas que não são usadas
- Cada coluna ocupa memória

### Usar Tipos de Dados Apropriados
- `Integer` < `Decimal` < `String` (em tamanho)
- Use tipo de dado mais restrito possível

### Evitar Bi-Directional Filters
- Causam ambiguidade e lentidão
- Use apenas quando absolutamente necessário

---

## Checklist de Modelo

Ao criar/revisar modelo:

**Estrutura:**
- [ ] Segue Star Schema (ou Snowflake justificado)
- [ ] Cada fato tem grão consistente
- [ ] Dimensões desnormalizadas
- [ ] Tabela de datas presente e marcada

**Relacionamentos:**
- [ ] Principalmente 1:N (evitar M:N)
- [ ] Direção Single quando possível
- [ ] Role-playing dimensions com inativos

**Nomenclatura:**
- [ ] Prefixos Dim/Fact consistentes
- [ ] Chaves com sufixo Key/ID
- [ ] Sem abreviações ambíguas

**Performance:**
- [ ] Colunas desnecessárias removidas
- [ ] Tipos de dados otimizados
- [ ] Cardinalidade minimizada
- [ ] Calculated columns apenas quando necessário

**Qualidade:**
- [ ] Descrições em objetos principais
- [ ] Medidas organizadas em pastas
- [ ] Sem erros/warnings

---

## Recursos

- **Kimball Dimensional Modeling**: Referência clássica
- **SQLBI**: Modelagem avançada Power BI
- **DAX Patterns**: Padrões de modelagem específicos
