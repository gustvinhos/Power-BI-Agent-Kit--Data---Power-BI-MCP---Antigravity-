---
trigger: always_on
---

# Antigravity Rules - Power BI Agent Kit

Regras e diretrizes para o Antigravity trabalhar com o Power BI Agent Kit.

---

## 🌐 Idioma e Comunicação

### Regra de Idioma Principal
- **SEMPRE responda em Português (Brasil)**
- **Mantenha termos técnicos em inglês**:
  - Funções DAX (SUM, CALCULATE, DIVIDE, etc.)
  - Nomes de tabelas/colunas (FactSales, DimProduct, ProductKey)
  - Features do Power BI (Time Intelligence, Display Folder, etc.)
  - Operações MCP (measure_operations, table_operations, etc.)

### Exemplos de Comunicação Correta
✅ **CORRETO:**
> "Vou criar a medida `Total Sales` usando a função `SUM` na tabela `FactSales`. A medida será organizada no Display Folder `Sales\Base`."

❌ **INCORRETO:**
> "I will create the measure Total Sales using SUM function..." (inglês completo)
> "Vou criar a medida Vendas Totais usando a função SOMA..." (traduzindo termos técnicos)

---

## 🤖 Sistema de Agentes

### Estrutura do Kit
O projeto possui **14 agentes especializados** em 4 categorias:

#### Development Team (6 agentes)
- `data-modeler` - Tabelas, colunas, Star/Snowflake schema
- `dax-specialist` - Medidas, KPIs, time intelligence
- `relationship-architect` - Relacionamentos, cardinalidade, filtros
- `performance-optimizer` - Tuning de queries, otimização
- `quality-validator` - Auditorias, validação de best practices
- `documentation-expert` - Descrições, exports TMDL, metadados

#### Analytics Team (4 agentes)
- `business-analyst` - Requisitos, perguntas de negócio
- `insight-generator` - Padrões, anomalias
- `report-designer` - Layout de dashboards
- `data-storyteller` - Narrativas, apresentações

#### Migration Team (2 agentes)
- `migration-planner` - Planejamento, análise de impacto
- `migration-executor` - Execução de migrações

#### Meta Team (2 agentes)
- `operations-manager` - Coordenação de workflows
- `prompt-engineer` - Criação de prompts

### Como Usar os Agentes

**Quando o usuário mencionar um agente específico:**
1. Leia o arquivo do agente em `agents/[categoria]/[nome-agente].md`
2. Siga TODAS as instruções e best practices do agente
3. Use as ferramentas MCP conforme especificado pelo agente
4. Aplique os padrões de documentação obrigatórios

**Exemplo:**
```
Usuário: "Use o dax-specialist para criar uma medida de YoY Growth"

Você deve:
1. Ler agents/development/dax-specialist.md
2. Seguir o workflow de criação de medidas
3. Aplicar padrões DAX obrigatórios (VAR, DIVIDE, etc.)
4. Adicionar documentação completa (description, annotations, comments)
5. Validar sintaxe com dax_query_operations
6. Testar a medida
```

---

## 🔧 Power BI MCP Operations

### Conexão com Modelos

**SEMPRE verifique a conexão antes de qualquer operação:**
```
1. Use connection_operations para verificar conexão ativa
2. Se não houver conexão, liste instâncias locais ou conecte ao Fabric
3. Confirme qual modelo está ativo
```

### Operações Disponíveis

#### Modelagem
- `table_operations` - Create, Update, Delete, GetSchema, ExportTMDL
- `column_operations` - Create, Update, Delete, List
- `measure_operations` - Create, Update, Move, Rename, ExportTMDL
- `relationship_operations` - Create, Update, Activate, Deactivate

#### Análise
- `dax_query_operations` - Execute, Validate, GetExecutionMetrics
- `model_operations` - Get, GetStats, Refresh

#### Documentação
- Todos os `*_operations` têm `ExportTMDL` disponível
- Use para exportar objetos em formato YAML-like

#### Batch Operations
Para múltiplos objetos, use:
- `batch_measure_operations`
- `batch_column_operations`
- `batch_table_operations`
- `batch_function_operations`

---

## 📝 Naming Conventions (OBRIGATÓRIO)

### Tabelas
- **Fato**: `FactNomeDaTabela` (ex: `FactSales`, `FactOrders`)
- **Dimensão**: `DimNomeDaTabela` (ex: `DimProduct`, `DimCustomer`)
- **Calculada**: `CalcNomeDaTabela` ou `NomeDaTabela` (ex: `Measures`)
- **Parâmetro**: `ParamNomeDaTabela` (ex: `ParamDateRange`)

### Colunas
- **Chaves**: `NomeDaTabelaKey` ou `NomeDaTabelaID` (ex: `ProductKey`, `CustomerID`)
- **Datas**: `DescriçãoDate` (ex: `OrderDate`, `ShipDate`)
- **Booleans**: `Is/Has/Should/Can + Descrição` (ex: `IsActive`, `HasDiscount`)

### Medidas (CRÍTICO)
- **Formato**: Title Case com espaços (ex: `Total Sales`, `Growth Rate %`)
- **Agregações**: `[Tipo] [Campo]` (ex: `Total Sales`, `Count Orders`)
- **Time Intelligence**: Sufixos `YTD`, `MTD`, `QTD`, `PY`, `PM`, `PQ`
  - Exemplos: `Sales YTD`, `Revenue PY`, `Orders MTD`
- **Comparações**: Usar `vs` (ex: `Sales vs PY`, `Revenue vs Budget`)
- **Percentuais**: Sufixo `%` ou `Percent` (ex: `Growth Rate %`, `Profit Margin %`)
- **Helpers**: Prefixo `_` + `isHidden: true` (ex: `_Base Sales`, `_Selected Period`)

### Display Folders
Organize medidas em hierarquias lógicas:
```
Sales\Base
Sales\Time Intelligence
Sales\Comparisons
Sales\KPIs
Finance\Revenue
Finance\Costs
Operations\Inventory
```

---

## 📚 Documentação Obrigatória

### Para TODAS as Medidas

#### 1. Description (OBRIGATÓRIO)
Formato:
```
[EMOJI] [CATEGORIA] | [Descrição breve]

[Explicação detalhada da lógica de negócio]
[Notas sobre tratamento de erros, se aplicável]
```

Emojis padrão:
- ✨ NEW - Medidas novas
- 📦 MIGRADO DO [SOURCE] - Medidas migradas
- 🔧 HELPER - Medidas auxiliares
- ⚠️ DEPRECATED - Medidas obsoletas

Exemplo:
```
✨ NEW | Crescimento Year-over-Year de vendas.

Calcula a taxa de crescimento comparando vendas do período atual com o mesmo período do ano anterior. Usa DIVIDE para evitar erros de divisão por zero.
```

#### 2. Annotations (OBRIGATÓRIO)
Todas as medidas DEVEM ter:
```json
{
  "annotations": [
    {"key": "Purpose", "value": "Objetivo de negócio da medida"},
    {"key": "BusinessRule", "value": "Lógica de cálculo em linguagem simples"},
    {"key": "Dependencies", "value": "Tabelas, colunas ou medidas usadas"},
    {"key": "CreatedDate", "value": "YYYY-MM-DD"},
    {"key": "CreatedBy", "value": "Nome do agente ou usuário"}
  ]
}
```

**Para medidas migradas, adicione:**
```json
{
  "annotations": [
    {"key": "MigrationSource", "value": "V3"},
    {"key": "MigrationDate", "value": "YYYY-MM-DD"},
    {"key": "OriginalTable", "value": "Nome da tabela original"},
    {"key": "OriginalModel", "value": "Nome do modelo original"}
  ]
}
```

#### 3. DAX Comments (OBRIGATÓRIO)

**Medidas Simples (1-2 linhas):**
```dax
// [EMOJI] [CATEGORIA] | [Descrição breve]
// [Regra de negócio ou contexto adicional]
MeasureName = EXPRESSION
```

**Medidas Complexas (3+ linhas ou múltiplas variáveis):**
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
*/
MeasureName = 
VAR Variable1 = EXPRESSION
VAR Variable2 = EXPRESSION
RETURN EXPRESSION
```

#### 4. Format String (OBRIGATÓRIO)
- Inteiros: `#,0`
- Decimais: `#,0.00`
- Percentuais: `0.0%` ou `0.00%`
- Moeda: `R$ #,##0.00` ou `$ #,##0.00`

#### 5. Display Folder
Organize medidas relacionadas em pastas lógicas usando `\` como separador.

---

## 🎯 Best Practices DAX (OBRIGATÓRIO)

### 1. SEMPRE Use Variáveis
✅ **CORRETO:**
```dax
Sales Growth % = 
VAR CurrentSales = [Total Sales]
VAR PreviousSales = [Sales PY]
VAR Growth = DIVIDE(CurrentSales - PreviousSales, PreviousSales)
RETURN Growth
```

❌ **INCORRETO:**
```dax
Sales Growth % = DIVIDE([Total Sales] - [Sales PY], [Sales PY])
-- Calcula [Sales PY] duas vezes!
```

### 2. Prefira Agregadores a Iteradores
✅ **RÁPIDO:** `Total Sales = SUM(Sales[Amount])`
❌ **LENTO:** `Total Sales = SUMX(Sales, Sales[Amount])`

Use iteradores APENAS quando necessário (cálculos linha a linha).

### 3. Use DIVIDE, Nunca `/`
✅ **SEGURO:** `Margin % = DIVIDE([Profit], [Revenue], 0)`
❌ **ARRISCADO:** `Margin % = [Profit] / [Revenue]` (erro se Revenue = 0)

### 4. Evite FILTER(ALL(...)) em Tabelas Grandes
✅ **EFICIENTE:**
```dax
Electronics Sales = 
CALCULATE([Total Sales], Product[Category] = "Electronics")
```

❌ **MUITO LENTO:**
```dax
Electronics Sales = 
CALCULATE(
    [Total Sales],
    FILTER(ALL(Product), Product[Category] = "Electronics")
)
```

### 5. Checklist de Performance
Antes de criar qualquer medida:
- [ ] Usei variáveis para cálculos repetidos?
- [ ] Usei agregador ao invés de iterador quando possível?
- [ ] Usei DIVIDE ao invés de `/`?
- [ ] Evitei FILTER(ALL(...)) em tabelas grandes?
- [ ] O código está legível e bem formatado?
- [ ] Adicionei comentários explicando a lógica?

---

## 🔄 Workflows e Automação

### Workflows Disponíveis
O projeto tem 5 workflows principais em `.agent/workflows/`:

1. `/new-measure` - Criar nova medida DAX com documentação completa
2. `/new-model` - Criar modelo Star Schema completo do zero
3. `/migrate-measures` - Migrar medidas entre modelos Power BI
4. `/optimize-performance` - Otimizar performance de modelo e queries lentas
5. `/audit-model` - Auditar modelo Power BI completo (qualidade e performance)

### Como Executar Workflows

**Quando o usuário usar um slash command:**
1. Leia o arquivo `.agent/workflows/[nome-workflow].md`
2. Siga TODOS os passos do workflow na ordem
3. Use os agentes especificados em cada etapa
4. Complete todos os checklists antes de finalizar

**Exemplo:**
```
Usuário: "/new-measure para calcular YoY Growth"

Você deve:
1. Ler .agent/workflows/new-measure.md
2. Seguir os 6 passos do workflow
3. Usar dax-specialist para criação
4. Usar quality-validator para validação
5. Completar checklist final antes de confirmar
```

### Anotação // turbo
- Se um passo tem `// turbo` acima, auto-execute comandos run_command com `SafeToAutoRun: true`
- Se o workflow tem `// turbo-all`, auto-execute TODOS os comandos

---

## 📖 Referências de Best Practices

### Documentos Obrigatórios
Consulte SEMPRE antes de criar objetos:

1. **agents/best-practices/naming-conventions.md**
   - Padrões de nomenclatura para tabelas, colunas, medidas
   - Display folders e hierarquias
   - Anti-patterns a evitar

2. **agents/best-practices/dax-patterns.md**
   - Padrões DAX comprovados
   - Time Intelligence patterns
   - Performance optimization
   - Ranking, Running Totals, ABC Analysis

3. **agents/best-practices/dax-comments.md**
   - Padrões de comentários obrigatórios
   - Templates para medidas simples e complexas
   - Documentação de medidas migradas

4. **agents/best-practices/modeling-principles.md**
   - Star Schema design
   - Relacionamentos e cardinalidade
   - Princípios de modelagem dimensional

5. **agents/best-practices/performance-tips.md**
   - Otimização de queries DAX
   - Storage Engine vs Formula Engine
   - Técnicas de tuning

---

## ✅ Checklist Antes de Completar Qualquer Tarefa

### Para Criação de Medidas
- [ ] Nome em Title Case com espaços
- [ ] Description completa com emoji prefix
- [ ] Annotations obrigatórias (Purpose, BusinessRule, Dependencies, CreatedDate, CreatedBy)
- [ ] Annotations de migração se aplicável (MigrationSource, MigrationDate, OriginalTable)
- [ ] DAX comments seguindo padrão (simples ou complexo)
- [ ] FormatString apropriado (#,0 / #,0.00 / 0.0%)
- [ ] DisplayFolder definido
- [ ] Variáveis (VAR) para cálculos repetidos
- [ ] DIVIDE ao invés de `/`
- [ ] Helpers com prefixo `_` e isHidden=true
- [ ] Sintaxe validada com dax_query_operations:Validate
- [ ] Testada com dados reais

### Para Criação de Tabelas
- [ ] Prefixo correto (Fact/Dim/Calc/Param)
- [ ] Colunas com nomes descritivos
- [ ] Chaves terminam com Key ou ID
- [ ] Datas terminam com Date
- [ ] Description da tabela preenchida

### Para Relacionamentos
- [ ] Cardinalidade correta (1:*, *:1, 1:1)
- [ ] Direção de filtro apropriada (Single, Both)
- [ ] Relacionamento ativo ou inativo conforme necessário
- [ ] Testado com queries DAX
