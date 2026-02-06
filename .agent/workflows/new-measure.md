---
description: Criar nova medida DAX com documentação completa
---

# Workflow: Nova Medida DAX

Este workflow cria uma medida DAX seguindo todas as best practices.

## Agentes Envolvidos

- [dax-specialist](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/dax-specialist.md) - Criação e validação de medidas DAX
- [quality-validator](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/quality-validator.md) - Validação de qualidade da medida
- [documentation-expert](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/documentation-expert.md) - Documentação de medidas complexas

## Pré-requisitos
- Conexão ativa com modelo Power BI
- Saber qual medida você quer criar

## Passos

### 1. Definir Requisito
Descreva claramente o que a medida deve calcular:
- Qual é a métrica de negócio?
- Qual a fórmula esperada?
- Há cálculos time intelligence envolvidos?

### 2. Validar DAX (dax-specialist)
Antes de criar, valide a sintaxe:
```
Use dax_query_operations com operation: "Validate"
Forneça a expressão DAX que você planeja usar
```

### 3. Criar a Medida (dax-specialist)
Use o agente dax-specialist com as seguintes instruções OBRIGATÓRIAS:

**Elementos obrigatórios:**
- [ ] Nome em Title Case (ex: "Total Sales", "Growth %")
- [ ] Expression usando variáveis (VAR)
- [ ] Description com emoji prefix (✨ NEW / 📦 MIGRADO / 🔧 HELPER)
- [ ] FormatString apropriado
- [ ] DisplayFolder para organização
- [ ] Annotations (Purpose, CreatedDate, CreatedBy)

**Exemplo de request:**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Total Sales",
    "tableName": "Measures",
    "expression": "VAR Result = SUM(FactSales[SalesAmount])\nRETURN Result",
    "description": "✨ NEW | Total de vendas brutas.\n\nAgrega todos os valores de vendas.",
    "displayFolder": "Sales\\Base",
    "formatString": "R$ #,##0.00",
    "annotations": [
      {"key": "Purpose", "value": "Métrica base de vendas"},
      {"key": "CreatedDate", "value": "2025-02-05"},
      {"key": "CreatedBy", "value": "dax-specialist"}
    ]
  }
}
```

### 4. Testar a Medida
Execute uma query simples para validar:
```
Use dax_query_operations com operation: "Execute"
Query: "EVALUATE ROW(\"Result\", [Nome da Medida])"
```

### 5. Validar Qualidade (quality-validator)
Execute validação rápida:
```
Verifique:
- [ ] Nome segue convenção?
- [ ] Description existe e está completa?
- [ ] FormatString apropriado?
- [ ] Annotations presentes?
- [ ] Em display folder?
```

### 6. Documentar (documentation-expert)
Se a medida é complexa, adicione documentação extra:
```
- Explique a lógica de negócio
- Documente variáveis usadas
- Liste dependências
```

## Checklist Final

Antes de considerar concluído:
- [ ] Medida criada sem erros
- [ ] Sintaxe DAX válida
- [ ] Description completa
- [ ] FormatString correto
- [ ] DisplayFolder definido
- [ ] Annotations adicionadas
- [ ] Testada com dados reais
- [ ] Validada pelo quality-validator

## Dicas

**Para medidas simples:**
- Pule etapa 6 (documentação extra)

**Para medidas time intelligence:**
- Certifique-se que Date Table está marcada
- Use funções TIME INTELLIGENCE nativas (TOTALYTD, etc)

**Para medidas helper (auxiliares):**
- Prefixe com `_` (ex: `_Base Sales`)
- Marque como hidden: `isHidden: true`

**Performance:**
- Use variáveis para cálculos repetidos
- Prefira SUM/COUNT a SUMX/COUNTX quando possível
- Use DIVIDE em vez de `/`

## Exemplos

### Medida Simples
Nome: `Total Quantity`
Pasta: `Sales\Base`

### Medida Time Intelligence
Nome: `Sales YTD`
Pasta: `Sales\Time Intelligence`

### Medida Comparação
Nome: `Sales vs PY`
Pasta: `Sales\Comparisons`

---

**Tempo estimado:** 5-10 minutos por medida
