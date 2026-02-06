---
description: Migrar medidas entre modelos Power BI
---

# Workflow: Migrar Medidas

Este workflow migra medidas de um modelo antigo para um novo modelo Power BI.

## Agentes Envolvidos

- [migration-planner](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/migration/migration-planner.md) - Planejamento e análise de dependências
- [migration-executor](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/migration/migration-executor.md) - Execução da migração e validação
- [data-modeler](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/data-modeler.md) - Preparação do modelo de destino
- [dax-specialist](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/dax-specialist.md) - Refatoração e organização de medidas
- [quality-validator](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/quality-validator.md) - Validação final das medidas migradas
- [documentation-expert](file:///c:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI%20-%20Copia/agents/development/documentation-expert.md) - Exportação e documentação

## Pré-requisitos
- Conexão com modelo de ORIGEM
- Conexão com modelo de DESTINO (ou capacidade de criar segundo connection)
- Lista de medidas a migrar

## Tempo Estimado
30-60 minutos

## Passos

### 1. Planejar Migração (migration-planner)

**1.1. Listar medidas no modelo antigo:**
```json
{
  "operation": "List",
  "connectionName": "source-model"
}
```

**1.2. Identificar medidas a migrar:**
- [ ] Todas as medidas?
- [ ] Apenas medidas específicas?
- [ ] Excluir medidas deprecated?

**1.3. Analisar dependências:**
Para cada medida:
- Quais outras medidas ela usa?
- Quais tabelas/colunas ela referencia?
- Ordem de migração necessária?

**1.4. Verificar compatibilidade de nomes:**
- Tabelas no destino têm mesmos nomes?
- Colunas existem?
- Necessário renomear algo?

### 2. Preparar Modelo de Destino (data-modeler)

**2.1. Verificar tabela de medidas existe:**
```json
{
  "operation": "List",
  "connectionName": "target-model"
}
```

Se não existir, criar:
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Measures",
    "daxExpression": "ROW(\"Dummy\", BLANK())"
  }
}
```

**2.2. Validar tabelas/colunas necessárias:**
Para cada dependência identificada, confirmar existe no destino.

### 3. Exportar Medidas do Modelo Antigo (documentation-expert)

Para cada medida a migrar:

```json
{
  "operation": "ExportTMDL",
  "measureName": "Total Sales",
  "connectionName": "source-model"
}
```

**Salve em arquivo ou copie JSON para documentação.**

### 4. Mapear Mudanças Necessárias (migration-planner)

Crie tabela de mapping:

| Medida Antiga | Mudanças Necessárias | Medida Nova |
|---------------|----------------------|-------------|
| Total Sales | Nenhuma | Total Sales |
| Rev by Product | Tabela: Products → DimProduct | Revenue by Product |
| Old Metric | Deprecated | (não migrar) |

### 5. Executar Migração (migration-executor)

Para cada medida, NESTA ORDEM:

**5.1. Medidas sem dependências primeiro**
**5.2. Depois medidas que dependem de outras**

**Template de migração:**
```json
{
  "operation": "Create",
  "connectionName": "target-model",
  "createDefinition": {
    "name": "Total Sales",
    "tableName": "Measures",
    "expression": "[expressão do modelo antigo, ajustada]",
    "description": "📦 MIGRADO | [descrição original]\n\nMigrado de: modelo-antigo\nData: 2025-02-05",
    "displayFolder": "[pasta original ou nova]",
    "formatString": "[formato original]",
    "annotations": [
      {"key": "MigrationSource", "value": "modelo-antigo"},
      {"key": "MigrationDate", "value": "2025-02-05"},
      {"key": "OriginalName", "value": "[se renomeado]"}
    ]
  }
}
```

**IMPORTANTE:**
- Prefixe description com `📦 MIGRADO`
- Adicione annotations de migração
- Ajuste referências de tabelas/colunas se necessário

### 6. Validar Cada Medida (migration-executor)

Após criar cada medida, **teste imediatamente**:

```json
{
  "operation": "Execute",
  "query": "EVALUATE ROW(\"Old\", [OldMeasure], \"New\", [NewMeasure])",
  "connectionName": "comparison"
}
```

**Validações:**
- [ ] Nova medida funciona sem erro?
- [ ] Resultado é igual ou próximo ao antigo?
- [ ] Se diferente, é esperado?

### 7. Organizar Medidas Migradas (dax-specialist)

**7.1. Criar pasta de display:**
```
Migrated\
  Migrated\Sales
  Migrated\Finance
  Migrated\Operations
```

**7.2. Mover medidas para pastas apropriadas:**
```json
{
  "operation": "Update",
  "updateDefinition": {
    "name": "Total Sales",
    "displayFolder": "Sales\\Base"
  }
}
```

### 8. Refatorar (Opcional) (dax-specialist)

Se medidas antigas usam má prática, refatore:

**Exemplo - adicionar variáveis:**
```dax
// ANTIGO
Growth = [Sales] - [Sales PY] / [Sales PY]

// NOVO
Growth = 
VAR Current = [Sales]
VAR Previous = [Sales PY]
RETURN
DIVIDE(Current - Previous, Previous)
```

### 9. Validação Final (quality-validator)

Executar auditoria nas medidas migradas:

**9.1. Verificar nomenclatura:**
- [ ] Nomes seguem convenção?
- [ ] Display folders organizadas?

**9.2. Verificar documentação:**
- [ ] Todas têm `📦 MIGRADO` na description?
- [ ] Annotations de migração presentes?
- [ ] Format strings corretos?

**9.3. Testar sample de medidas:**
Escolha 5-10 medidas críticas e teste valores.

### 10. Documentar Migração (documentation-expert)

**10.1. Criar relatório de migração:**
```markdown
# Relatório de Migração de Medidas

**Data:** 2025-02-05
**Modelo Origem:** vendas-v2
**Modelo Destino:** vendas-v3

## Resumo
- Total medidas analisadas: 50
- Medidas migradas: 45
- Medidas descartadas: 3
- Medidas refatoradas: 2

## Medidas Migradas
- Total Sales ✅
- Sales YTD ✅
- Growth % ✅ (refatorada)
...

## Medidas NÃO Migradas
- Old Revenue (deprecated)
- Test Measure (não necessária)

## Mudanças Aplicadas
- Tabela Products → DimProduct (20 medidas)
- Adicionadas variáveis (2 medidas)
```

**10.2. Exportar TMDL do modelo novo:**
```json
{
  "operation": "ExportTMDL",
  "filePath": "C:\\migration\\target-model-after.tmdl"
}
```

## Checklist Final

### Planejamento
- [ ] Medidas listadas
- [ ] Dependências mapeadas
- [ ] Mudanças identificadas
- [ ] Ordem de migração definida

### Execução
- [ ] Todas as medidas migradas
- [ ] Cada medida testada individualmente
- [ ] Annotations de migração adicionadas
- [ ] Display folders organizadas

### Validação
- [ ] Auditoria executada
- [ ] Sample de medidas testado
- [ ] Valores conferidos com origem

### Documentação
- [ ] Relatório de migração criado
- [ ] TMDL exportado
- [ ] Mudanças documentadas

## Dicas

**Para muitas medidas (>50):**
- Considere migrar em lotes
- Teste cada lote antes do próximo
- Priorize medidas críticas

**Para medidas complexas:**
- Exporte TMDL completo primeiro
- Analise dependências cuidadosamente
- Teste extensivamente

**Se encontrar erros:**
- Valide que tabelas/colunas existem
- Verifique data types compatíveis
- Use quality-validator para diagnóstico

**Rollback:**
- Mantenha TMDL do modelo origem
- Documente cada mudança
- Teste em ambiente não-produção primeiro

## Exemplo de Mapping

```markdown
| Origem | Destino | Mudanças |
|--------|---------|----------|
| TotalRev | Total Revenue | Renomeado |
| Rev_Product | Revenue by Product | Renomeado, tabela: Products→DimProduct |
| SalesQty | Total Quantity | Renomeado |
| OldMetric | - | NÃO MIGRAR (deprecated) |
```

---

**Tempo estimado:** 30-60 minutos (depende do número de medidas)
**Frequência:** Conforme necessário para migrações de modelo
