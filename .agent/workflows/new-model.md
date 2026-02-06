---
description: Criar modelo Star Schema completo do zero
---

# Workflow: Criar Novo Modelo

Este workflow cria um modelo Star Schema completo do zero seguindo best practices.

## Agentes Envolvidos

- [business-analyst](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/analytics/business-analyst.md) - Levantamento de requisitos de negócio
- [data-modeler](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/data-modeler.md) - Criação de tabelas e estrutura
- [relationship-architect](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/relationship-architect.md) - Criação de relacionamentos
- [dax-specialist](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/dax-specialist.md) - Criação de medidas
- [quality-validator](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/quality-validator.md) - Validação do modelo
- [documentation-expert](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/documentation-expert.md) - Documentação final

## Pré-requisitos
- Conexão ativa com Power BI Desktop
- Definição clara do que modelar (vendas, inventário, etc)
- Dados disponíveis (ou mockup)

## Tempo Estimado
30-60 minutos para modelo básico

## Passos

### 1. Levantamento de Requisitos (business-analyst)

**1.1. Definir perguntas de negócio:**
- Quais KPIs precisam ser respondidos?
- Quais dimensões de análise (produto, tempo, cliente)?
- Qual período de tempo cobrir?

**1.2. Definir grain (nível de detalhe):**
Exemplo: "Uma linha por item vendido em cada pedido"

**1.3. Listar dimensões necessárias:**
- [ ] DimDate (obrigatória)
- [ ] DimProduct
- [ ] DimCustomer
- [ ] DimSalesRep
- [ ] Outras?

**1.4. Identificar métricas:**
- [ ] Total Sales
- [ ] Total Quantity
- [ ] Profit
- [ ] Outras?

### 2. Criar Tabela de Medidas (data-modeler)

// turbo
Crie tabela placeholder para medidas:
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Measures",
    "description": "Tabela para organizar todas as medidas",
    "daxExpression": "ROW(\"Dummy\", BLANK())",
    "isHidden": true
  }
}
```

### 3. Criar Date Table (data-modeler)

Use o agente data-modeler:

**Opção 1 - DAX:**
```dax
DimDate = 
CALENDAR(DATE(2020, 1, 1), DATE(2030, 12, 31))
```

**Adicionar colunas:**
- Year, Quarter, Month, Day
- WeekDay, MonthName
- YearMonth, YearQuarter

**Marcar como Date Table:**
```json
{
  "operation": "MarkAsDateTable",
  "tableName": "DimDate",
  "dateColumn": "Date"
}
```

### 4. Criar Dimensões (data-modeler)

Para cada dimensão (Product, Customer, etc):

**4.1. Criar tabela:**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "DimProduct",
    "description": "Dimensão de produtos",
    "columns": [
      {
        "name": "ProductKey",
        "dataType": "Int64",
        "isKey": true
      },
      {
        "name": "ProductName",
        "dataType": "String"
      },
      {
        "name": "Category",
        "dataType": "String"
      },
      {
        "name": "Price",
        "dataType": "Decimal",
        "formatString": "R$ #,##0.00"
      }
    ]
  }
}
```

**4.2. Repetir para outras dimensões**

### 5. Criar Tabela Fato (data-modeler)

```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "FactSales",
    "description": "Fato de vendas (grain: linha de pedido)",
    "columns": [
      {
        "name": "SalesKey",
        "dataType": "Int64",
        "isKey": true
      },
      {
        "name": "ProductKey",
        "dataType": "Int64"
      },
      {
        "name": "CustomerKey",
        "dataType": "Int64"
      },
      {
        "name": "DateKey",
        "dataType": "Int64"
      },
      {
        "name": "OrderDate",
        "dataType": "DateTime"
      },
      {
        "name": "Quantity",
        "dataType": "Int64"
      },
      {
        "name": "UnitPrice",
        "dataType": "Decimal"
      },
      {
        "name": "SalesAmount",
        "dataType": "Decimal",
        "formatString": "R$ #,##0.00"
      }
    ]
  }
}
```

### 6. Criar Relacionamentos (relationship-architect)

Para cada par Fact → Dimension:

```json
{
  "operation": "Create",
  "relationshipDefinition": {
    "name": "FactSales_DimProduct",
    "fromTable": "DimProduct",
    "fromColumn": "ProductKey",
    "toTable": "FactSales",
    "toColumn": "ProductKey",
    "fromCardinality": "One",
    "toCardinality": "Many",
    "crossFilteringBehavior": "OneDirection",
    "isActive": true
  }
}
```

**Repita para:**
- [ ] FactSales → DimDate
- [ ] FactSales → DimCustomer
- [ ] FactSales → DimSalesRep (se houver)

### 7. Criar Medidas Base (dax-specialist)

**7.1. Total Sales**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Total Sales",
    "tableName": "Measures",
    "expression": "SUM(FactSales[SalesAmount])",
    "description": "✨ NEW | Total de vendas brutas",
    "displayFolder": "Sales\\Base",
    "formatString": "R$ #,##0.00"
  }
}
```

**7.2. Total Quantity**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Total Quantity",
    "tableName": "Measures",
    "expression": "SUM(FactSales[Quantity])",
    "description": "✨ NEW | Quantidade total vendida",
    "displayFolder": "Sales\\Base",
    "formatString": "#,##0"
  }
}
```

**7.3. Average Price**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Average Price",
    "tableName": "Measures",
    "expression": "DIVIDE([Total Sales], [Total Quantity])",
    "description": "✨ NEW | Preço médio por unidade",
    "displayFolder": "Sales\\Base",
    "formatString": "R$ #,##0.00"
  }
}
```

### 8. Criar Medidas Time Intelligence (dax-specialist)

**8.1. Sales YTD**
```dax
Sales YTD = TOTALYTD([Total Sales], DimDate[Date])
```

**8.2. Sales PY (Prior Year)**
```dax
Sales PY = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(DimDate[Date]))
```

**8.3. YoY Growth %**
```dax
YoY Growth % = 
VAR Current = [Total Sales]
VAR Previous = [Sales PY]
RETURN
DIVIDE(Current - Previous, Previous)
```

### 9. Validar Modelo (quality-validator)

Execute auditoria rápida:
- [ ] Todas as tabelas seguem Dim/Fact?
- [ ] Relacionamentos são 1:N single-direction?
- [ ] Todas as medidas têm description?
- [ ] Date Table marcada?

### 10. Documentar (documentation-expert)

**10.1. Tabelas:**
Adicione description a cada tabela explicando:
- O que contém
- Grain (para facts)
- Fonte dos dados

**10.2. Medidas:**
Garantir todas têm:
- Description completa
- Annotations (Purpose, CreatedDate)
- Format string
- Display folder

**10.3. Exportar TMDL (opcional):**
```json
{
  "operation": "ExportTMDL",
  "filePath": "C:\\docs\\model-documentation.tmdl"
}
```

## Checklist Final

### Estrutura
- [ ] Tabela Measures criada
- [ ] DimDate criada e marcada
- [ ] Dimensões criadas com chaves
- [ ] Fact criada com grain definido

### Relacionamentos
- [ ] Fact → Dimensions (1:N)
- [ ] Direção Single
- [ ] Todos ativos

### Medidas
- [ ] Base measures (Sum, Count)
- [ ] Time intelligence (YTD, PY)
- [ ] Comparisons (Growth, vs PY)
- [ ] Todas documentadas

### Qualidade
- [ ] Nomenclatura consistente
- [ ] Documentation completa
- [ ] Validação executada

## Exemplo de Estrutura Final

```
Model: Sales Model
├── Measures (hidden table)
├── DimDate
│   └── Relacionamento → FactSales.OrderDate
├── DimProduct
│   └── Relacionamento → FactSales.ProductKey
├── DimCustomer
│   └── Relacionamento → FactSales.CustomerKey
└── FactSales
    └── Grain: Uma linha por item vendido

Medidas:
├── Sales\Base
│   ├── Total Sales
│   ├── Total Quantity
│   └── Average Price
├── Sales\Time Intelligence
│   ├── Sales YTD
│   ├── Sales MTD
│   └── Sales PY
└── Sales\Comparisons
    ├── YoY Growth %
    └── Sales vs PY
```

---

**Tempo estimado:** 30-60 minutos
**Resultado:** Modelo Star Schema completo e documentado
