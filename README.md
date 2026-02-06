# Power BI Agent Kit 🎯

Kit completo de agentes de IA especializados para desenvolvimento, análise e migração de modelos semânticos Power BI usando o Power BI MCP (Model Context Protocol).

---

## 🚀 Quick Start

1. **Conecte-se ao modelo Power BI** via MCP
2. **Escolha o agente apropriado** para sua tarefa
3. **Siga as melhores práticas** documentadas

Veja [Getting Started](agents/docs/getting-started.md) para instruções detalhadas.

---

## 🤖 Agentes Disponíveis

O kit inclui **14 agentes especializados** organizados em 4 categorias:

### Development Team (6 agentes)
Agentes para construção e manutenção de modelos:

| Agente | Descrição |
|--------|-----------|
| [data-modeler](agents/development/data-modeler.md) | Tabelas, colunas, Star/Snowflake schema |
| [dax-specialist](agents/development/dax-specialist.md) | Medidas, KPIs, time intelligence |
| [relationship-architect](agents/development/relationship-architect.md) | Relacionamentos, cardinalidade, direção de filtro |
| [performance-optimizer](agents/development/performance-optimizer.md) | Tuning de queries, otimização de modelos |
| [quality-validator](agents/development/quality-validator.md) | Auditorias, validação de best practices |
| [documentation-expert](agents/development/documentation-expert.md) | Descrições, exports TMDL, metadados |

### Analytics Team (4 agentes)
Agentes para análise e insights:

| Agente | Descrição |
|--------|-----------|
| [business-analyst](agents/analytics/business-analyst.md) | Levantamento de requisitos, perguntas de negócio |
| [insight-generator](agents/analytics/insight-generator.md) | Descoberta de padrões, detecção de anomalias |
| [report-designer](agents/analytics/report-designer.md) | Layout de dashboards, seleção de visuais |
| [data-storyteller](agents/analytics/data-storyteller.md) | Narrativas, apresentações, talking points |

### Migration Team (2 agentes)
Agentes para migração de modelos:

| Agente | Descrição |
|--------|-----------|
| [migration-planner](agents/migration/migration-planner.md) | Planejamento, análise de impacto, rollback |
| [migration-executor](agents/migration/migration-executor.md) | Execução de migrações, transformações |

### Meta Team (2 agentes)
Agentes de coordenação:

| Agente | Descrição |
|--------|-----------|
| [operations-manager](agents/meta/operations-manager.md) | Coordenação de workflows entre agentes |
| [prompt-engineer](agents/meta/prompt-engineer.md) | Criação e melhoria de prompts de agentes |

---

## 📚 Best Practices

Documentação completa de melhores práticas:

| Documento | Descrição |
|-----------|-----------|
| [Naming Conventions](agents/best-practices/naming-conventions.md) | Padrões de nomenclatura para tabelas, colunas, medidas |
| [Modeling Principles](agents/best-practices/modeling-principles.md) | Star Schema, relacionamentos, design |
| [DAX Patterns](agents/best-practices/dax-patterns.md) | Padrões DAX comprovados e otimizados |
| [DAX Comments](agents/best-practices/dax-comments.md) | Padrões de comentários e documentação |
| [Performance Tips](agents/best-practices/performance-tips.md) | Otimização de queries e modelos |

---

## 🔄 Workflows Comuns

### Criar um Novo Modelo
```
1. business-analyst     → Definir requisitos
2. data-modeler         → Criar tabelas
3. relationship-architect → Criar relacionamentos
4. dax-specialist       → Criar medidas
5. quality-validator    → Validar modelo
6. documentation-expert → Documentar
```

### Migrar Modelo Existente
```
1. migration-planner    → Analisar e planejar
2. migration-executor   → Executar migração
3. quality-validator    → Validar resultados
4. documentation-expert → Atualizar documentação
```

### Otimizar Performance
```
1. performance-optimizer → Analisar gargalos
2. dax-specialist       → Otimizar medidas
3. quality-validator    → Validar melhorias
```

### Gerar Insights de Dados
```
1. business-analyst     → Definir perguntas
2. insight-generator    → Descobrir padrões
3. report-designer      → Desenhar dashboard
4. data-storyteller     → Criar narrativa
```

---

## 📂 Estrutura do Kit

```
agents/
├── README.md                    # Overview do kit (este arquivo)
├── development/                 # Agentes de desenvolvimento
│   ├── data-modeler.md
│   ├── dax-specialist.md
│   ├── relationship-architect.md
│   ├── performance-optimizer.md
│   ├── quality-validator.md
│   └── documentation-expert.md
├── analytics/                   # Agentes analíticos
│   ├── business-analyst.md
│   ├── insight-generator.md
│   ├── report-designer.md
│   └── data-storyteller.md
├── migration/                   # Agentes de migração
│   ├── migration-planner.md
│   └── migration-executor.md
├── meta/                        # Meta-agentes
│   ├── operations-manager.md
│   └── prompt-engineer.md
├── best-practices/              # Documentação de boas práticas
│   ├── naming-conventions.md
│   ├── dax-patterns.md
│   ├── dax-comments.md
│   ├── modeling-principles.md
│   └── performance-tips.md
├── templates/                   # Templates reutilizáveis
├── examples/                    # Exemplos de uso
└── docs/                        # Documentação geral
    └── getting-started.md
```

---

## 🌐 Idioma

Todos os agentes respondem em **Português (Brasil)**, mantendo termos técnicos (funções DAX, nomes de tabelas/colunas, features do Power BI) em inglês.

---

## ⚡ Power BI MCP - Principais Operações

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

## 🔧 Requisitos

- Power BI Desktop ou Fabric
- Power BI MCP Server configurado
- Modelo semântico conectado

---

## 📖 Referências

Este sistema implementa boas práticas reconhecidas:

- **Kimball Dimensional Modeling** (Ralph Kimball)
- **SQLBI** patterns and optimizations
- **DAX Patterns** (sqlbi.com/dax-patterns)
- **Microsoft Power BI** documentation

---

## 🔄 Change Log

| Versão | Data | Mudanças |
|--------|------|----------|
| 2.0.0 | 2025-02 | Nova estrutura modular com 14 agentes em 4 categorias |
| 1.0.0 | 2024 | Sistema inicial com 6 agentes |

---

**Pronto para começar? Veja o [Getting Started](agents/docs/getting-started.md) e construa modelos Power BI excepcionais! 🚀**
