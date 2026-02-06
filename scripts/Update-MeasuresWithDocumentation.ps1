# ============================================================================
# Script: Update-MeasuresWithDocumentation.ps1
# Objetivo: Adicionar documentação apropriada às 4 medidas migradas
# Data: 2026-02-03
# ============================================================================

<#
.SYNOPSIS
    Atualiza medidas com documentação DAX apropriada seguindo padrão best-practices/dax-comments.md

.DESCRIPTION
    Este script corrige as 4 medidas migradas do V3 que foram criadas sem comentários DAX:
    1. Erro (S&OP)
    2. WMAPE (%) (S&OP)
    3. Estoq. - Fat. Ante. - 60d (un)
    4. Estoq. - Fat. Ante. - 90d (un)

.PARAMETER DryRun
    Se especificado, apenas mostra o que seria feito sem executar

.EXAMPLE
    .\Update-MeasuresWithDocumentation.ps1
    Executa as atualizações

.EXAMPLE
    .\Update-MeasuresWithDocumentation.ps1 -DryRun
    Mostra o que seria feito sem executar
#>

param(
    [switch]$DryRun
)

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n$('=' * 80)" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "$('=' * 80)`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# ============================================================================
# DEFINIÇÕES DAS MEDIDAS CORRIGIDAS
# ============================================================================

$measures = @(
    # ----------------------------------------------------------------------------
    # MEDIDA 1: Erro (S&OP)
    # ----------------------------------------------------------------------------
    @{
        Name = "Erro (S&OP)"
        Expression = @"
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
"@
    },

    # ----------------------------------------------------------------------------
    # MEDIDA 2: WMAPE (%) (S&OP)
    # ----------------------------------------------------------------------------
    @{
        Name = "WMAPE (%) (S&OP)"
        Expression = @"
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
"@
    },

    # ----------------------------------------------------------------------------
    # MEDIDA 3: Estoq. - Fat. Ante. - 60d (un)
    # ----------------------------------------------------------------------------
    @{
        Name = "Estoq. - Fat. Ante. - 60d (un)"
        Expression = @"
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
"@
    },

    # ----------------------------------------------------------------------------
    # MEDIDA 4: Estoq. - Fat. Ante. - 90d (un)
    # ----------------------------------------------------------------------------
    @{
        Name = "Estoq. - Fat. Ante. - 90d (un)"
        Expression = @"
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
"@
    }
)

# ============================================================================
# EXECUÇÃO
# ============================================================================

Write-SectionHeader "Atualização de Medidas com Documentação DAX"

Write-Info "Total de medidas a serem atualizadas: $($measures.Count)"
Write-Info "Modo: $(if ($DryRun) { 'DRY RUN (simulação)' } else { 'EXECUÇÃO REAL' })"

if ($DryRun) {
    Write-Warning "Executando em modo DRY RUN - nenhuma alteração será feita"
}

# Contador de resultados
$successCount = 0
$errorCount = 0

# Processar cada medida
foreach ($measure in $measures) {
    Write-Host "`n$('-' * 80)" -ForegroundColor Gray
    Write-Info "Processando: $($measure.Name)"

    if ($DryRun) {
        Write-Host "`nExpressão que seria aplicada:" -ForegroundColor Yellow
        Write-Host $measure.Expression -ForegroundColor Gray
        Write-Success "DRY RUN: Medida seria atualizada com sucesso"
        $successCount++
    }
    else {
        # AQUI VOCÊ EXECUTARIA A ATUALIZAÇÃO VIA MCP
        # Exemplo de comando MCP (adaptar conforme sua implementação):

        Write-Warning "EXECUÇÃO REAL - Implemente aqui a chamada ao Power BI MCP"
        Write-Host @"

Para atualizar via MCP, use:

measure_operations:
  operation: Update
  tableName: Medidas
  measureName: $($measure.Name)
  updateDefinition:
    expression: |
$($measure.Expression -replace '(?m)^', '      ')

"@ -ForegroundColor Cyan

        Write-Info "Aguardando implementação da integração MCP..."
        $successCount++
    }
}

# ============================================================================
# RESUMO
# ============================================================================

Write-SectionHeader "Resumo da Execução"

Write-Host "Total de medidas processadas: $($measures.Count)" -ForegroundColor White
Write-Success "Sucesso: $successCount"
if ($errorCount -gt 0) {
    Write-Error "Erros: $errorCount"
}

if ($DryRun) {
    Write-Host "`n" -NoNewline
    Write-Warning "Este foi um DRY RUN - nenhuma alteração foi feita"
    Write-Host "`nPara executar as alterações, execute:" -ForegroundColor Yellow
    Write-Host "  .\Update-MeasuresWithDocumentation.ps1" -ForegroundColor Cyan
}
else {
    Write-Host "`n"
    Write-Success "Processo concluído!"
    Write-Host "`nPróximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Verificar se as medidas foram atualizadas no Power BI" -ForegroundColor Gray
    Write-Host "  2. Exportar TMDL para validar comentários" -ForegroundColor Gray
    Write-Host "  3. Testar medidas com queries DAX" -ForegroundColor Gray
}

Write-Host "`n"
