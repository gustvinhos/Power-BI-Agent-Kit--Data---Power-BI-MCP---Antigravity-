# Power BI Agent Kit

Um kit completo de agentes de IA especializados para desenvolvimento, análise e migração de modelos semânticos Power BI usando o Power BI MCP (Model Context Protocol).

## 🚀 Quick Start

1. **Conecte-se ao modelo Power BI**
2. **Escolha o agente apropriado para sua tarefa**
3. **Siga as melhores práticas documentadas**

Veja [Getting Started](docs/getting-started.md) para instruções detalhadas.

## 📂 Estrutura

```
├── agents/                    # Agentes especializados
│   ├── development/           # Desenvolvimento de modelos
│   │   ├── data-modeler.md
│   │   ├── relationship-architect.md
│   │   ├── dax-specialist.md
│   │   ├── performance-optimizer.md
│   │   ├── quality-validator.md
│   │   └── documentation-expert.md
│   │
│   ├── analytics/             # Análise e insights
│   │   ├── business-analyst.md
│   │   ├── insight-generator.md
│   │   ├── report-designer.md
│   │   └── data-storyteller.md
│   │
│   ├── migration/             # Migração de modelos
│   │   ├── migration-planner.md
│   │   └── migration-executor.md
│   │
│   └── meta/                  # Meta-agentes (coordenação)
│       ├── operations-manager.md
│       └── prompt-engineer.md
│
├── best-practices/            # Padrões e convenções
│   ├── naming-conventions.md
│   ├── modeling-principles.md
│   ├── dax-patterns.md
│   ├── dax-comments.md
│   └── performance-tips.md
│
├── templates/                 # Templates reutilizáveis
│   └── (templates)
│
├── examples/                  # Exemplos práticos
│   └── (exemplos)
│
└── docs/                      # Documentação
    └── getting-started.md
```

## 🤖 Agentes Disponíveis

### Development Team
Agentes para construção e manutenção de modelos:

| Agente | Descrição |
|--------|-----------|
| **data-modeler** | Tabelas, colunas, Star/Snowflake schema |
| **relationship-architect** | Relacionamentos, cardinalidade, direção de filtro |
| **dax-specialist** | Medidas, KPIs, time intelligence |
| **performance-optimizer** | Tuning de queries, otimização de modelos |
| **quality-validator** | Auditorias, validação de best practices |
| **documentation-expert** | Descrições, exports TMDL, metadados |

### Analytics Team
Agentes para análise e insights:

| Agente | Descrição |
|--------|-----------|
| **business-analyst** | Levantamento de requisitos, perguntas de negócio |
| **insight-generator** | Descoberta de padrões, detecção de anomalias |
| **report-designer** | Layout de dashboards, seleção de visuais |
| **data-storyteller** | Narrativas, apresentações, talking points |

### Migration Team
Agentes para migração de modelos:

| Agente | Descrição |
|--------|-----------|
| **migration-planner** | Planejamento, análise de impacto, rollback |
| **migration-executor** | Execução de migrações, transformações |

### Meta Team
Agentes de coordenação:

| Agente | Descrição |
|--------|-----------|
| **operations-manager** | Coordenação de workflows entre agentes |
| **prompt-engineer** | Criação e melhoria de prompts de agentes |

## 📋 Best Practices

- **[Naming Conventions](best-practices/naming-conventions.md)** - Padrões de nomenclatura
- **[Modeling Principles](best-practices/modeling-principles.md)** - Princípios de modelagem
- **[DAX Patterns](best-practices/dax-patterns.md)** - Padrões DAX comprovados
- **[DAX Comments](best-practices/dax-comments.md)** - Padrões de comentários DAX
- **[Performance Tips](best-practices/performance-tips.md)** - Dicas de performance

## 🎯 Casos de Uso Comuns

### Criar um novo modelo
```
1. Use business-analyst para requisitos
2. Use data-modeler para tabelas
3. Use relationship-architect para relacionamentos
4. Use dax-specialist para medidas
5. Use quality-validator para validação
6. Use documentation-expert para documentar
```

### Migrar um modelo existente
```
1. Use migration-planner para analisar e planejar
2. Use migration-executor para executar
3. Use quality-validator para validar
4. Use documentation-expert para documentar
```

### Otimizar performance
```
1. Use performance-optimizer para análise
2. Use dax-specialist para otimizar medidas
3. Use quality-validator para validar
```

### Gerar insights de dados
```
1. Use business-analyst para definir perguntas
2. Use insight-generator para descobrir padrões
3. Use data-storyteller para criar narrativa
```

## 🌐 Idioma

Todos os agentes respondem em **Português (Brasil)**, mantendo termos técnicos (funções DAX, nomes de tabelas/colunas, features do Power BI) em inglês.

## 📖 Documentação Adicional

- [Getting Started](docs/getting-started.md) - Como começar
- [Agent Reference](docs/agent-reference.md) - Referência completa dos agentes

## 🔧 Requisitos

- Power BI Desktop ou Fabric
- Power BI MCP Server configurado
- Modelo semântico conectado

---

**Versão**: 1.0.0  
**Última atualização**: 2025-01-15
