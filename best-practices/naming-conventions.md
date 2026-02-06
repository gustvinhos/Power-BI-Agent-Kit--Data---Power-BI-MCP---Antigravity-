# Convenções de Nomenclatura - Power BI

Convenções padronizadas para garantir consistência e legibilidade em modelos Power BI.

---

## Tabelas

### Tabelas de Dimensão
- **Prefixo**: `Dim` ou `D_`
- **Formato**: PascalCase
- **Exemplos**: 
  - `DimProduct`
  - `DimCustomer`
  - `DimDate`
  - `DimGeography`

### Tabelas de Fato
- **Prefixo**: `Fact` ou `F_`
- **Formato**: PascalCase
- **Exemplos**:
  - `FactSales`
  - `FactInventory`
  - `FactOrders`

### Tabelas de Bridge (Ponte)
- **Prefixo**: `Bridge`
- **Formato**: PascalCase
- **Exemplo**: `BridgeProductCategory`

### Tabelas Calculadas
- **Prefixo**: `Calc` (opcional)
- **Formato**: PascalCase
- **Exemplos**:
  - `CalcDateTable`
  - `ParameterTable`

### Tabelas de Parâmetros
- **Sufixo**: `Parameter` ou `Param`
- **Formato**: PascalCase
- **Exemplos**:
  - `SalesTypeParameter`
  - `TopNParameter`

---

## Colunas

### Chaves (Keys)
- **Sufixo**: `Key` ou `ID`
- **Formato**: PascalCase
- **Exemplos**:
  - `ProductKey`
  - `CustomerID`
  - `OrderKey`

### Chaves Estrangeiras
- **Formato**: Mesmo nome da chave primária referenciada
- **Exemplo**: `ProductKey` (em FactSales) → `ProductKey` (em DimProduct)

### Colunas de Data
- **Sufixo**: `Date`
- **Formato**: PascalCase
- **Exemplos**:
  - `OrderDate`
  - `ShipDate`
  - `CreatedDate`

### Colunas Calculadas
- **Formato**: PascalCase, descritivo
- **Exemplos**:
  - `FullName`
  - `AgeGroup`
  - `PriceCategory`
  - `YearMonth`

### Colunas Booleanas
- **Prefixo**: `Is`, `Has`, `Should`
- **Formato**: PascalCase
- **Exemplos**:
  - `IsActive`
  - `HasDiscount`
  - `ShouldInclude`

---

## Medidas (Measures)

### Medidas Básicas
- **Formato**: Espaços entre palavras, Title Case
- **Pattern**: `[Agregação] [Campo]`
- **Exemplos**:
  - `Total Sales`
  - `Average Price`
  - `Count Orders`
  - `Sum Quantity`

### Time Intelligence
- **Sufixo**: `YTD`, `MTD`, `QTD`, `PY`, `PM`, `PQ`
- **Formato**: Title Case com espaços
- **Exemplos**:
  - `Total Sales YTD`
  - `Revenue MTD`
  - `Profit PY` (Previous Year)
  - `Growth vs PY`

### Medidas de Variação
- **Pattern**: `[Medida] vs [Período]` ou `[Medida] % Change`
- **Exemplos**:
  - `Sales vs PY`
  - `Revenue % Change`
  - `Variance vs Budget`

### Medidas de Percentual
- **Sufixo**: `%` ou `Percent` ou `Pct`
- **Formato**: Title Case
- **Exemplos**:
  - `Profit Margin %`
  - `Growth Rate %`
  - `Sales % of Total`

### Medidas Complexas/Auxiliares
- **Prefixo**: `_` (underscore para ocultar)
- **Formato**: Title Case
- **Uso**: Medidas intermediárias que não devem aparecer no relatório
- **Exemplos**:
  - `_Base Sales`
  - `_Selected Period`
  - `_Previous Period Sales`

---

## Relacionamentos

### Nomenclatura Automática
- **Pattern**: `FromTable_FromColumn`
- **Exemplo**: `FactSales_ProductKey` (auto-gerado)

### Nomenclatura Manual (quando necessário)
- **Pattern**: `[FromTable]To[ToTable]`
- **Formato**: PascalCase
- **Exemplos**:
  - `SalesToProduct`
  - `OrdersToCustomer`
  - `SalesToDateActive` (para role-playing dimensions)

---

## Pastas de Exibição (Display Folders)

### Para Medidas
Organizar medidas em hierarquia de pastas:

```
📁 Sales
  📁 Base Measures
    - Total Sales
    - Total Quantity
  📁 Time Intelligence
    - Total Sales YTD
    - Total Sales MTD
  📁 Comparisons
    - Sales vs PY
    - Sales Growth %
📁 Profitability
  - Profit Margin %
  - Gross Profit
📁 KPIs
  - Sales Target Achievement
  - Customer Satisfaction Score
```

### Convenções
- **Formato**: Title Case
- **Hierarquia**: Usar `\` para subpastas
- **Exemplo**: `Sales\Time Intelligence\YTD`

---

## Hierarquias (Hierarchies)

### Nomenclatura
- **Formato**: PascalCase, descritivo
- **Sufixo**: `Hierarchy` (opcional)
- **Exemplos**:
  - `ProductHierarchy`
  - `GeographyHierarchy`
  - `DateHierarchy`

### Níveis (Levels)
- **Formato**: PascalCase, singular
- **Ordem**: Do mais alto para mais baixo
- **Exemplo**: 
  ```
  DateHierarchy
    └─ Year
       └─ Quarter
          └─ Month
             └─ Day
  ```

---

## Funções DAX (User-Defined Functions)

### Nomenclatura
- **Prefixo**: `fn` (function)
- **Formato**: PascalCase
- **Exemplos**:
  - `fnGetWorkingDays`
  - `fnConvertCurrency`
  - `fnCalculateMargin`

---

## Perspectivas (Perspectives)

### Nomenclatura
- **Formato**: Title Case, descritivo do contexto de negócio
- **Exemplos**:
  - `Sales Analysis`
  - `Finance View`
  - `Executive Dashboard`

---

## Anotações e Extended Properties

### Annotations
- **Chaves**: PascalCase
- **Exemplos**:
  - `@BusinessOwner`
  - `@LastModified`
  - `@DataSource`

---

## Boas Práticas Gerais

### ✅ DO (Faça)
- Use nomes descritivos e autoexplicativos
- Seja consistente em todo o modelo
- Use convenções que facilitem ordenação alfabética
- Documente exceções às convenções
- Use prefixos/sufixos para facilitar filtros e buscas

### ❌ DON'T (Não Faça)
- Não use abreviações ambíguas (ex: `Prod` pode ser Product ou Production)
- Não use caracteres especiais desnecessários
- Não misture idiomas (escolha inglês OU português)
- Não use nomes genéricos (`Table1`, `Measure1`)
- Não use espaços em excesso ou inconsistentes

---

## Idioma

### Recomendação
- **Inglês**: Preferível para ambientes corporativos globais ou quando código será compartilhado
- **Português**: Aceitável para ambientes locais onde toda equipe é brasileira

### Consistência
- **CRÍTICO**: Nunca misture idiomas no mesmo modelo
- Escolha um idioma e use consistentemente em:
  - Nomes de tabelas
  - Nomes de colunas
  - Nomes de medidas
  - Descrições
  - Comentários DAX

---

## Exemplos Completos

### Modelo de Vendas (Sales Model)

**Tabelas:**
```
DimProduct
DimCustomer
DimDate
DimGeography
FactSales
FactOrders
```

**Medidas:**
```
Total Sales
Total Sales YTD
Sales vs PY
Profit Margin %
Average Order Value
Customer Count
_Base Period Sales (hidden)
```

**Relacionamentos:**
```
FactSales_ProductKey
FactSales_CustomerKey
FactSales_OrderDateKey
FactSales_ShipDateKey (inactive)
```

**Hierarquias:**
```
ProductHierarchy
  └─ Category
     └─ Subcategory
        └─ Product

GeographyHierarchy
  └─ Country
     └─ State
        └─ City
```

---

## Checklist de Validação

Ao revisar um modelo, verifique:

- [ ] Todos os nomes de tabelas seguem convenção de prefixo
- [ ] Chaves têm sufixo `Key` ou `ID`
- [ ] Medidas usam Title Case com espaços
- [ ] Medidas auxiliares estão ocultas com prefixo `_`
- [ ] Time Intelligence usa sufixos padronizados
- [ ] Relacionamentos têm nomes descritivos
- [ ] Pastas de exibição estão organizadas logicamente
- [ ] Não há mistura de idiomas
- [ ] Não há abreviações ambíguas
- [ ] Nomes são autoexplicativos
