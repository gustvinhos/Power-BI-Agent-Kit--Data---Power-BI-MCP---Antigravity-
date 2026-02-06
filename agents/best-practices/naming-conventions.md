# Naming Conventions - Power BI Best Practices

Padrões de nomenclatura para modelos semânticos Power BI.

## Princípios Gerais

1. **Consistência**: Use o mesmo padrão em todo o modelo
2. **Clareza**: Nomes devem ser auto-explicativos
3. **Idioma**: Escolha UM idioma e mantenha (Inglês ou Português)
4. **Sem caracteres especiais**: Evite espaços, acentos, símbolos
5. **Case apropr iado**: PascalCase para objetos técnicos

## Tabelas

### Tabelas Fato
```
Prefixo: Fact
Formato: FactNomeDaTabela
Exemplos: FactSales, FactOrders, FactInventory
```

### Tabelas Dimensão
```
Prefixo: Dim
Formato: DimNomeDaTabela
Exemplos: DimProduct, DimCustomer, DimDate
```

### Tabelas Calculadas
```
Prefixo: Calc (opcional)
Formato: CalcNomeDaTabela ou NomeDaTabela
Exemplos: CalcBudget, Measures
```

### Tabelas de Parâmetro
```
Prefixo: Param (opcional)
Exemplos: ParamDateRange, ParamMetricSelector
```

### Tabelas de Bridge (Many-to-Many)
```
Prefixo: Bridge
Exemplos: BridgeProductCategory, BridgeUserRole
```

## Colunas

### Chaves (Keys)
```
Sufixo: Key ou ID
Formato: NomeDaTabelaKey ou NomeDaTabelaID
Exemplos: ProductKey, CustomerID, OrderKey
```

### Datas
```
Sufixo: Date
Formato: DescriçãoDate
Exemplos: OrderDate, ShipDate, DueDate, CreatedDate
```

### Booleans
```
Prefixo: Is, Has, Should, Can
Formato: PrefixoDescrição
Exemplos: IsActive, HasDiscount, ShouldNotify, CanRefund
```

### Valores Numéricos
```
Sem prefixo/sufixo especial
Use nomes descritivos
Exemplos: Quantity, Amount, Price, Cost, Revenue
```

### Hierarquias
```
Nomeie cada nível claramente
Exemplos: Year, Quarter, Month, Day
Exemplos: Country, State, City
```

## Medidas

### Formato Geral
```
Formato: Title Case com espaços
Exemplos: Total Sales, Average Price, Customer Count
```

### Agregações
```
Padrão: [Tipo Agregação] [Campo]
Exemplos:
  - Total Sales
  - Count Orders
  - Average Price
  - Min Quantity
  - Max Revenue
```

### Time Intelligence
```
Sufixos: YTD, MTD, QTD, PY, PM, PQ
Exemplos:
  - Sales YTD (Year to Date)
  - Revenue MTD (Month to Date)
  - Orders QTD (Quarter to Date)
  - Sales PY (Prior Year)
  - Revenue PM (Prior Month)
  - Orders PQ (Prior Quarter)
```

### Comparações
```
Usar "vs" para comparações
Exemplos:
  - Sales vs PY
  - Revenue vs Budget
  - Variance vs Target
```

### Percentuais
```
Sufixo: % ou Percent
Exemplos:
  - Growth Rate %
  - Profit Margin %
  - Market Share Percent
```

### Growth/Change
```
Exemplos:
  - Sales Growth %
  - YoY Growth %
  - MoM Change %
```

### Medidas Helper (Auxiliares)
```
Prefixo: _ (underscore)
Formato: _Descrição
Exemplos:
  - _Base Sales
  - _Selected Period
  - _Filter Context
```

**IMPORTANTE**: Medidas com prefixo `_` devem ter `isHidden: true`

## Display Folders

### Estrutura Recomendada
```
Sales\
  Sales\Base
  Sales\Time Intelligence
  Sales\Comparisons
  Sales\KPIs

Finance\
  Finance\Revenue
  Finance\Costs
  Finance\Profitability

Operations\
  Operations\Inventory
  Operations\Orders
```

### Separador de Níveis
Use `\` (backslash) para separar níveis de pasta.

## Relacionamentos

### Nome Automático
Power BI gera automaticamente: `FromTable_FromColumn`

### Nome Manual (Role-Playing)
```
Formato: [FromTable]To[ToTable][Role]
Exemplos:
  - SalesToDateActive
  - SalesToDateShip
  - SalesToDateDue
```

## Annotações

### Chaves Padrão
```
Purpose: [Objetivo do objeto]
BusinessRule: [Regra de negócio]
Dependencies: [Dependências]
CreatedDate: [Data de criação]
CreatedBy: [Criador]
MigrationSource: [Fonte da migração]
MigrationDate: [Data da migração]
```

## Anti-Patterns (Evitar)

❌ **NÃO FAÇA:**
- `Table1`, `Query1` - Nomes genéricos
- `SalesAmt` - Abreviações desnecessárias
- `tbl_products` - Prefixos de sistema de banco
- `TOTAL_SALES` - SCREAMING_CASE
- `total-sales` - kebab-case
- `Vendas Totais YTD` - Misturar idiomas
- `SalesQty$` - Caracteres especiais

✅ **FAÇA:**
- `FactSales`, `DimProduct` - Prefixos claros
- `Total Sales` - Nome completo e legível
- `Sales YTD` - Sufixo padrão para time intelligence
- `ProductKey` - Sufixo para chaves

## Checklist de Nomenclatura

Antes de criar qualquer objeto, verifique:

- [ ] Tabela fato tem prefixo `Fact`?
- [ ] Tabela dimensão tem prefixo `Dim`?
- [ ] Chaves terminam com `Key` ou `ID`?
- [ ] Datas terminam com `Date`?
- [ ] Booleans começam com `Is`/`Has`/`Should`?
- [ ] Medidas estão em Title Case?
- [ ] Time Intelligence usa sufixos padrão (YTD, PY, etc)?
- [ ] Helpers começam com `_` e estão hidden?
- [ ] Medidas estão organizadas em Display Folders?
- [ ] Não há mistura de idiomas?

## Exemplos Completos

### Modelo de Vendas (Inglês)
```
Tables:
  - FactSales
  - DimProduct
  - DimCustomer
  - DimDate
  - DimSalesRep
  - Measures

Columns (FactSales):
  - SalesKey
  - ProductKey
  - CustomerKey
  - DateKey
  - OrderDate
  - ShipDate
  - Quantity
  - UnitPrice
  - SalesAmount

Measures:
  - Total Sales           (Sales\Base)
  - Total Quantity        (Sales\Base)
  - Sales YTD             (Sales\Time Intelligence)
  - Sales PY              (Sales\Time Intelligence)
  - Sales vs PY           (Sales\Comparisons)
  - Growth Rate %         (Sales\KPIs)
  - _Base Sales           (hidden)
```

### Modelo de Vendas (Português)
```
Tables:
  - FactVendas
  - DimProduto
  - DimCliente
  - DimData
  - DimVendedor
  - Medidas

Columns (FactVendas):
  - VendaKey
  - ProdutoKey
  - ClienteKey
  - DataKey
  - DataPedido
  - DataEnvio
  - Quantidade
  - PrecoUnitario
  - ValorVenda

Measures:
  - Total Vendas          (Vendas\Base)
  - Total Quantidade      (Vendas\Base)
  - Vendas YTD            (Vendas\Time Intelligence)
  - Vendas AA             (Vendas\Time Intelligence) -- Ano Anterior
  - Vendas vs AA          (Vendas\Comparações)
  - Taxa Crescimento %    (Vendas\KPIs)
  - _Base Vendas          (hidden)
```

---

**Lembre-se**: Nomes consistentes facilitam manutenção, debugging e onboarding de novos desenvolvedores.
