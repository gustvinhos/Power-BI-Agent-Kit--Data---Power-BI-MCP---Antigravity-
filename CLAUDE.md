# Power BI Agent Kit - Instruções para Claude

## Idioma
- Responda sempre em **Português (Brasil)**
- Mantenha termos técnicos em **inglês**: funções DAX, nomes de tabelas/colunas, features do Power BI

---

## Conexão MCP (Power BI)

Antes de qualquer operação no modelo, verifique a conexão:
```
connection_operations: ListLocalInstances, Connect, GetConnection
```

Operações disponíveis:
- `table_operations`: Create, Update, Delete, GetSchema, List
- `measure_operations`: Create, Update, Delete, Move, List
- `column_operations`: Create, Update, Delete, List
- `relationship_operations`: Create, Update, Delete, List
- `dax_query_operations`: Execute, Validate, ClearCache

---

## Nomenclatura Obrigatória

| Objeto | Padrão | Exemplo |
|--------|--------|---------|
| Tabela Dimensão | `Dim` + PascalCase | `DimProduct`, `DimDate` |
| Tabela Fato | `Fact` + PascalCase | `FactSales`, `FactOrders` |
| Chaves | Sufixo `Key` ou `ID` | `ProductKey`, `CustomerID` |
| Medidas | Title Case com espaços | `Total Sales`, `Profit Margin %` |
| Medidas Helper | Prefixo `_` + isHidden | `_Base Sales` |
| Time Intelligence | Sufixos padrão | YTD, MTD, QTD, PY, PM |
| Percentuais | Sufixo `%` | `Growth Rate %` |
| Comparações | Usar `vs` | `Sales vs PY`, `Variance vs Budget` |

---

## DAX - Regras Obrigatórias

### SEMPRE fazer:
1. **Usar VAR** para valores reutilizados
2. **DIVIDE()** em vez de `/` (evita erro divisão por zero)
3. **Preferir agregadores** (SUM, COUNT) sobre iteradores (SUMX, COUNTX)
4. **Indentar** código para legibilidade

### NUNCA fazer:
1. Usar `FILTER(ALL(...))` sem necessidade real
2. Calcular o mesmo valor múltiplas vezes
3. Usar `/` para divisão (risco de erro)
4. Criar medida sem documentação

### Exemplo de medida correta:
```dax
// 📈 COMPARAÇÃO | Crescimento ano a ano
// Calcula variação percentual vs mesmo período ano anterior
Sales Growth YoY % =
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = DIVIDE(CurrentSales - PreviousSales, PreviousSales)
RETURN Growth
```

---

## Documentação Obrigatória

Toda medida DEVE ter:

### 1. Comentário de Cabeçalho
```dax
// EMOJI CATEGORIA | Descrição breve
// Regra de negócio ou contexto adicional
```

### 2. Emojis Padrão
| Emoji | Categoria | Uso |
|-------|-----------|-----|
| 📊 | MÉTRICA BASE | Agregações simples (SUM, COUNT) |
| 🔄 | TIME INTELLIGENCE | YTD, PY, MTD, etc. |
| 📈 | COMPARAÇÃO | Variações, growth, vs Budget |
| 🎯 | KPI | Indicadores-chave |
| 🔧 | HELPER | Medidas auxiliares (ocultas) |
| 📦 | MIGRADO | Medidas migradas de outro modelo |
| ✨ | NOVO | Medidas recém-criadas |

### 3. Annotations Obrigatórias
```json
{
  "annotations": [
    {"key": "Purpose", "value": "Objetivo de negócio"},
    {"key": "BusinessRule", "value": "Lógica de cálculo"},
    {"key": "CreatedDate", "value": "YYYY-MM-DD"},
    {"key": "CreatedBy", "value": "Claude"}
  ]
}
```

### 4. Para Medidas Migradas (adicionar):
```json
{
  "annotations": [
    {"key": "MigrationSource", "value": "Nome do modelo origem"},
    {"key": "MigrationDate", "value": "YYYY-MM-DD"},
    {"key": "OriginalTable", "value": "Tabela original"}
  ]
}
```

---

## Checklist Antes de Criar Medida

- [ ] Nome segue convenção (Title Case, espaços)?
- [ ] Usa VAR para cálculos repetidos?
- [ ] Usa DIVIDE() em vez de `/`?
- [ ] Tem comentário com emoji + categoria?
- [ ] Tem description explicando negócio?
- [ ] Tem annotations obrigatórias?
- [ ] Format string apropriado (#,0 / 0.0% / R$ #,0.00)?
- [ ] Validou sintaxe com `dax_query_operations:Validate`?

---

## Referências

Para detalhes completos, consulte:
- `best-practices/naming-conventions.md`
- `best-practices/dax-patterns.md`
- `best-practices/dax-comments.md`
- `best-practices/modeling-principles.md`
- `best-practices/performance-tips.md`
