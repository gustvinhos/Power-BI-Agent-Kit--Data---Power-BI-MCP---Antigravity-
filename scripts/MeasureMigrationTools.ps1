# ============================================================================
# MeasureMigrationTools.ps1
# Ferramentas para migração de medidas com documentação automática
# Data: 2026-02-03
# ============================================================================

<#
.SYNOPSIS
    Módulo com funções para criação e validação de medidas migradas

.DESCRIPTION
    Contém:
    - New-MigratedMeasure: Template para criar medidas com documentação automática
    - Test-MeasureHasDocumentation: Valida se medida possui documentação adequada
    - Export-MeasureToTMDL: Exporta definição de medida para TMDL

.EXAMPLE
    Import-Module .\MeasureMigrationTools.ps1
    $measure = New-MigratedMeasure -Name "Teste" -Expression "[A] + [B]" ...
#>

# ============================================================================
# FUNÇÃO 1: New-MigratedMeasure
# ============================================================================

function New-MigratedMeasure {
    <#
    .SYNOPSIS
        Cria definição de medida migrada com documentação completa

    .DESCRIPTION
        Gera automaticamente comentários DAX seguindo o padrão best-practices/dax-comments.md
        para medidas migradas do V3 para o V2.

    .PARAMETER Name
        Nome da medida (obrigatório)

    .PARAMETER Expression
        Expressão DAX pura (sem comentários) - obrigatório

    .PARAMETER Purpose
        Descrição do propósito de negócio (obrigatório)

    .PARAMETER Logic
        Descrição da lógica passo-a-passo (obrigatório para medidas complexas)

    .PARAMETER Dependencies
        Array de dependências (medidas, tabelas, colunas) - obrigatório

    .PARAMETER DisplayFolder
        Pasta de exibição no Power BI (obrigatório)

    .PARAMETER FormatString
        String de formatação (ex: "#,0", "0.00%", "R$ #,0.00")

    .PARAMETER SourceModel
        Modelo de origem (padrão: "S&OP Axia V3")

    .PARAMETER SourceTable
        Tabela de origem (padrão: "Medidas")

    .PARAMETER BusinessRules
        Regras de negócio adicionais (opcional)

    .PARAMETER Notes
        Notas adicionais (opcional)

    .EXAMPLE
        $measure = New-MigratedMeasure `
            -Name "Erro (S&OP)" `
            -Expression "[QTD Vendas] - [Demanda S&OP/Protheus 60d]" `
            -Purpose "Calcula erro de previsão S&OP" `
            -Logic "1. Obtém vendas reais`n2. Obtém previsão`n3. Calcula diferença" `
            -Dependencies @("[QTD Vendas]", "[Demanda S&OP/Protheus 60d]") `
            -DisplayFolder "8.S&OP\Previsões" `
            -FormatString "#,0"

    .OUTPUTS
        Hashtable pronto para usar com Power BI MCP measure_operations
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Expression,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Purpose,

        [Parameter(Mandatory = $false)]
        [string]$Logic = "",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Dependencies,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayFolder,

        [Parameter(Mandatory = $false)]
        [string]$FormatString = "",

        [Parameter(Mandatory = $false)]
        [string]$SourceModel = "S&OP Axia V3",

        [Parameter(Mandatory = $false)]
        [string]$SourceTable = "Medidas",

        [Parameter(Mandatory = $false)]
        [string]$BusinessRules = "",

        [Parameter(Mandatory = $false)]
        [string]$Notes = ""
    )

    # Data atual
    $date = Get-Date -Format "yyyy-MM-dd"

    # Construir seção de dependências
    $dependenciesSection = ($Dependencies | ForEach-Object { "        - $_" }) -join "`n"

    # Construir seção de lógica (se fornecida)
    $logicSection = ""
    if ($Logic) {
        $logicLines = $Logic -split "`n" | ForEach-Object { "        $_" }
        $logicSection = @"

    LÓGICA:
$($logicLines -join "`n")
"@
    }

    # Construir seção de regras de negócio (se fornecidas)
    $businessRulesSection = ""
    if ($BusinessRules) {
        $businessRulesLines = $BusinessRules -split "`n" | ForEach-Object { "        $_" }
        $businessRulesSection = @"

    REGRA DE NEGÓCIO:
$($businessRulesLines -join "`n")
"@
    }

    # Construir seção de notas (se fornecidas)
    $notesSection = ""
    if ($Notes) {
        $notesLines = $Notes -split "`n" | ForEach-Object { "        $_" }
        $notesSection = @"

    NOTAS:
$($notesLines -join "`n")
"@
    }

    # Construir bloco de comentários completo
    $commentBlock = @"
/*
    📦 MIGRADO DO V3 | $Name

    PROPÓSITO:
        $Purpose
$logicSection

    DEPENDÊNCIAS:
$dependenciesSection

    ORIGEM:
        Modelo: $SourceModel
        Tabela: $SourceTable
        Data Migração: $date
$businessRulesSection
$notesSection

    AUTOR: Data Team - Migração V3→V2
    DATA: $date
*/
$Expression
"@

    # Construir descrição curta (annotation)
    $shortDescription = "📦 MIGRADO DO V3 | $Purpose"

    # Retornar objeto MCP-ready
    $measureDefinition = @{
        operation = "Create"
        tableName = "Medidas"
        createDefinition = @{
            name = $Name
            expression = $commentBlock
            displayFolder = $DisplayFolder
            description = $shortDescription
        }
    }

    # Adicionar formatString se fornecido
    if ($FormatString) {
        $measureDefinition.createDefinition.formatString = $FormatString
    }

    return $measureDefinition
}

# ============================================================================
# FUNÇÃO 2: Test-MeasureHasDocumentation
# ============================================================================

function Test-MeasureHasDocumentation {
    <#
    .SYNOPSIS
        Valida se uma expressão DAX possui documentação adequada

    .DESCRIPTION
        Verifica se a expressão contém:
        - Bloco de comentários /* ... */
        - Seção PROPÓSITO
        - Seção DEPENDÊNCIAS
        - Para medidas migradas: seção ORIGEM

    .PARAMETER Expression
        Expressão DAX a ser validada

    .PARAMETER IsMigrated
        Se $true, valida também seção ORIGEM (padrão: $true)

    .PARAMETER Strict
        Se $true, valida também LÓGICA e outras seções (padrão: $false)

    .EXAMPLE
        Test-MeasureHasDocumentation -Expression $myExpression

    .EXAMPLE
        Test-MeasureHasDocumentation -Expression $myExpression -Strict

    .OUTPUTS
        $true se válido, lança exceção se inválido
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Expression,

        [Parameter(Mandatory = $false)]
        [bool]$IsMigrated = $true,

        [Parameter(Mandatory = $false)]
        [switch]$Strict
    )

    $errors = @()

    # Verificar presença de bloco de comentários
    if ($Expression -notmatch '\/\*.*\*\/') {
        $errors += "❌ Bloco de comentários /* ... */ não encontrado"
    }

    # Verificar seção PROPÓSITO
    if ($Expression -notmatch 'PROPÓSITO:') {
        $errors += "❌ Seção PROPÓSITO não encontrada"
    }

    # Verificar seção DEPENDÊNCIAS
    if ($Expression -notmatch 'DEPENDÊNCIAS:') {
        $errors += "❌ Seção DEPENDÊNCIAS não encontrada"
    }

    # Verificar seção ORIGEM (se migrada)
    if ($IsMigrated -and $Expression -notmatch 'ORIGEM:') {
        $errors += "❌ Seção ORIGEM não encontrada (obrigatória para medidas migradas)"
    }

    # Verificar emoji (se migrada)
    if ($IsMigrated -and $Expression -notmatch '📦') {
        $errors += "❌ Emoji 📦 não encontrado (obrigatório para medidas migradas)"
    }

    # Validações adicionais (modo strict)
    if ($Strict) {
        # Verificar seção LÓGICA para medidas complexas (múltiplas linhas)
        $lineCount = ($Expression -split "`n").Count
        if ($lineCount -gt 5 -and $Expression -notmatch 'LÓGICA:') {
            $errors += "⚠️  Seção LÓGICA recomendada para medidas complexas (modo strict)"
        }

        # Verificar data de migração
        if ($IsMigrated -and $Expression -notmatch 'Data Migração: \d{4}-\d{2}-\d{2}') {
            $errors += "⚠️  Data de migração não encontrada ou em formato incorreto (modo strict)"
        }

        # Verificar autor
        if ($Expression -notmatch 'AUTOR:') {
            $errors += "⚠️  Seção AUTOR não encontrada (modo strict)"
        }
    }

    # Se houver erros, lançar exceção
    if ($errors.Count -gt 0) {
        $errorMessage = @"

🔴 VALIDAÇÃO DE DOCUMENTAÇÃO FALHOU
====================================

Expressão analisada:
-------------------
$Expression

Problemas encontrados ($($errors.Count)):
-------------------
$($errors -join "`n")

Documentação obrigatória deve incluir:
- Bloco de comentários /* ... */
- Seção PROPÓSITO (objetivo de negócio)
- Seção DEPENDÊNCIAS (medidas/tabelas usadas)
- Seção ORIGEM (modelo, tabela, data de migração)
- Emoji 📦 para medidas migradas

Veja padrão completo em:
  best-practices/dax-comments.md

Exemplo de medida bem documentada:
  validation/results/medidas-corrigidas-com-documentacao.md

"@

        throw $errorMessage
    }

    # Se passou, retornar sucesso
    Write-Host "✅ Validação OK: Medida possui documentação adequada" -ForegroundColor Green
    return $true
}

# ============================================================================
# FUNÇÃO 3: Export-MeasureToTMDL
# ============================================================================

function Export-MeasureToTMDL {
    <#
    .SYNOPSIS
        Exporta definição de medida para formato TMDL

    .DESCRIPTION
        Converte definição de medida (hashtable) para formato TMDL
        usado pelo Power BI

    .PARAMETER MeasureDefinition
        Hashtable com definição da medida

    .EXAMPLE
        $measure = New-MigratedMeasure ...
        Export-MeasureToTMDL -MeasureDefinition $measure

    .OUTPUTS
        String no formato TMDL
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]$MeasureDefinition
    )

    $def = $MeasureDefinition.createDefinition
    $name = $def.name
    $expression = $def.expression -replace '(?m)^', '        ' # Indentar
    $displayFolder = $def.displayFolder
    $formatString = $def.formatString
    $description = $def.description

    $tmdl = @"
    measure '$name' =
$expression

        displayFolder: $displayFolder
        formatString: $formatString

        annotation Description = $description
"@

    return $tmdl
}

# ============================================================================
# FUNÇÃO 4: New-MeasureMigrationReport
# ============================================================================

function New-MeasureMigrationReport {
    <#
    .SYNOPSIS
        Gera relatório de migração de medidas

    .DESCRIPTION
        Cria relatório markdown documentando medidas migradas

    .PARAMETER Measures
        Array de definições de medidas

    .PARAMETER OutputPath
        Caminho para salvar relatório

    .EXAMPLE
        New-MeasureMigrationReport -Measures $measures -OutputPath "report.md"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Measures,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $date = Get-Date -Format "yyyy-MM-dd HH:mm"

    $report = @"
# 📊 Relatório de Migração de Medidas

**Data:** $date
**Total de Medidas:** $($Measures.Count)

---

## Medidas Migradas

"@

    $index = 1
    foreach ($measure in $Measures) {
        $def = $measure.createDefinition
        $report += @"

### $index. $($def.name)

**Display Folder:** ``$($def.displayFolder)``
**Format:** ``$($def.formatString)``

**Expressão:**
``````dax
$($def.expression)
``````

---

"@
        $index++
    }

    $report | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "✅ Relatório salvo em: $OutputPath" -ForegroundColor Green
}

# ============================================================================
# EXPORTAR FUNÇÕES
# ============================================================================

Export-ModuleMember -Function @(
    'New-MigratedMeasure',
    'Test-MeasureHasDocumentation',
    'Export-MeasureToTMDL',
    'New-MeasureMigrationReport'
)

Write-Host "✅ Módulo MeasureMigrationTools carregado com sucesso" -ForegroundColor Green
Write-Host @"

Funções disponíveis:
  • New-MigratedMeasure           - Cria medida com documentação automática
  • Test-MeasureHasDocumentation  - Valida documentação de medida
  • Export-MeasureToTMDL          - Exporta para formato TMDL
  • New-MeasureMigrationReport    - Gera relatório de migração

Para ajuda: Get-Help <nome-da-função> -Detailed

"@ -ForegroundColor Cyan
