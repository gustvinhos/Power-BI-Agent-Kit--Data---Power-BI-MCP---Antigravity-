# 📋 Plano de Migração - Medidas Pendentes V3 → V2

## 🎯 Objetivo
Migrar as medidas exclusivas do V3 que ainda não foram adicionadas ao V2 (Golden Dataset).

---

## 📊 Medidas para Migrar (Prioridade ALTA)

### 1. **Erro** (Previsão S&OP)
```dax
Erro = 
[Qtd Vendida (un)] - [Previsao de Demanda (qtd)]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Previsões`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Calcula o erro de previsão subtraindo a demanda prevista da quantidade vendida real. Usado para análise de acurácia de previsões S&OP.
- **Format String:** General Number

---

### 2. **WMAPE (%)** (Previsão S&OP)
```dax
WMAPE (%) = 
DIVIDE([Erro], [Qtd Vendida (un)])
```

**Metadados:**
- **Display Folder:** `8.S&OP\Previsões`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Weighted Mean Absolute Percentage Error. Calcula o percentual de erro da previsão dividindo o erro pela quantidade vendida. Métrica chave para avaliar acurácia de forecasting.
- **Format String:** Percentage (0.00%)

---

### 3. **Estoq. - Fat. Ante. - 60d (un)** (POG)
```dax
Estoq. - Fat. Ante. - 60d (un) = 
[QTD Estoque Liquido (Análises)] - [60d (un)]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Estoques - POGs`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 60 dias. Usado para planejamento de cobertura de estoque.
- **Format String:** #,0

---

### 4. **Estoq. - Fat. Ante. - 90d (un)** (POG)
```dax
Estoq. - Fat. Ante. - 90d (un) = 
[QTD Estoque Liquido (Análises)] - [90d (un)]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Estoques - POGs`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 90 dias. Usado para planejamento de cobertura de estoque de médio prazo.
- **Format String:** #,0

---

## ⚠️ Medidas para Investigar

### 5. **Vendas (un)** - NÃO ENCONTRADA NO V3
- **Status:** Medida não existe no V3 com este nome exato
- **Possibilidade 1:** Nome diferente no V3
- **Possibilidade 2:** Medida foi removida do V3
- **Possibilidade 3:** Documentação incorreta
- **Ação:** Verificar se V2 já possui funcionalidade equivalente via "SWITCH Vendas"

### 6. **Vendas (Kg/L)**, **Vendas (Hec)**, **Vendas (R$)** - NÃO ENCONTRADAS
- **Status:** Medidas não existem no V3 com estes nomes exatos
- **Observação:** V2 possui "SWITCH Vendas" que faz conversão de unidades
- **Ação:** Confirmar se "SWITCH Vendas" do V2 é suficiente ou se medidas adicionais são necessárias

### 7. **Demanda 60 dias** - SIMILAR EXISTE
- **V3:** Não encontrada com este nome exato
- **V2:** Possui "Demanda S&OP/Protheus 60d"
- **Ação:** Comparar expressões DAX para confirmar equivalência

---

## 🔧 Dependências Identificadas

### Medidas Base Necessárias (devem existir no V2):
- `[Qtd Vendida (un)]` - ⚠️ Verificar se existe no V2
- `[Previsao de Demanda (qtd)]` - ⚠️ Verificar se existe no V2
- `[QTD Estoque Liquido (Análises)]` - ⚠️ Verificar se existe no V2
- `[60d (un)]` - ⚠️ Verificar se existe no V2
- `[90d (un)]` - ⚠️ Verificar se existe no V2

**Ação Crítica:** Antes de migrar as medidas 1-4, verificar se todas as medidas base existem no V2. Se não existirem, migrar primeiro as dependências.

---

## 📝 Script de Migração (PowerShell + MCP)

```powershell
# Conectar ao V2 (Golden Dataset)
# Criar medidas usando MCP

# 1. Criar medida "Erro"
$measure1 = @{
    operation = "Create"
    tableName = "Medidas"
    createDefinition = @{
        name = "Erro"
        expression = "[Qtd Vendida (un)] - [Previsao de Demanda (qtd)]"
        description = "📦 MIGRADO DO V3 | Calcula o erro de previsão subtraindo a demanda prevista da quantidade vendida real. Usado para análise de acurácia de previsões S&OP."
        displayFolder = "8.S&OP\Previsões"
        formatString = ""
    }
}

# 2. Criar medida "WMAPE (%)"
$measure2 = @{
    operation = "Create"
    tableName = "Medidas"
    createDefinition = @{
        name = "WMAPE (%)"
        expression = "DIVIDE([Erro], [Qtd Vendida (un)])"
        description = "📦 MIGRADO DO V3 | Weighted Mean Absolute Percentage Error. Calcula o percentual de erro da previsão dividindo o erro pela quantidade vendida. Métrica chave para avaliar acurácia de forecasting."
        displayFolder = "8.S&OP\Previsões"
        formatString = "0.00%"
    }
}

# 3. Criar medida "Estoq. - Fat. Ante. - 60d (un)"
$measure3 = @{
    operation = "Create"
    tableName = "Medidas"
    createDefinition = @{
        name = "Estoq. - Fat. Ante. - 60d (un)"
        expression = "[QTD Estoque Liquido (Análises)] - [60d (un)]"
        description = "📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 60 dias. Usado para planejamento de cobertura de estoque."
        displayFolder = "8.S&OP\Estoques - POGs"
        formatString = "#,0"
    }
}

# 4. Criar medida "Estoq. - Fat. Ante. - 90d (un)"
$measure4 = @{
    operation = "Create"
    tableName = "Medidas"
    createDefinition = @{
        name = "Estoq. - Fat. Ante. - 90d (un)"
        expression = "[QTD Estoque Liquido (Análises)] - [90d (un)]"
        description = "📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 90 dias. Usado para planejamento de cobertura de estoque de médio prazo."
        displayFolder = "8.S&OP\Estoques - POGs"
        formatString = "#,0"
    }
}
```

---

## ✅ Checklist de Migração

### Pré-Migração
- [ ] Verificar se medidas base existem no V2:
  - [ ] `[Qtd Vendida (un)]`
  - [ ] `[Previsao de Demanda (qtd)]`
  - [ ] `[QTD Estoque Liquido (Análises)]`
  - [ ] `[60d (un)]`
  - [ ] `[90d (un)]`
- [ ] Se medidas base não existirem, identificar equivalentes no V2
- [ ] Ajustar expressões DAX conforme nomenclatura do V2

### Migração
- [ ] Criar medida "Erro" no V2
- [ ] Criar medida "WMAPE (%)" no V2
- [ ] Criar medida "Estoq. - Fat. Ante. - 60d (un)" no V2
- [ ] Criar medida "Estoq. - Fat. Ante. - 90d (un)" no V2

### Pós-Migração
- [ ] Validar que medidas foram criadas com sucesso
- [ ] Executar query de validação (05-v3-delta-validation.dax)
- [ ] Comparar resultados V3 vs V2 (devem ser idênticos)
- [ ] Documentar discrepâncias (se houver)
- [ ] Atualizar relatório de validação

---

## 🎯 Critérios de Sucesso

- ✅ Todas as 4 medidas criadas no V2 (Golden)
- ✅ Medidas possuem tag "📦 MIGRADO DO V3" na descrição
- ✅ Display Folders corretos (8.S&OP\Previsões e 8.S&OP\Estoques - POGs)
- ✅ Resultados idênticos entre V3 e V2 (0% diferença)
- ✅ Sem erros semânticos ou sintáticos

---

## 📎 Arquivos Relacionados

- [v3-to-v2-delta-validation-report.md](file:///C:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI/validation/results/v3-to-v2-delta-validation-report.md) - Relatório de validação
- [05-v3-delta-validation.dax](file:///C:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI/validation/queries/05-v3-delta-validation.dax) - Query de validação
- [task.md](file:///C:/Users/ThiagoReisAraujo/.gemini/antigravity/brain/711aa748-40ee-4bf2-a2e4-c8baab513ad6/task.md) - Checklist da Fase 3

---

**Criado em:** 2026-02-03 18:10 BRT  
**Status:** Pronto para Execução
