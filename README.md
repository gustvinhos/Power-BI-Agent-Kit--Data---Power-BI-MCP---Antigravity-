# Power BI Expert System 🎯

Sistema completo de agentes especializados para desenvolvimento, modelagem e otimização de modelos Power BI usando o Power BI MCP (Model Context Protocol).

---

## 📋 Visão Geral

Este sistema fornece **6 agentes especializados** que trabalham como consultores experts em Power BI:

| Agente | Especialidade | Quando Usar |
|--------|---------------|-------------|
| **[Data Modeler](/.agents/agents/data-modeler.md)** | Modelagem dimensional (Star/Snowflake) | Criar tabelas, design de esquema, estrutura de dados |
| **[DAX Specialist](/.agents/agents/dax-specialist.md)** | Medidas e cálculos DAX | Criar medidas, KPIs, time intelligence |
| **[Relationship Architect](/.agents/agents/relationship-architect.md)** | Relacionamentos e integridade | Conectar tabelas, resolver relacionamentos |
| **[Performance Optimizer](/.agents/agents/performance-optimizer.md)** | Otimização de performance | Analisar lentidão, otimizar queries e modelos |
| **[Quality Validator](/.agents/agents/quality-validator.md)** | Validação e qualidade | Auditar modelos, validar boas práticas |
| **[Documentation Expert](/.agents/agents/documentation-expert.md)** | Documentação completa | Documentar modelos, exportar metadados |

---

## 🚀 Quick Start

### Pré-requisitos

1. **Power BI Desktop** instalado e em execução
2. **Power BI MCP** configurado (Model Context Protocol)
3. Um modelo Power BI aberto (ou pronto para criar novo)

### Primeiro Uso

**1. Conectar ao Power BI Desktop:**
```
Usar: connection_operations
Operação: Connect
DataSource: localhost:[porta] (veja Power BI Desktop)
```

**2. Verificar modelo atual:**
```
Usar: model_operations
Operação: Get
```

**3. Escolher agente apropriado** conforme necessidade

---

## 🎯 Como Usar Cada Agente

### 1. Data Modeler - Criando Modelo

**Cenário:** "Preciso criar um modelo de vendas com produtos e clientes"

**Agente:** `@data-modeler`

**O que ele faz:**
1. Planeja estrutura Star Schema
2. Cria tabela de datas (DimDate) primeiro
3. Cria dimensões (DimProduct, DimCustomer)
4. Cria fatos (FactSales)
5. Aplica convenções de nomenclatura automaticamente
6. Valida grão e estrutura

**Exemplo de uso:**
```
@data-modeler Create a sales model with product, customer, 
and date dimensions, plus a sales fact table at order line grain.
```

---

### 2. DAX Specialist - Criando Medidas

**Cenário:** "Preciso calcular crescimento YoY de vendas"

**Agente:** `@dax-specialist`

**O que ele faz:**
1. Cria medida base (Total Sales) se necessário
2. Cria medida Sales PY
3. Cria medida YoY Growth %
4. Usa variáveis para performance
5. Adiciona descrições
6. Organiza em pastas de exibição
7. Valida sintaxe

**Exemplo de uso:**
```
@dax-specialist Create measures for year-over-year sales growth 
including YTD, MTD, and comparison to previous year.
```

---

### 3. Relationship Architect - Conectando Tabelas

**Cenário:** "Preciso conectar minhas tabelas de fato e dimensão"

**Agente:** `@relationship-architect`

**O que ele faz:**
1. Identifica chaves primárias e estrangeiras
2. Determina cardinalidade apropriada (1:N)
3. Define direção de filtro (Single)
4. Cria relacionamentos ativos
5. Manuseia role-playing dimensions (datas múltiplas)
6. Valida integridade

**Exemplo de uso:**
```
@relationship-architect Create relationships between FactSales 
and all dimension tables (Product, Customer, Date).
```

---

### 4. Performance Optimizer - Acelerando Modelo

**Cenário:** "Meu relatório está lento"

**Agente:** `@performance-optimizer`

**O que ele faz:**
1. Executa queries com métricas detalhadas
2. Analisa Storage Engine vs Formula Engine
3. Identifica gargalos (DAX lento, model structure)
4. Sugere otimizações priorizadas
5. Re-testa após mudanças
6. Documenta melhorias

**Exemplo de uso:**
```
@performance-optimizer Analyze performance of "Total Sales YTD" 
measure and suggest optimizations.
```

---

### 5. Quality Validator - Auditando Modelo

**Cenário:** "Quero validar se meu modelo segue boas práticas"

**Agente:** `@quality-validator`

**O que ele faz:**
1. Verifica convenções de nomenclatura
2. Valida integridade de relacionamentos
3. Testa dados (duplicados, NULLs, órfãos)
4. Identifica anti-padrões de performance
5. Gera relatório de qualidade com score
6. Prioriza issues (Critical → Low)

**Exemplo de uso:**
```
@quality-validator Run a full quality audit on my current model 
and generate a report with prioritized recommendations.
```

---

### 6. Documentation Expert - Documentando Modelo

**Cenário:** "Preciso documentar meu modelo para a equipe"

**Agente:** `@documentation-expert`

**O que ele faz:**
1. Adiciona descrições a tabelas e medidas
2. Documenta lógica de negócio complexa
3. Exporta TMDL para referência técnica
4. Cria README do modelo
5. Gera data dictionary
6. Documenta fontes de dados

**Exemplo de uso:**
```
@documentation-expert Create comprehensive documentation for 
this sales model including table descriptions, measure explanations, 
and a user guide.
```

---

## 📚 Base de Conhecimento

O sistema inclui documentação completa de boas práticas:

### [Naming Conventions](/best-practices/naming-conventions.md)
- Padrões Dim/Fact para tabelas
- Convenções para medidas (Title Case)
- Sufixos para chaves, datas, booleans
- Organização em display folders

### [DAX Patterns](/best-practices/dax-patterns.md)
- Time Intelligence (YTD, MTD, QTD, PY)
- Percentuais e comparações
- Rankings e ABC analysis
- Running totals
- Otimizações de performance

### [Modeling Principles](/best-practices/modeling-principles.md)
- Star Schema vs Snowflake
- Granularidade de tabelas
- Normalização vs Desnormalização
- Slowly Changing Dimensions
- Role-Playing Dimensions

### [Performance Tips](/best-practices/performance-tips.md)
- Variáveis em DAX
- Agregadores vs Iteradores
- Storage Engine vs Formula Engine
- Compressão VertiPaq
- Query Folding

---

## 🔄 Workflows Comuns

### Criar Modelo do Zero

```
1. @data-modeler: Create Star Schema structure
2. @relationship-architect: Connect all tables
3. @dax-specialist: Create key measures
4. @quality-validator: Validate structure
5. @documentation-expert: Document model
```

### Otimizar Modelo Existente

```
1. @quality-validator: Full audit (identify issues)
2. @performance-optimizer: Analyze slow queries
3. @data-modeler: Fix structure issues
4. @dax-specialist: Optimize measures
5. @quality-validator: Re-validate
```

### Adicionar Novas Métricas

```
1. @dax-specialist: Create measures
2. @quality-validator: Check for issues
3. @performance-optimizer: Test performance
4. @documentation-expert: Document logic
```

### Revisar Modelo Antes de Deploy

```
1. @quality-validator: Full audit
2. @performance-optimizer: Performance check
3. @documentation-expert: Ensure documentation complete
4. @relationship-architect: Validate relationships
```

---

## 🎓 Boas Práticas do Sistema

### Quando Usar Cada Agente

**Use Data Modeler para:**
- Criar/modificar tabelas
- Design de esquema
- Colunas calculadas (quando apropriado)
- Validar grão de tabelas

**Use DAX Specialist para:**
- Qualquer medida DAX
- Time intelligence
- KPIs e cálculos complexos
- Refatoração de DAX

**Use Relationship Architect para:**
- Criar relacionamentos
- Resolver problemas de filtro
- Role-playing dimensions
- Many-to-many scenarios

**Use Performance Optimizer para:**
- Queries lentas
- Modelo grande/lento
- Otimização pós-desenvolvimento
- Análise de métricas

**Use Quality Validator para:**
- Antes de deploy
- Após mudanças grandes
- Revisão periódica
- Onboarding de novo modelo

**Use Documentation Expert para:**
- Fim de projeto
- Transferência de conhecimento
- Compliance/auditoria
- Modelos compartilhados

---

## ⚡ Power BI MCP - Operações Principais

### Conexão
```
connection_operations:
- Connect (Power BI Desktop, Fabric, Analysis Services)
- Disconnect
- ListLocalInstances
```

### Modelagem
```
table_operations: Create, Update, Delete, GetSchema
column_operations: Create, Update, Delete
measure_operations: Create, Update, Move
relationship_operations: Create, Update, Activate
```

### Análise
```
dax_query_operations: Execute, Validate, GetExecutionMetrics
model_operations: Get, GetStats
```

### Documentação
```
*_operations:ExportTMDL (disponível para todos os objetos)
```

---

## 📊 Exemplos Práticos

### Exemplo 1: Modelo de Vendas Completo

```markdown
**Objetivo:** Criar modelo de vendas do zero

**Agentes usados:** Data Modeler → Relationship Architect → DAX Specialist

**Passos:**
1. @data-modeler: Criar DimDate, DimProduct, DimCustomer, FactSales
2. @relationship-architect: Conectar tudo (1:N, single-direction)
3. @dax-specialist: Criar Total Sales, Sales YTD, Sales vs PY, Growth %
4. @quality-validator: Validar estrutura e convenções
5. @documentation-expert: Documentar para equipe

**Resultado:** Modelo Star Schema completo, otimizado e documentado
```

### Exemplo 2: Otimizar Relatório Lento

```markdown
**Problema:** Relatório demora 15 segundos para carregar

**Agentes usados:** Performance Optimizer → DAX Specialist → Data Modeler

**Passos:**
1. @performance-optimizer: Analisar queries (identificou FE-heavy DAX)
2. @dax-specialist: Refatorar medidas com variáveis
3. @data-modeler: Converter calculated columns em measures
4. @performance-optimizer: Re-testar (agora 2 segundos!)

**Resultado:** 7.5x mais rápido
```

### Exemplo 3: Audit de Qualidade

```markdown
**Objetivo:** Garantir modelo segue padrões da empresa

**Agente usado:** Quality Validator

**Passos:**
1. @quality-validator: Full audit
   - ❌ 15 medidas sem descrição
   - ❌ 3 relacionamentos bidirecionais desnecessários
   - ❌ 5 tabelas não seguem convenção Dim/Fact
   - ✅ DAX patterns estão bons
   
2. Correções aplicadas baseadas no relatório

3. @quality-validator: Re-audit
   - ✅ Score: 95/100 (antes: 65/100)

**Resultado:** Modelo em conformidade com padrões
```

---

## 🛠️ Troubleshooting

### "Não consigo conectar ao Power BI Desktop"

**Solução:**
1. Verificar Power BI Desktop está aberto
2. Ter um modelo aberto (mesmo vazio)
3. Verificar porta correta (External Tools → Server/Port)
4. Usar `connection_operations:ListLocalInstances`

### "Relacionamento não quer criar"

**Causas comuns:**
- Duplicados na coluna "One" side
- NULLs nas chaves
- Data types diferentes
- Já existe relacionamento entre essas tabelas

**Solução:** Use `@relationship-architect` para diagnosticar

### "Medida dá erro"

**Causas comuns:**
- Sintaxe DAX incorreta
- Referência a tabela/coluna inexistente
- Divisão por zero sem DIVIDE

**Solução:** Use `@dax-specialist` com `Validate` operação

### "Modelo muito grande/lento"

**Solução:** Use `@performance-optimizer` para análise completa:
1. GetStats para tamanho
2. Execute queries com metrics
3. Identificar colunas de alta cardinalidade
4. Remover colunas desnecessárias

---

## 📖 Glossário Power BI

**Star Schema:** Fact table no centro, dimensions nas pontas
**Grain:** Nível de detalhe de uma fact table
**SE:** Storage Engine (rápido, paralelo)
**FE:** Formula Engine (lento, single-thread)
**Cardinality:** Número de valores únicos em coluna
**TMDL:** Representação YAML do modelo
**Role-Playing Dimension:** Dimensão usada múltiplas vezes (ex: data de pedido vs data de envio)

---

## 🤝 Integração Entre Agentes

Os agentes trabalham em conjunto:

```
Data Modeler → cria estrutura
    ↓
Relationship Architect → conecta tabelas
    ↓
DAX Specialist → adiciona medidas
    ↓
Performance Optimizer → otimiza
    ↓
Quality Validator → valida
    ↓
Documentation Expert → documenta
```

Você pode pular etapas ou repetir conforme necessário!

---

## 📝 Convenções do Sistema

### Nomenclatura

- **Tabelas:** `DimProduct`, `FactSales` (PascalCase)
- **Colunas:** `ProductKey`, `OrderDate` (PascalCase)
- **Medidas:** `Total Sales`, `Growth %` (Title Case com espaços)
- **Hidden Helpers:** `_Base Sales` (underscore prefix)

### Relacionamentos Padrão

- **Cardinality:** One-to-Many (1:N)
- **Direction:** Single (Dim → Fact)
- **Active:** Apenas 1 por par de tabelas

### DAX Patterns

- Sempre usar variáveis
- DIVIDE em vez de `/`
- Agregadores > Iteradores
- Comentar lógica complexa

---

## 🎯 Próximos Passos

**Iniciantes:**
1. Conectar ao Power BI Desktop
2. Usar `@data-modeler` para criar primeiro modelo
3. Usar `@dax-specialist` para primeiras medidas
4. Explorar documentação de boas práticas

**Intermediários:**
1. Usar `@quality-validator` em modelos existentes
2. Aprender padrões DAX avançados
3. Otimizar com `@performance-optimizer`
4. Documentar com `@documentation-expert`

**Avançados:**
1. Criar workflows customizados
2. Integrar em CI/CD
3. Estender com custom patterns
4. Contribuir com templates adicionais

---

## 📞 Suporte

Para dúvidas ou problemas:

1. **Visite a documentação** em `/best-practices/`
2. **Consulte o agente apropriado** usando `@nome-agente`
3. **Use Quality Validator** para auditorias automáticas
4. **Exporte TMDL** para análise detalhada

---

## ⚖️ Licença e Créditos

Este sistema implementa boas práticas reconhecidas pela comunidade Power BI:

- **Kimball Dimensional Modeling** (Ralph Kimball)
- **SQLBI** patterns and optimizations
- **DAX Patterns** (sqlbi.com/dax-patterns)
- **Microsoft Power BI** documentation

---

## 🔄 Change Log

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0.0 | 2024 | Sistema inicial com 6 agentes e documentação completa |

---

**Pronto para começar? Escolha um agente e comece a construir modelos Power BI excepcionais! 🚀**
