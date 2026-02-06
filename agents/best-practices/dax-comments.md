# DAX Comments - Padrões de Comentários

Padrões de comentários e documentação para código DAX em Power BI.

## Por que Comentar?

1. **Manutenção**: Futuro desenvolvedor (ou você mesmo) entende a lógica
2. **Debugging**: Facilita isolamento de problemas
3. **Onboarding**: Novos membros entendem o modelo rapidamente
4. **Auditoria**: Regras de negócio ficam documentadas

## Tipos de Comentários DAX

### Comentário de Linha
```dax
// Este é um comentário de linha
Total Sales = SUM(FactSales[SalesAmount])  // Comentário no final
```

### Comentário de Bloco
```dax
/* 
Este é um comentário
de múltiplas linhas
*/
Total Sales = SUM(FactSales[SalesAmount])
```

## Padrão de Cabeçalho

Para medidas complexas, use um cabeçalho padronizado:

```dax
/*
==================================================
NOME: Sales Performance Index
DESCRIÇÃO: Calcula índice de performance de vendas
           comparando atual vs meta ajustada sazonalmente
DEPENDÊNCIAS:
  - [Total Sales]
  - [Sales Target]
  - [Seasonality Factor]
REGRA DE NEGÓCIO:
  - Performance = (Vendas / Meta) * Fator Sazonal
  - Retorna BLANK se não houver meta
AUTOR: dax-specialist
DATA: 2025-01-15
==================================================
*/
Sales Performance Index = 
VAR ActualSales = [Total Sales]
VAR Target = [Sales Target]
VAR SeasonFactor = [Seasonality Factor]
RETURN
IF(
    Target = 0,
    BLANK(),
    DIVIDE(ActualSales, Target) * SeasonFactor
)
```

### Template Simplificado

Para medidas de complexidade média:

```dax
// DESCRIÇÃO: [O que a medida faz]
// REGRA: [Regra de negócio]
// DEPENDE DE: [Outras medidas]
```

**Exemplo:**
```dax
// DESCRIÇÃO: Crescimento de vendas ano a ano
// REGRA: (Atual - Anterior) / Anterior
// DEPENDE DE: [Total Sales], [Sales PY]
YoY Growth % = 
VAR Current = [Total Sales]
VAR Previous = [Sales PY]
RETURN
DIVIDE(Current - Previous, Previous)
```

## Comentários Inline

Use para explicar partes específicas do código:

```dax
ABC Class = 
VAR CurrentRank = [Product Rank]
VAR TotalProducts = CALCULATE(
    DISTINCTCOUNT(DimProduct[ProductKey]),
    ALL(DimProduct)  // Remove filtros para contar todos
)
VAR ClassA = TotalProducts * 0.2  // Top 20% dos produtos
VAR ClassB = TotalProducts * 0.5  // Top 50% (20% + 30%)
RETURN
SWITCH(
    TRUE(),
    CurrentRank <= ClassA, "A",   // Alta prioridade
    CurrentRank <= ClassB, "B",   // Média prioridade
    "C"                            // Baixa prioridade
)
```

## Quando Comentar

### SEMPRE Comente

1. **Regras de negócio não óbvias**
   ```dax
   // Desconto especial: clientes Premium com mais de 10 pedidos
   // recebem 15% adicional além do desconto base
   ```

2. **Workarounds ou truques**
   ```dax
   // WORKAROUND: Usando MAX em vez de VALUES para evitar erro
   // quando múltiplos valores estão no contexto
   VAR SelectedProduct = MAX(DimProduct[ProductName])
   ```

3. **Decisões de design**
   ```dax
   // DECISÃO: Usando DATEADD em vez de SAMEPERIODLASTYEAR
   // porque os dados começam em março (ano fiscal)
   ```

4. **Dependências externas**
   ```dax
   // DEPENDE DE: Tabela DimDate marcada como Date Table
   // DEPENDE DE: Relacionamento FactSales[OrderDate] -> DimDate[Date]
   ```

5. **Limitações conhecidas**
   ```dax
   // LIMITAÇÃO: Não funciona corretamente se selecionado
   // mais de um ano simultaneamente
   ```

### NÃO Comente

1. **Código auto-explicativo**
   ```dax
   // NÃO NECESSÁRIO:
   // Total Sales = SUM(FactSales[SalesAmount])  // Soma as vendas
   ```

2. **Repetição do nome da medida**
   ```dax
   // NÃO FAÇA:
   // Esta medida calcula Total Sales
   Total Sales = ...
   ```

## Comentários por Seção

Para medidas longas, divida em seções:

```dax
Target Achievement with Tolerance = 
// ===== CONFIG =====
VAR ToleranceThreshold = 0.05  // 5% de tolerância
VAR MinTarget = 1000           // Valor mínimo para considerar

// ===== INPUTS =====
VAR ActualValue = [Total Sales]
VAR TargetValue = [Sales Target]

// ===== VALIDAÇÃO =====
VAR IsValid = TargetValue >= MinTarget

// ===== CÁLCULO =====
VAR RawAchievement = DIVIDE(ActualValue, TargetValue)
VAR AdjustedAchievement = 
    IF(
        RawAchievement >= 1 - ToleranceThreshold,
        1,  // Dentro da tolerância = 100%
        RawAchievement
    )

// ===== RESULTADO =====
RETURN
IF(IsValid, AdjustedAchievement, BLANK())
```

## Emoji Markers

Use emojis para marcar tipos de comentários:

```dax
// 📌 IMPORTANTE: Esta medida é usada em vários relatórios críticos
// ⚠️ CUIDADO: Não remover sem verificar dependências
// 🐛 BUG KNOWN: Valor incorreto para datas futuras
// 🔧 TODO: Otimizar performance quando tabela > 1M linhas
// ✅ TESTADO: Validado com dados de 2020-2024
// 🔗 RELACIONADO: Ver também [Sales Adjusted]
```

## Documentação de Migração

Para objetos migrados, documente a origem:

```dax
/*
📦 MIGRADO DO V3
Original: SalesCalc.TotalAmt
Data: 2025-01-15
Autor: migration-executor

ALTERAÇÕES:
- Renomeado de TotalAmt para Total Sales
- Adicionado tratamento de BLANK
- Movido de tabela Sales para Measures
*/
Total Sales = 
COALESCE(SUM(FactSales[SalesAmount]), 0)
```

## Comentários para Debugging

### Marcar Para Revisão
```dax
// TODO: Validar com Finance se regra de arredondamento está correta
// REVIEW: Este cálculo parece duplicar linhas em alguns cenários
```

### Manter Versão Anterior
```dax
/*
// VERSÃO ANTERIOR (mantida para referência):
// Old Version = SUM(Sales[Amount])

// NOVA VERSÃO:
// Adicionado filtro para excluir devoluções
*/
Total Sales = 
CALCULATE(
    SUM(FactSales[SalesAmount]),
    FactSales[IsReturn] = FALSE
)
```

## Anti-Patterns de Comentários

❌ **Comentário obsoleto**
```dax
// Calcula total de vendas do mês
Total Sales = SUM(FactSales[SalesAmount])  // Não calcula só do mês!
```

❌ **Comentário óbvio demais**
```dax
// Declara variável chamada Sales
VAR Sales = [Total Sales]
```

❌ **Comentar código morto**
```dax
// Total Sales = SUM(Sales[Amount])
// Total = SUM(Sales[Amount] * 1.1)
// NewTotal = SUMX(...)
Final Total = ...  // Confuso!
```

❌ **Comentário que não explica o "porquê"**
```dax
// Multiplica por 1.1
VAR Adjusted = Value * 1.1  // Por que 1.1? Qual regra?
```

## Checklist de Comentários

Antes de finalizar medida:

- [ ] Medidas complexas têm cabeçalho explicativo?
- [ ] Regras de negócio estão documentadas?
- [ ] Decisões de design estão justificadas?
- [ ] Dependências estão listadas?
- [ ] Limitações conhecidas estão documentadas?
- [ ] Comentários estão atualizados com o código?
- [ ] Não há comentários obsoletos ou enganosos?

---

**Lembre-se**: Bons comentários explicam o PORQUÊ, não o QUÊ. O código já diz o que faz; o comentário explica a razão.
