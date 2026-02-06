# 🔄 Atualização das Medidas via Power BI MCP

## ⚠️ IMPORTANTE

As 4 medidas precisam ser atualizadas **AGORA** no Power BI Desktop que está aberto.

---

## 📋 Medidas a Atualizar

1. **Erro (S&OP)**
2. **WMAPE (%) (S&OP)**
3. **Estoq. - Fat. Ante. - 60d (un)**
4. **Estoq. - Fat. Ante. - 90d (un)**

---

## 🔧 Como Executar via MCP

### Opção 1: Via Claude Code (Se MCP configurado)

Se você tem o Power BI MCP configurado no Claude Code, execute:

```typescript
// Medida 1: Erro (S&OP)
await mcp.call_tool("powerbi", "measure_operations", {
  operation: "Update",
  tableName: "Medidas",
  measureName: "Erro (S&OP)",
  updateDefinition: {
    expression: `/*
    📦 MIGRADO DO V3 | Erro de Previsão S&OP

    PROPÓSITO:
        Calcula o erro absoluto entre a quantidade vendida real e a
        demanda prevista pelo S&OP/Protheus. Métrica fundamental para
        avaliar acurácia das previsões de demanda.

    LÓGICA:
        1. Obtém quantidade vendida real (QTD Vendas)
        2. Obtém demanda prevista para 60 dias (Demanda S&OP/Protheus 60d)
        3. Calcula diferença (Real - Previsto)
        4. Valores positivos: Vendeu MAIS que previsto
        5. Valores negativos: Vendeu MENOS que previsto

    DEPENDÊNCIAS:
        - [QTD Vendas]: Quantidade total vendida (com ajuste de outliers)
        - [Demanda S&OP/Protheus 60d]: Previsão de demanda para próximos 60 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - Usado em análises de acurácia de forecasting
        - Base para cálculo do WMAPE (%)
        - Valores positivos indicam demanda subestimada
        - Valores negativos indicam demanda superestimada

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Vendas] - [Demanda S&OP/Protheus 60d]`
  }
});

// Medida 2: WMAPE (%) (S&OP)
await mcp.call_tool("powerbi", "measure_operations", {
  operation: "Update",
  tableName: "Medidas",
  measureName: "WMAPE (%) (S&OP)",
  updateDefinition: {
    expression: `/*
    📦 MIGRADO DO V3 | Weighted Mean Absolute Percentage Error

    PROPÓSITO:
        Calcula o erro percentual ponderado da previsão de demanda.
        Métrica chave (KPI) para avaliar acurácia do forecasting S&OP.
        Quanto menor o WMAPE, melhor a qualidade da previsão.

    LÓGICA:
        1. Obtém erro absoluto de previsão ([Erro (S&OP)])
        2. Obtém quantidade vendida real como base ([QTD Vendas])
        3. Divide erro pela quantidade vendida
        4. Usa DIVIDE para evitar divisão por zero
        5. Retorna BLANK se não houver vendas

    DEPENDÊNCIAS:
        - [Erro (S&OP)]: Diferença entre real e previsto
        - [QTD Vendas]: Quantidade vendida (denominador)

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - WMAPE < 10%: Previsão EXCELENTE
        - WMAPE 10-20%: Previsão BOA
        - WMAPE 20-30%: Previsão ACEITÁVEL
        - WMAPE > 30%: Previsão RUIM (requer revisão)

    PERFORMANCE:
        - Usa DIVIDE para segurança (evita erro #DIV/0)
        - Retorna BLANK quando não há vendas

    NOTAS:
        - Medida dependente: requer [Erro (S&OP)] existente
        - Formato percentual (0.00%) facilita leitura
        - Usado em dashboards executivos de S&OP

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
DIVIDE([Erro (S&OP)], [QTD Vendas])`
  }
});

// Medida 3: POG 60d
await mcp.call_tool("powerbi", "measure_operations", {
  operation: "Update",
  tableName: "Medidas",
  measureName: "Estoq. - Fat. Ante. - 60d (un)",
  updateDefinition: {
    expression: `/*
    📦 MIGRADO DO V3 | POG 60 dias (Plano Operacional de Gestão)

    PROPÓSITO:
        Calcula a cobertura de estoque líquido considerando faturamentos
        antecipados dos próximos 60 dias. Usado para planejamento de
        reposição e análise de risco de ruptura de curto prazo.

    LÓGICA:
        1. Obtém estoque líquido atual (disponível)
        2. Obtém faturamentos antecipados para próximos 60 dias
        3. Calcula diferença (Estoque - Faturamentos Antecipados)
        4. Valores positivos: Estoque SUFICIENTE para 60 dias
        5. Valores negativos: Risco de RUPTURA nos próximos 60 dias

    DEPENDÊNCIAS:
        - [QTD Estoque Liquido (Análises)]: Estoque disponível atual
        - [QTD Prox 60d (Análises)]: Faturamentos antecipados 60 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Nome Original V3: "Estoq. - Fat. Ante. - Xd" (parametrizado)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - POG > 0: Estoque suficiente (situação SAUDÁVEL)
        - POG = 0: Estoque justo (situação LIMÍTROFE)
        - POG < 0: Risco de ruptura (situação CRÍTICA)
        - Usado para alertas de reposição urgente

    NOTAS:
        - Horizonte de planejamento: Curto prazo (60 dias)
        - Considera apenas faturamentos já antecipados/confirmados
        - Não inclui demanda prevista não confirmada
        - Complementa POG 90d para análise de médio prazo

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Estoque Liquido (Análises)] - [QTD Prox 60d (Análises)]`
  }
});

// Medida 4: POG 90d
await mcp.call_tool("powerbi", "measure_operations", {
  operation: "Update",
  tableName: "Medidas",
  measureName: "Estoq. - Fat. Ante. - 90d (un)",
  updateDefinition: {
    expression: `/*
    📦 MIGRADO DO V3 | POG 90 dias (Plano Operacional de Gestão)

    PROPÓSITO:
        Calcula a cobertura de estoque líquido considerando faturamentos
        antecipados dos próximos 90 dias. Usado para planejamento de
        reposição de médio prazo e análise estratégica de estoque.

    LÓGICA:
        1. Obtém estoque líquido atual (disponível)
        2. Obtém faturamentos antecipados para próximos 90 dias
        3. Calcula diferença (Estoque - Faturamentos Antecipados)
        4. Valores positivos: Estoque SUFICIENTE para 90 dias
        5. Valores negativos: Risco de RUPTURA nos próximos 90 dias

    DEPENDÊNCIAS:
        - [QTD Estoque Liquido (Análises)]: Estoque disponível atual
        - [QTD Prox 90d (Análises)]: Faturamentos antecipados 90 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Nome Original V3: "Estoq. - Fat. Ante. - Xd" (parametrizado)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - POG > 0: Estoque suficiente (situação SAUDÁVEL)
        - POG = 0: Estoque justo (situação LIMÍTROFE)
        - POG < 0: Risco de ruptura (situação CRÍTICA)
        - Horizonte maior que POG 60d para planejamento estratégico

    NOTAS:
        - Horizonte de planejamento: Médio prazo (90 dias)
        - Considera apenas faturamentos já antecipados/confirmados
        - Não inclui demanda prevista não confirmada
        - Complementa POG 60d para visão de curto prazo
        - Usado em reuniões S&OP mensais

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Estoque Liquido (Análises)] - [QTD Prox 90d (Análises)]`
  }
});
```

### Opção 2: Manual no Power BI Desktop

Se MCP não estiver disponível, faça manualmente:

1. Abra Power BI Desktop (já está aberto)
2. Vá para visualização de **Modelo** ou **Dados**
3. Encontre cada medida na tabela **Medidas**
4. Para cada medida:
   - Clique direito → **Editar Medida** (ou DAX editor)
   - Copie a expressão completa com comentários (abaixo)
   - Cole substituindo a expressão atual
   - Clique **OK** ou **Aplicar**

---

## 📝 Expressões Completas (Para Copiar/Colar)

### Medida 1: Erro (S&OP)

```dax
/*
    📦 MIGRADO DO V3 | Erro de Previsão S&OP

    PROPÓSITO:
        Calcula o erro absoluto entre a quantidade vendida real e a
        demanda prevista pelo S&OP/Protheus. Métrica fundamental para
        avaliar acurácia das previsões de demanda.

    LÓGICA:
        1. Obtém quantidade vendida real (QTD Vendas)
        2. Obtém demanda prevista para 60 dias (Demanda S&OP/Protheus 60d)
        3. Calcula diferença (Real - Previsto)
        4. Valores positivos: Vendeu MAIS que previsto
        5. Valores negativos: Vendeu MENOS que previsto

    DEPENDÊNCIAS:
        - [QTD Vendas]: Quantidade total vendida (com ajuste de outliers)
        - [Demanda S&OP/Protheus 60d]: Previsão de demanda para próximos 60 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - Usado em análises de acurácia de forecasting
        - Base para cálculo do WMAPE (%)
        - Valores positivos indicam demanda subestimada
        - Valores negativos indicam demanda superestimada

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Vendas] - [Demanda S&OP/Protheus 60d]
```

### Medida 2: WMAPE (%) (S&OP)

```dax
/*
    📦 MIGRADO DO V3 | Weighted Mean Absolute Percentage Error

    PROPÓSITO:
        Calcula o erro percentual ponderado da previsão de demanda.
        Métrica chave (KPI) para avaliar acurácia do forecasting S&OP.
        Quanto menor o WMAPE, melhor a qualidade da previsão.

    LÓGICA:
        1. Obtém erro absoluto de previsão ([Erro (S&OP)])
        2. Obtém quantidade vendida real como base ([QTD Vendas])
        3. Divide erro pela quantidade vendida
        4. Usa DIVIDE para evitar divisão por zero
        5. Retorna BLANK se não houver vendas

    DEPENDÊNCIAS:
        - [Erro (S&OP)]: Diferença entre real e previsto
        - [QTD Vendas]: Quantidade vendida (denominador)

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - WMAPE < 10%: Previsão EXCELENTE
        - WMAPE 10-20%: Previsão BOA
        - WMAPE 20-30%: Previsão ACEITÁVEL
        - WMAPE > 30%: Previsão RUIM (requer revisão)

    PERFORMANCE:
        - Usa DIVIDE para segurança (evita erro #DIV/0)
        - Retorna BLANK quando não há vendas

    NOTAS:
        - Medida dependente: requer [Erro (S&OP)] existente
        - Formato percentual (0.00%) facilita leitura
        - Usado em dashboards executivos de S&OP

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
DIVIDE([Erro (S&OP)], [QTD Vendas])
```

### Medida 3: Estoq. - Fat. Ante. - 60d (un)

```dax
/*
    📦 MIGRADO DO V3 | POG 60 dias (Plano Operacional de Gestão)

    PROPÓSITO:
        Calcula a cobertura de estoque líquido considerando faturamentos
        antecipados dos próximos 60 dias. Usado para planejamento de
        reposição e análise de risco de ruptura de curto prazo.

    LÓGICA:
        1. Obtém estoque líquido atual (disponível)
        2. Obtém faturamentos antecipados para próximos 60 dias
        3. Calcula diferença (Estoque - Faturamentos Antecipados)
        4. Valores positivos: Estoque SUFICIENTE para 60 dias
        5. Valores negativos: Risco de RUPTURA nos próximos 60 dias

    DEPENDÊNCIAS:
        - [QTD Estoque Liquido (Análises)]: Estoque disponível atual
        - [QTD Prox 60d (Análises)]: Faturamentos antecipados 60 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Nome Original V3: "Estoq. - Fat. Ante. - Xd" (parametrizado)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - POG > 0: Estoque suficiente (situação SAUDÁVEL)
        - POG = 0: Estoque justo (situação LIMÍTROFE)
        - POG < 0: Risco de ruptura (situação CRÍTICA)
        - Usado para alertas de reposição urgente

    NOTAS:
        - Horizonte de planejamento: Curto prazo (60 dias)
        - Considera apenas faturamentos já antecipados/confirmados
        - Não inclui demanda prevista não confirmada
        - Complementa POG 90d para análise de médio prazo

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Estoque Liquido (Análises)] - [QTD Prox 60d (Análises)]
```

### Medida 4: Estoq. - Fat. Ante. - 90d (un)

```dax
/*
    📦 MIGRADO DO V3 | POG 90 dias (Plano Operacional de Gestão)

    PROPÓSITO:
        Calcula a cobertura de estoque líquido considerando faturamentos
        antecipados dos próximos 90 dias. Usado para planejamento de
        reposição de médio prazo e análise estratégica de estoque.

    LÓGICA:
        1. Obtém estoque líquido atual (disponível)
        2. Obtém faturamentos antecipados para próximos 90 dias
        3. Calcula diferença (Estoque - Faturamentos Antecipados)
        4. Valores positivos: Estoque SUFICIENTE para 90 dias
        5. Valores negativos: Risco de RUPTURA nos próximos 90 dias

    DEPENDÊNCIAS:
        - [QTD Estoque Liquido (Análises)]: Estoque disponível atual
        - [QTD Prox 90d (Análises)]: Faturamentos antecipados 90 dias

    ORIGEM:
        Modelo: S&OP Axia V3
        Tabela Original: Medidas (V3)
        Nome Original V3: "Estoq. - Fat. Ante. - Xd" (parametrizado)
        Data Migração: 2026-02-03

    REGRA DE NEGÓCIO:
        - POG > 0: Estoque suficiente (situação SAUDÁVEL)
        - POG = 0: Estoque justo (situação LIMÍTROFE)
        - POG < 0: Risco de ruptura (situação CRÍTICA)
        - Horizonte maior que POG 60d para planejamento estratégico

    NOTAS:
        - Horizonte de planejamento: Médio prazo (90 dias)
        - Considera apenas faturamentos já antecipados/confirmados
        - Não inclui demanda prevista não confirmada
        - Complementa POG 60d para visão de curto prazo
        - Usado em reuniões S&OP mensais

    AUTOR: Data Team - Migração V3→V2
    DATA: 2026-02-03
*/
[QTD Estoque Liquido (Análises)] - [QTD Prox 90d (Análises)]
```

---

## ✅ Após Atualizar

1. **Salve o arquivo .pbix**
2. **Exporte TMDL** para verificar que os comentários foram salvos
3. **Teste cada medida** com uma query DAX simples
4. **Marque como concluído** no checklist

---

## 🔍 Por Que o Padrão Não Foi Seguido?

### Causa Raiz

O plano de migração original enviou apenas a **expressão DAX pura** no campo `expression`:

```powershell
expression = "[QTD Vendas] - [Demanda S&OP/Protheus 60d]"  # SEM COMENTÁRIOS!
```

### Deveria Ter Sido

```powershell
expression = @"
/*
    📦 MIGRADO DO V3 | ...
    PROPÓSITO: ...
*/
[QTD Vendas] - [Demanda S&OP/Protheus 60d]
"@
```

### Lição Aprendida

- ✅ Use SEMPRE o template `New-MigratedMeasure`
- ✅ Valide com `Test-MeasureHasDocumentation` ANTES de criar
- ✅ Peer review OBRIGATÓRIO
- ✅ Checklist OBRIGATÓRIO para futuras migrações

---

**Agora execute as atualizações acima no Power BI Desktop!**
