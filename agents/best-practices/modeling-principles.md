# Modeling Principles - Power BI Best Practices

Princípios fundamentais de modelagem de dados para Power BI.

## Star Schema: O Padrão Ouro

### Por que Star Schema?

O Star Schema é o padrão recomendado pela Microsoft para Power BI porque:

1. **Performance**: Otimizado para consultas analíticas
2. **Simplicidade**: Fácil de entender e navegar
3. **Filtros Eficientes**: Filtros fluem de dimensões para fatos
4. **VertiPaq Optimized**: O engine comprime melhor

### Estrutura Básica

```
         DimProduct ────────────────────┐
              ↓                         │
DimCustomer ← FactSales → DimDate      │
              ↓                         │
         DimSalesRep ───────────────────┘
```

**Fato (Centro)**: Contém métricas numéricas e chaves
**Dimensões (Pontas)**: Contém atributos descritivos

### Componentes

#### Tabela Fato (Fact Table)
- Contém **métricas** (valores numéricos)
- Contém **chaves estrangeiras** para dimensões
- Geralmente muitas linhas
- Define o **grain** (nível mais detalhado)
- Exemplos: FactSales, FactOrders, FactInventory

#### Tabela Dimensão (Dimension Table)
- Contém **atributos descritivos**
- Contém **chave primária única**
- Geralmente poucas linhas (milhares)
- Usado para **filtrar e agrupar**
- Exemplos: DimProduct, DimCustomer, DimDate

### Grain (Granularidade)

O grain define o que cada linha da tabela fato representa:

| Tabela | Grain |
|--------|-------|
| FactSales | Uma linha por item vendido |
| FactDailyInventory | Uma linha por produto por dia |
| FactOrderHeader | Uma linha por pedido |

**Documentar o grain é obrigatório!**

## Relacionamentos

### Direção Correta

```
Dimensão (1) ──────→ (N) Fato
   ONE            MANY
```

- **De**: Dimensão (lado ONE, chave única)
- **Para**: Fato (lado MANY, chave estrangeira)
- **Filtro**: Dimensão → Fato (single direction)

### Cardinalidade

| Tipo | Uso | Frequência |
|------|-----|------------|
| 1:N | Dim → Fact | 99% dos casos |
| N:1 | Fact → Dim | Raro (igual 1:N invertido) |
| M:N | Evitar | Usar bridge table |
| 1:1 | Evitar | Considere merge |

### Direção de Filtro

**Single Direction (✅ Recomendado)**
- Filtro flui de Dimensão para Fato
- Performance melhor
- Comportamento previsível

**Both Directions (⚠️ Evitar)**
- Pode causar ambiguidade
- Performance pior
- Use DAX como alternativa

## Tipos de Dimensões

### Dimensão Regular
Atributos simples de uma entidade.
```
DimProduct: ProductKey, ProductName, Category, Price
```

### Dimensão de Data (Date Table)
**OBRIGATÓRIA** para time intelligence.
```
DimDate: Date, Year, Quarter, Month, Day, WeekDay
```

Requisitos:
- Coluna de data contínua (sem buracos)
- Marcada como Date Table
- Relacionada às datas nas facts

### Dimensão Role-Playing
Mesma dimensão usada para múltiplos propósitos.

```
FactSales.OrderDate ────→ DimDate (ACTIVE)
FactSales.ShipDate - - - → DimDate (INACTIVE)
FactSales.DueDate - - - → DimDate (INACTIVE)
```

Use `USERELATIONSHIP()` para ativar:
```dax
Sales by Ship Date = 
CALCULATE([Total Sales], USERELATIONSHIP(FactSales[ShipDate], DimDate[Date]))
```

### Dimensão Degenerada
Atributos que ficam na própria fact (sem tabela separada).
```
FactSales: OrderNumber, InvoiceNumber (não precisam de dimensão)
```

### Slowly Changing Dimensions (SCD)
Histórico de mudanças em dimensões:

- **Type 1**: Sobrescreve (sem histórico)
- **Type 2**: Nova linha com datas de validade
- **Type 3**: Coluna para valor anterior

## Tabela de Medidas

### Por que Criar?

Medidas podem ser criadas em qualquer tabela, mas uma tabela dedicada:
- Organiza melhor o modelo
- Facilita navegação
- Não polui tabelas de dados

### Como Criar

```dax
Measures = DATATABLE("Placeholder", STRING, {{""}})
```

Ou qualquer tabela calculada vazia:
```dax
Measures = ROW("Dummy", BLANK())
```

Depois:
1. Crie todas as medidas nesta tabela
2. Organize em Display Folders
3. Esconda a coluna Placeholder

## Calculado vs Importado

### Colunas Calculadas

❌ **EVITE quando possível**:
- Ocupam memória permanentemente
- Recalculam em cada refresh
- Não se beneficiam de compressão

✅ **USE apenas para**:
- Categorização fixa (A/B/C)
- Segmentação estática
- Sort By Column requirements

### Medidas

✅ **PREFIRA sempre**:
- Calculam on-demand
- Não ocupam memória
- Podem usar contexto de filtro

**Regra**: Se precisa de agregação, use MEDIDA, não coluna calculada.

## Normalização vs Desnormalização

### No Power BI: Prefira Desnormalização

❌ **Normalizado demais** (banco transacional):
```
Produto → Subcategoria → Categoria → Departamento
```

✅ **Desnormalizado** (analítico):
```
DimProduct: Produto, Subcategoria, Categoria, Departamento
```

### Quando Snowflake é OK

Use apenas se:
- Dimensões muito grandes (>100K linhas)
- Relação clara de hierarquia
- Filtros frequentes em cada nível

## Boas Práticas de Modelagem

### ✅ FAÇA

1. **Use Star Schema** como base
2. **Documente o grain** de cada fact
3. **Crie Date Table** e marque como tal
4. **Use single direction** para filtros
5. **Prefira 1:N** cardinality
6. **Minimize calculated columns**
7. **Crie tabela de Medidas**
8. **Use nomenclatura consistente**

### ❌ NÃO FAÇA

1. **Wide tables** (muitas colunas em uma tabela)
2. **Many-to-Many** sem justificativa
3. **Bidirectional** filtering desnecessário
4. **Calculated columns** para agregações
5. **Snowflake profundo** (>2 níveis)
6. **Tabelas sem relacionamento**
7. **Chaves compostas** (use surrogate keys)
8. **Import de colunas não usadas**

## Checklist de Modelagem

Antes de considerar o modelo pronto:

### Estrutura
- [ ] Segue padrão Star Schema?
- [ ] Grain documentado para cada fact?
- [ ] Date Table existe e está marcada?
- [ ] Tabela de Measures existe?

### Relacionamentos
- [ ] Todos os relacionamentos são 1:N?
- [ ] Direção de filtro é single?
- [ ] Role-playing dimensions configuradas?
- [ ] Sem circular dependencies?

### Colunas
- [ ] Apenas colunas necessárias importadas?
- [ ] Data types corretos?
- [ ] Minimal calculated columns?
- [ ] Colunas não usadas escondidas?

### Medidas
- [ ] Todas em tabela de Measures?
- [ ] Organizadas em Display Folders?
- [ ] Base measures antes de derivadas?
- [ ] Documentation/descriptions?

## Performance Implications

| Prática | Impacto |
|---------|---------|
| Star Schema | ⬆️ Positive |
| Few relationships | ⬆️ Positive |
| Single direction | ⬆️ Positive |
| Integer keys | ⬆️ Positive |
| Snowflake | ⬇️ Slight negative |
| Bidirectional | ⬇️ Negative |
| Many-to-Many | ⬇️ Negative |
| High cardinality | ⬇️ Negative |
| Many calc columns | ⬇️ Negative |

---

**Lembre-se**: Um bom modelo é simples, bem documentado e segue o Star Schema. Complexidade adicional deve ter justificativa clara.
