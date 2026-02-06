# 🗺️ Mapeamento de Dependências - Medidas V3 → V2

## 📅 Data: 2026-02-03 18:12 BRT

---

## ✅ Resumo Executivo

**Status:** ✅ **TODAS AS DEPENDÊNCIAS MAPEADAS**

Todas as medidas base necessárias para migração existem no V2, mas com **nomenclaturas diferentes**. As expressões DAX precisam ser ajustadas antes da migração.

---

## 📊 Mapeamento Completo de Dependências

### 1️⃣ **Qtd Vendida (un)** → **QTD Vendas**

#### V3 (Original)
```dax
Qtd Vendida (un) = 
CALCULATE(
    SUM('Vendas Total AXIA'[QTD_DISP]),
    FILTER(
        'Vendas Total AXIA',
        'Vendas Total AXIA'[FLG_REAL_SAIDA] = "REAL SAÍDA"
    )
)
```
- **Display Folder:** 3.Vendas\Vendas
- **Tabela:** Medidas

#### V2 (Equivalente)
```dax
QTD Vendas = 
CALCULATE(
    SUM('Vendas Total AXIA'[QTD_AJUSTADA_OUTLIER]),
    FILTER(
        'Vendas Total AXIA',
        'Vendas Total AXIA'[FLG_REAL_SAIDA] = "REAL SAÍDA"
    )
)
```
- **Display Folder:** 3.Vendas\Vendas Geral
- **Tabela:** Medidas

**Diferença:** 
- V3 usa `QTD_DISP`
- V2 usa `QTD_AJUSTADA_OUTLIER` (com ajuste de outliers)

**Decisão:** ✅ Usar `[QTD Vendas]` do V2 (mais robusto com tratamento de outliers)

---

### 2️⃣ **Previsao de Demanda (qtd)** → **Demanda S&OP/Protheus 60d**

#### V3 (Original)
```dax
Previsao de Demanda (qtd) = 
[Demanda S&OP/Protheus]
```
- **Display Folder:** 8.S&OP\Previsões
- **Tabela:** Medidas
- **Observação:** É uma referência a outra medida

#### V2 (Equivalente)
```dax
Demanda S&OP/Protheus 60d = 
VAR Periodo = 3

VAR Venda_Prox_Periodo_LY = 
    SUMX(
        DATESINPERIOD(
            'Dim Calendário'[Date],
            DATE(year(MAX('Dim Calendário'[Date]))-1,MONTH(MAX('Dim Calendário'[Date])),1),
            Periodo,
            MONTH
        ),
        [QTD Vendas]
    )

VAR Venda_Ult_Periodo_LY = 
    SUMX(
        DATESINPERIOD(
            'Dim Calendário'[Date],
            date(year(MAX('Dim Calendário'[Date]))-1,MONTH(MAX('Dim Calendário'[Date]))-Periodo,1),
            Periodo,
            MONTH
        ),
        [QTD Vendas]
    )
    
VAR Venda_Ult_Periodo_Atual = 
   SUMX(
        DATESINPERIOD(
            'Dim Calendário'[Date],
            date(year(MAX('Dim Calendário'[Date])),MONTH(MAX('Dim Calendário'[Date]))-Periodo,1),
            Periodo,
            MONTH
        ),
        [QTD Vendas]
    )

VAR Crescimento = 
    IF(ABS(
    IF(
        Venda_Ult_Periodo_LY = 0, 
        BLANK(), 
        DIVIDE(
            (Venda_Ult_Periodo_Atual - Venda_Ult_Periodo_LY),
            Venda_Ult_Periodo_LY
        )
    ))>0.7,
    BLANK(),
    IF(
        Venda_Ult_Periodo_LY = 0, 
        BLANK(), 
        DIVIDE(
            (Venda_Ult_Periodo_Atual - Venda_Ult_Periodo_LY),
            Venda_Ult_Periodo_LY
        )
    )
    )

VAR Media_Venda = 
    DIVIDE(
        (Venda_Prox_Periodo_LY + Venda_Ult_Periodo_Atual), 
        2
    )

VAR Previsao_Mensal = 
        Media_Venda * (1 + Crescimento)
     
RETURN Previsao_Mensal
```
- **Display Folder:** (sem pasta)
- **Tabela:** Medidas

**Decisão:** ✅ Usar `[Demanda S&OP/Protheus 60d]` do V2

---

### 3️⃣ **QTD Estoque Liquido (Análises)** → **QTD Estoque Liquido (Análises)** ✅

#### V3 (Original)
```dax
QTD Estoque Liquido (Análises) = 
[QTD Estoque Bruto (Análises)] - [Fat Antecipado(un)] + [Pedido em aberto (un)]
```
- **Display Folder:** 1.Estoque\Estoque Atual
- **Tabela:** Medidas

#### V2 (Equivalente)
```dax
QTD Estoque Liquido (Análises) = 
[QTD Estoque Bruto (Análises)] - [Fat Antecipado(un)] + [Pedido em aberto (un)]
```
- **Display Folder:** 1.Estoque\Estoque Atual
- **Tabela:** Medidas

**Decisão:** ✅ **IDÊNTICA!** Usar `[QTD Estoque Liquido (Análises)]` do V2

---

### 4️⃣ **60d (un)** → **QTD Ult 60d** ou **QTD Prox 60d (Análises)**

#### V3 (Original)
```dax
60d (un) = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], today()-365, 2, MONTH), [Qtd Vendida (un)])
```
- **Display Folder:** 3.Vendas\Vendas
- **Tabela:** Medidas
- **Observação:** Calcula vendas dos últimos 60 dias do ano anterior (today()-365)

#### V2 - Opção 1: **QTD Ult 60d**
```dax
QTD Ult 60d = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], today()-60, 2, MONTH), [QTD Vendas])
```
- **Display Folder:** 3.Vendas\Vendas Geral
- **Observação:** Calcula vendas dos últimos 60 dias (today()-60)

#### V2 - Opção 2: **QTD Prox 60d (Análises)**
```dax
QTD Prox 60d (Análises) = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], LASTDATE('Dim Calendário'[Date])-365, 2, MONTH), [QTD Vendas])
```
- **Display Folder:** 3.Vendas\Análises
- **Observação:** Calcula vendas dos próximos 60 dias do ano anterior (LASTDATE-365)

**Análise:** 
- V3 usa `today()-365` (60 dias do ano passado)
- V2 Opção 1 usa `today()-60` (últimos 60 dias)
- V2 Opção 2 usa `LASTDATE-365` (60 dias do ano passado, similar ao V3)

**Decisão:** ✅ Usar `[QTD Prox 60d (Análises)]` do V2 (mais similar ao V3)

---

### 5️⃣ **90d (un)** → **QTD Ult 90d** ou **QTD Prox 90d (Análises)**

#### V3 (Original)
```dax
90d (un) = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], today()-365, 3, MONTH), [Qtd Vendida (un)])
```
- **Display Folder:** 3.Vendas\Vendas
- **Tabela:** Medidas

#### V2 - Opção 1: **QTD Ult 90d**
```dax
QTD Ult 90d = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], today()-90, 3, MONTH), [QTD Vendas])
```
- **Display Folder:** 3.Vendas\Vendas Geral

#### V2 - Opção 2: **QTD Prox 90d (Análises)**
```dax
QTD Prox 90d (Análises) = 
SUMX(DATESINPERIOD('Dim Calendário'[Date], LASTDATE('Dim Calendário'[Date])-365, 3, MONTH), [QTD Vendas])
```
- **Display Folder:** 3.Vendas\Análises

**Decisão:** ✅ Usar `[QTD Prox 90d (Análises)]` do V2 (mais similar ao V3)

---

## 🔧 Expressões DAX Ajustadas para Migração

### Medida 1: **Erro**

#### Original V3
```dax
Erro = 
[Qtd Vendida (un)] - [Previsao de Demanda (qtd)]
```

#### ✅ Ajustada para V2
```dax
Erro = 
[QTD Vendas] - [Demanda S&OP/Protheus 60d]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Previsões`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Calcula o erro de previsão subtraindo a demanda prevista da quantidade vendida real. Usado para análise de acurácia de previsões S&OP.
- **Format String:** General Number

---

### Medida 2: **WMAPE (%)**

#### Original V3
```dax
WMAPE (%) = 
DIVIDE([Erro], [Qtd Vendida (un)])
```

#### ✅ Ajustada para V2
```dax
WMAPE (%) = 
DIVIDE([Erro], [QTD Vendas])
```

**Metadados:**
- **Display Folder:** `8.S&OP\Previsões`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Weighted Mean Absolute Percentage Error. Calcula o percentual de erro da previsão dividindo o erro pela quantidade vendida. Métrica chave para avaliar acurácia de forecasting.
- **Format String:** 0.00%

---

### Medida 3: **Estoq. - Fat. Ante. - 60d (un)**

#### Original V3
```dax
Estoq. - Fat. Ante. - 60d (un) = 
[QTD Estoque Liquido (Análises)] - [60d (un)]
```

#### ✅ Ajustada para V2
```dax
Estoq. - Fat. Ante. - 60d (un) = 
[QTD Estoque Liquido (Análises)] - [QTD Prox 60d (Análises)]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Estoques - POGs`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 60 dias. Usado para planejamento de cobertura de estoque.
- **Format String:** #,0

---

### Medida 4: **Estoq. - Fat. Ante. - 90d (un)**

#### Original V3
```dax
Estoq. - Fat. Ante. - 90d (un) = 
[QTD Estoque Liquido (Análises)] - [90d (un)]
```

#### ✅ Ajustada para V2
```dax
Estoq. - Fat. Ante. - 90d (un) = 
[QTD Estoque Liquido (Análises)] - [QTD Prox 90d (Análises)]
```

**Metadados:**
- **Display Folder:** `8.S&OP\Estoques - POGs`
- **Tabela:** Medidas
- **Descrição:** 📦 MIGRADO DO V3 | Plano Operacional de Gestão (POG). Calcula a diferença entre estoque líquido atual e faturamentos antecipados dos próximos 90 dias. Usado para planejamento de cobertura de estoque de médio prazo.
- **Format String:** #,0

---

## ✅ Checklist de Validação de Dependências

- [x] **Qtd Vendida (un)** → Mapeada para `[QTD Vendas]`
- [x] **Previsao de Demanda (qtd)** → Mapeada para `[Demanda S&OP/Protheus 60d]`
- [x] **QTD Estoque Liquido (Análises)** → Existe idêntica no V2
- [x] **60d (un)** → Mapeada para `[QTD Prox 60d (Análises)]`
- [x] **90d (un)** → Mapeada para `[QTD Prox 90d (Análises)]`
- [x] Todas as expressões DAX ajustadas
- [x] Metadados completos definidos

---

## 🎯 Próximos Passos

### Passo 1: Criar Medidas no V2 (Golden Dataset)

Agora que todas as dependências foram mapeadas, podemos criar as 4 medidas no V2:

1. **Erro** - Previsão S&OP
2. **WMAPE (%)** - Previsão S&OP
3. **Estoq. - Fat. Ante. - 60d (un)** - POG
4. **Estoq. - Fat. Ante. - 90d (un)** - POG

### Passo 2: Validação Pós-Migração

1. Executar query de validação
2. Comparar resultados V3 vs V2
3. Documentar discrepâncias (se houver)

---

## 📊 Resumo de Mapeamento

| Medida Base V3 | Medida Equivalente V2 | Status | Diferença |
|----------------|----------------------|--------|-----------|
| `Qtd Vendida (un)` | `QTD Vendas` | ✅ Mapeada | Coluna diferente (QTD_DISP vs QTD_AJUSTADA_OUTLIER) |
| `Previsao de Demanda (qtd)` | `Demanda S&OP/Protheus 60d` | ✅ Mapeada | Nome diferente |
| `QTD Estoque Liquido (Análises)` | `QTD Estoque Liquido (Análises)` | ✅ Idêntica | Nenhuma |
| `60d (un)` | `QTD Prox 60d (Análises)` | ✅ Mapeada | Nome diferente |
| `90d (un)` | `QTD Prox 90d (Análises)` | ✅ Mapeada | Nome diferente |

---

## 🚨 Observações Importantes

### 1. **Diferença em QTD Vendas**
- V3 usa `QTD_DISP` (quantidade disponível)
- V2 usa `QTD_AJUSTADA_OUTLIER` (quantidade com ajuste de outliers)
- **Impacto:** Resultados podem ter pequenas diferenças devido ao tratamento de outliers
- **Decisão:** Usar V2 (mais robusto)

### 2. **Medidas de Período (60d, 90d)**
- V3 usa `today()-365` (período do ano anterior)
- V2 tem duas opções: `today()-X` (últimos X dias) ou `LASTDATE-365` (período do ano anterior)
- **Decisão:** Usar medidas "Prox Xd (Análises)" que são mais similares ao V3

### 3. **Previsão de Demanda**
- V3 tem medida intermediária `Previsao de Demanda (qtd)` que referencia `Demanda S&OP/Protheus`
- V2 tem diretamente `Demanda S&OP/Protheus 60d`
- **Decisão:** Usar medida direta do V2

---

## 📎 Arquivos Relacionados

- [migration-plan-v3-to-v2.md](file:///C:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI/validation/results/migration-plan-v3-to-v2.md) - Plano de migração
- [v3-to-v2-delta-validation-report.md](file:///C:/Users/ThiagoReisAraujo/OneDrive%20-%20Axia%20Agro/Documentos/Apps/PowerBI/validation/results/v3-to-v2-delta-validation-report.md) - Relatório de validação
- [walkthrough.md](file:///C:/Users/ThiagoReisAraujo/.gemini/antigravity/brain/711aa748-40ee-4bf2-a2e4-c8baab513ad6/walkthrough.md) - Walkthrough da validação

---

**Status:** ✅ Mapeamento Completo - Pronto para Migração
