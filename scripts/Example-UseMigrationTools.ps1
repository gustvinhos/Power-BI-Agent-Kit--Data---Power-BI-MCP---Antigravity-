# ============================================================================
# Example-UseMigrationTools.ps1
# Exemplo de uso das ferramentas de migração
# Data: 2026-02-03
# ============================================================================

<#
.SYNOPSIS
    Exemplo completo de como usar MeasureMigrationTools.ps1

.DESCRIPTION
    Demonstra:
    - Importação do módulo
    - Criação de medida com documentação automática
    - Validação de documentação
    - Exportação para TMDL
    - Geração de relatório
#>

# ============================================================================
# PASSO 1: Importar o módulo
# ============================================================================

Write-Host "`n📦 Importando módulo MeasureMigrationTools..." -ForegroundColor Cyan
Import-Module .\MeasureMigrationTools.ps1 -Force

# ============================================================================
# PASSO 2: Criar medida com documentação automática
# ============================================================================

Write-Host "`n✨ Criando medida com documentação automática..." -ForegroundColor Cyan

$medidaErro = New-MigratedMeasure `
    -Name "Erro (S&OP)" `
    -Expression "[QTD Vendas] - [Demanda S&OP/Protheus 60d]" `
    -Purpose "Calcula o erro absoluto entre a quantidade vendida real e a demanda prevista pelo S&OP/Protheus. Métrica fundamental para avaliar acurácia das previsões de demanda." `
    -Logic @"
1. Obtém quantidade vendida real (QTD Vendas)
2. Obtém demanda prevista para 60 dias (Demanda S&OP/Protheus 60d)
3. Calcula diferença (Real - Previsto)
4. Valores positivos: Vendeu MAIS que previsto
5. Valores negativos: Vendeu MENOS que previsto
"@ `
    -Dependencies @("[QTD Vendas]", "[Demanda S&OP/Protheus 60d]") `
    -DisplayFolder "8.S&OP\Previsões" `
    -BusinessRules @"
- Usado em análises de acurácia de forecasting
- Base para cálculo do WMAPE (%)
- Valores positivos indicam demanda subestimada
- Valores negativos indicam demanda superestimada
"@ `
    -Notes @"
- Horizonte de previsão: 60 dias
- Métrica usada em dashboards executivos
- Complementa o WMAPE (%) para análise completa
"@

Write-Host "✅ Medida criada com sucesso!" -ForegroundColor Green

# ============================================================================
# PASSO 3: Validar documentação
# ============================================================================

Write-Host "`n🔍 Validando documentação da medida..." -ForegroundColor Cyan

try {
    Test-MeasureHasDocumentation -Expression $medidaErro.createDefinition.expression
    Write-Host "✅ Validação passou!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Validação falhou:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    exit 1
}

# ============================================================================
# PASSO 4: Visualizar expressão gerada
# ============================================================================

Write-Host "`n📄 Expressão DAX gerada:" -ForegroundColor Cyan
Write-Host $medidaErro.createDefinition.expression -ForegroundColor Gray

# ============================================================================
# PASSO 5: Exportar para TMDL
# ============================================================================

Write-Host "`n📋 Exportando para formato TMDL..." -ForegroundColor Cyan
$tmdl = Export-MeasureToTMDL -MeasureDefinition $medidaErro
Write-Host $tmdl -ForegroundColor Gray

# ============================================================================
# PASSO 6: Criar múltiplas medidas
# ============================================================================

Write-Host "`n🔄 Criando múltiplas medidas..." -ForegroundColor Cyan

$measures = @()

# Medida 1: Erro (S&OP)
$measures += $medidaErro

# Medida 2: WMAPE (%)
$measures += New-MigratedMeasure `
    -Name "WMAPE (%) (S&OP)" `
    -Expression "DIVIDE([Erro (S&OP)], [QTD Vendas])" `
    -Purpose "Calcula o erro percentual ponderado da previsão de demanda. Métrica chave (KPI) para avaliar acurácia do forecasting S&OP." `
    -Logic @"
1. Obtém erro absoluto de previsão ([Erro (S&OP)])
2. Obtém quantidade vendida real como base ([QTD Vendas])
3. Divide erro pela quantidade vendida
4. Usa DIVIDE para evitar divisão por zero
5. Retorna BLANK se não houver vendas
"@ `
    -Dependencies @("[Erro (S&OP)]", "[QTD Vendas]") `
    -DisplayFolder "8.S&OP\Previsões" `
    -FormatString "0.00%" `
    -BusinessRules @"
- WMAPE < 10%: Previsão EXCELENTE
- WMAPE 10-20%: Previsão BOA
- WMAPE 20-30%: Previsão ACEITÁVEL
- WMAPE > 30%: Previsão RUIM (requer revisão)
"@ `
    -Notes @"
- Medida dependente: requer [Erro (S&OP)] existente
- Formato percentual (0.00%) facilita leitura
- Usado em dashboards executivos de S&OP
"@

# Medida 3: POG 60d
$measures += New-MigratedMeasure `
    -Name "Estoq. - Fat. Ante. - 60d (un)" `
    -Expression "[QTD Estoque Liquido (Análises)] - [QTD Prox 60d (Análises)]" `
    -Purpose "Calcula a cobertura de estoque líquido considerando faturamentos antecipados dos próximos 60 dias. Usado para planejamento de reposição e análise de risco de ruptura de curto prazo." `
    -Logic @"
1. Obtém estoque líquido atual (disponível)
2. Obtém faturamentos antecipados para próximos 60 dias
3. Calcula diferença (Estoque - Faturamentos Antecipados)
4. Valores positivos: Estoque SUFICIENTE para 60 dias
5. Valores negativos: Risco de RUPTURA nos próximos 60 dias
"@ `
    -Dependencies @("[QTD Estoque Liquido (Análises)]", "[QTD Prox 60d (Análises)]") `
    -DisplayFolder "8.S&OP\Estoques - POGs" `
    -FormatString "#,0" `
    -BusinessRules @"
- POG > 0: Estoque suficiente (situação SAUDÁVEL)
- POG = 0: Estoque justo (situação LIMÍTROFE)
- POG < 0: Risco de ruptura (situação CRÍTICA)
- Usado para alertas de reposição urgente
"@ `
    -Notes @"
- Horizonte de planejamento: Curto prazo (60 dias)
- Considera apenas faturamentos já antecipados/confirmados
- Não inclui demanda prevista não confirmada
- Complementa POG 90d para análise de médio prazo
"@

# Medida 4: POG 90d
$measures += New-MigratedMeasure `
    -Name "Estoq. - Fat. Ante. - 90d (un)" `
    -Expression "[QTD Estoque Liquido (Análises)] - [QTD Prox 90d (Análises)]" `
    -Purpose "Calcula a cobertura de estoque líquido considerando faturamentos antecipados dos próximos 90 dias. Usado para planejamento de reposição de médio prazo e análise estratégica de estoque." `
    -Logic @"
1. Obtém estoque líquido atual (disponível)
2. Obtém faturamentos antecipados para próximos 90 dias
3. Calcula diferença (Estoque - Faturamentos Antecipados)
4. Valores positivos: Estoque SUFICIENTE para 90 dias
5. Valores negativos: Risco de RUPTURA nos próximos 90 dias
"@ `
    -Dependencies @("[QTD Estoque Liquido (Análises)]", "[QTD Prox 90d (Análises)]") `
    -DisplayFolder "8.S&OP\Estoques - POGs" `
    -FormatString "#,0" `
    -BusinessRules @"
- POG > 0: Estoque suficiente (situação SAUDÁVEL)
- POG = 0: Estoque justo (situação LIMÍTROFE)
- POG < 0: Risco de ruptura (situação CRÍTICA)
- Horizonte maior que POG 60d para planejamento estratégico
"@ `
    -Notes @"
- Horizonte de planejamento: Médio prazo (90 dias)
- Considera apenas faturamentos já antecipados/confirmados
- Não inclui demanda prevista não confirmada
- Complementa POG 60d para visão de curto prazo
- Usado em reuniões S&OP mensais
"@

Write-Host "✅ Total de medidas criadas: $($measures.Count)" -ForegroundColor Green

# ============================================================================
# PASSO 7: Validar todas as medidas
# ============================================================================

Write-Host "`n🔍 Validando todas as medidas..." -ForegroundColor Cyan

$validationErrors = 0
foreach ($measure in $measures) {
    try {
        $null = Test-MeasureHasDocumentation -Expression $measure.createDefinition.expression
    }
    catch {
        Write-Host "❌ Falha na validação de: $($measure.createDefinition.name)" -ForegroundColor Red
        $validationErrors++
    }
}

if ($validationErrors -eq 0) {
    Write-Host "✅ Todas as $($measures.Count) medidas passaram na validação!" -ForegroundColor Green
}
else {
    Write-Host "❌ $validationErrors medidas falharam na validação" -ForegroundColor Red
}

# ============================================================================
# PASSO 8: Gerar relatório
# ============================================================================

Write-Host "`n📊 Gerando relatório de migração..." -ForegroundColor Cyan

$reportPath = ".\migration-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').md"
New-MeasureMigrationReport -Measures $measures -OutputPath $reportPath

# ============================================================================
# PASSO 9: Resumo
# ============================================================================

Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "  ✅ EXEMPLO COMPLETO EXECUTADO COM SUCESSO" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nResumo:" -ForegroundColor Cyan
Write-Host "  • Medidas criadas: $($measures.Count)" -ForegroundColor White
Write-Host "  • Validações bem-sucedidas: $($measures.Count - $validationErrors)" -ForegroundColor White
Write-Host "  • Relatório gerado: $reportPath" -ForegroundColor White

Write-Host "`nPróximos passos:" -ForegroundColor Yellow
Write-Host "  1. Revisar as medidas geradas" -ForegroundColor Gray
Write-Host "  2. Aplicar ao Power BI via MCP" -ForegroundColor Gray
Write-Host "  3. Testar com queries DAX" -ForegroundColor Gray
Write-Host "  4. Exportar TMDL para validação final" -ForegroundColor Gray

Write-Host "`n"
