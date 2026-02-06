# Getting Started - Power BI Agent Kit

Este guia explica como começar a usar o Power BI Agent Kit para desenvolvimento, análise e migração de modelos semânticos.

## Pré-requisitos

### 1. Power BI Desktop ou Fabric
- Power BI Desktop instalado localmente, OU
- Acesso a um workspace Fabric com modelo semântico

### 2. Power BI MCP Server
O MCP Server deve estar configurado e rodando. Verifique com:
```
connection_operations: ListLocalInstances
```

### 3. Modelo Conectado
Conecte-se ao modelo antes de usar os agentes:
```
connection_operations: Connect
dataSource: localhost:<port>
```

## Primeiros Passos

### Passo 1: Verificar Conexão

```json
{
  "operation": "ListConnections"
}
```

Se nenhuma conexão ativa, use:
```json
{
  "operation": "Connect",
  "dataSource": "localhost:PORTA"
}
```

### Passo 2: Explorar o Modelo

Use o quality-validator para uma visão geral:
```
- model_operations: Get (estrutura do modelo)
- table_operations: List (tabelas existentes)
- measure_operations: List (medidas existentes)
- relationship_operations: List (relacionamentos)
```

### Passo 3: Escolher o Agente Certo

| Tarefa | Agente |
|--------|--------|
| Criar tabelas | data-modeler |
| Criar relacionamentos | relationship-architect |
| Criar medidas | dax-specialist |
| Validar modelo | quality-validator |
| Documentar | documentation-expert |
| Analisar dados | insight-generator |
| Planejar migração | migration-planner |

## Fluxos de Trabalho Comuns

### Criar uma Nova Medida

1. **Defina o requisito** (business-analyst ou você mesmo)
2. **Crie a medida** (dax-specialist)
   - Valide sintaxe
   - Adicione descrição
   - Configure formato
   - Organize em pasta
3. **Valide** (quality-validator)
4. **Documente** (documentation-expert)

**Exemplo:**
```json
{
  "operation": "Create",
  "createDefinition": {
    "name": "Total Sales",
    "tableName": "Measures",
    "expression": "SUM(FactSales[SalesAmount])",
    "description": "✨ NEW | Total de vendas brutas.\n\nAgrega todos os valores de vendas da tabela de fatos.",
    "displayFolder": "Sales\\Base",
    "formatString": "R$ #,##0.00",
    "annotations": [
      {"key": "Purpose", "value": "Cálculo do total de vendas"},
      {"key": "CreatedDate", "value": "2025-01-15"},
      {"key": "CreatedBy", "value": "dax-specialist"}
    ]
  }
}
```

### Criar um Modelo Star Schema

1. **Planeje o schema** (data-modeler)
   - Identifique fato e dimensões
   - Defina grain
   - Liste colunas

2. **Crie dimensões primeiro** (data-modeler)
   - DimDate
   - DimProduct
   - DimCustomer
   - etc.

3. **Crie tabela fato** (data-modeler)
   - FactSales com foreign keys

4. **Crie relacionamentos** (relationship-architect)
   - Fact → Dim (1:N, Single direction)

5. **Crie medidas** (dax-specialist)
   - Base measures
   - Time intelligence
   - KPIs

6. **Valide** (quality-validator)

7. **Documente** (documentation-expert)

### Migrar Medidas de Outro Modelo

1. **Analise o modelo fonte** (migration-planner)
   - Inventário de objetos
   - Dependências
   - Complexidade

2. **Crie plano de migração** (migration-planner)
   - Ordem de execução
   - Transformações necessárias
   - Plano de rollback

3. **Execute a migração** (migration-executor)
   - Siga a ordem do plano
   - Adicione metadados de migração
   - Valide cada objeto

4. **Valide resultados** (quality-validator)

5. **Documente** (documentation-expert)

## Convenções Importantes

### Nomenclatura (veja naming-conventions.md)

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Tabela Fato | `Fact*` | `FactSales` |
| Tabela Dimensão | `Dim*` | `DimProduct` |
| Chave | `*Key` ou `*ID` | `ProductKey` |
| Data | `*Date` | `OrderDate` |
| Boolean | `Is*`/`Has*` | `IsActive` |
| Medida | Title Case | `Total Sales` |
| Medida YTD | `* YTD` | `Sales YTD` |
| Medida PY | `* PY` | `Sales PY` |

### Documentação (veja dax-comments.md)

**Toda medida DEVE ter:**
1. Description com emoji prefix
2. Annotations obrigatórias
3. Format string apropriado
4. Display folder

**Emojis de prefix:**
- 📦 MIGRADO - Objeto migrado
- ✨ NEW - Objeto novo
- 🔧 HELPER - Medida auxiliar
- ⚠️ DEPRECATED - Depreciado

## Dicas de Sucesso

### Sempre faça
- ✅ Valide DAX antes de criar
- ✅ Adicione descrições completas
- ✅ Siga convenções de nomenclatura
- ✅ Use variáveis em DAX complexo
- ✅ Documente regras de negócio

### Nunca faça
- ❌ Criar medidas sem documentação
- ❌ Usar nomes genéricos (Table1, Measure1)
- ❌ Ignorar erros de validação
- ❌ Misturar idiomas em nomes
- ❌ Criar Related Columns calculadas

## Solução de Problemas

### "No active connection"
```json
{
  "operation": "Connect",
  "dataSource": "localhost:PORTA"
}
```

### "Object already exists"
1. Verifique se o objeto já existe
2. Use `Get` para comparar
3. Delete primeiro se necessário, ou
4. Use `Update` para modificar

### "Invalid DAX expression"
1. Use `dax_query_operations: Validate`
2. Verifique referências a tabelas/colunas
3. Confirme que dependências existem

### "Relationship creates circular dependency"
1. Identifique o caminho circular
2. Torne uma relação inativa, ou
3. Mude para direção única

## Próximos Passos

1. Leia os documentos de best practices
2. Explore os agentes disponíveis
3. Pratique com exemplos simples
4. Crie suas próprias medidas com documentação completa
5. Valide regularmente com quality-validator

---

**Precisa de ajuda?** Use o agente apropriado ou consulte a documentação em `best-practices/`.
