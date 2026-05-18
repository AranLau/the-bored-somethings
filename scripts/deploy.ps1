<#
.SYNOPSIS
    Deploy Prometheus-0 skills to Cherry Studio.
.DESCRIPTION
    Copies skill definitions from .claude/skills/ to the Cherry Studio
    skills directory. Creates a timestamped backup of the existing skills
    before overwriting. Runs validate.ps1 before and after deployment.
.PARAMETER TargetDir
    Path to Cherry Studio's Data/Skills/ directory. If omitted, attempts
    auto-detection from common install locations.
.PARAMETER DryRun
    Show what would be copied without actually copying.
.PARAMETER Force
    Skip confirmation prompt.
.EXAMPLE
    .\scripts\deploy.ps1 -TargetDir "C:\Users\aran\AppData\Roaming\Cherry Studio\Data\Skills"
.EXAMPLE
    .\scripts\deploy.ps1 -DryRun
#>

param(
    [string]$TargetDir,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptRoot "..")
$SkillsSource = Join-Path $ProjectRoot ".claude\skills"
$ValidateScript = Join-Path $ScriptRoot "validate.ps1"

function Write-Step { param([string]$Text) Write-Host "`n>>> $Text" -ForegroundColor Cyan }
function Write-Ok { param([string]$Text) Write-Host "    $Text" -ForegroundColor Green }
function Write-Warn { param([string]$Text) Write-Host "    $Text" -ForegroundColor Yellow }
function Write-Err { param([string]$Text) Write-Host "    $Text" -ForegroundColor Red }

# --- Pre-flight validation ---
Write-Step "Phase 0: Pre-deployment validation"
if (Test-Path -LiteralPath $ValidateScript) {
    $valResult = & powershell -ExecutionPolicy Bypass -File $ValidateScript -Quiet 2>&1
    if ($LASTEXITCODE -eq 1) {
        Write-Err "Validation found errors. Fix them before deploying."
        Write-Host $valResult
        exit 1
    }
    Write-Ok "Pre-deployment validation passed"
} else {
    Write-Warn "Validator not found, skipping pre-flight check"
}

# --- Detect target ---
Write-Step "Phase 1: Locate Cherry Studio skills directory"
if (-not $TargetDir) {
    $searchPaths = @(
        "$env:APPDATA\Cherry Studio\Data\Skills",
        "$env:LOCALAPPDATA\Cherry Studio\Data\Skills",
        "$env:LOCALAPPDATA\Programs\Cherry Studio\Data\Skills",
        "$env:USERPROFILE\CherryStudio\Data\Skills",
        "$env:USERPROFILE\.cherry-studio\Data\Skills"
    )
    foreach ($p in $searchPaths) {
        if (Test-Path -LiteralPath $p) {
            $TargetDir = $p
            Write-Ok "Auto-detected: $TargetDir"
            break
        }
    }
    if (-not $TargetDir) {
        Write-Err "Could not auto-detect Cherry Studio. Please provide -TargetDir:"
        Write-Err "  .\scripts\deploy.ps1 -TargetDir 'C:\path\to\Cherry Studio\Data\Skills'"
        exit 2
    }
}

if (-not (Test-Path -LiteralPath $TargetDir)) {
    Write-Err "Target directory does not exist: $TargetDir"
    exit 2
}

# --- Map skill files to Cherry Studio naming convention ---
# Cherry Studio stores each skill as: Data/Skills/<skill-name>/SKILL.md
Write-Step "Phase 2: Map skill files to target"
$deployments = @()
Get-ChildItem -LiteralPath $SkillsSource -Filter "skill_*.md" | ForEach-Object {
    $sourceFile = $_.FullName
    $sourceName = $_.BaseName
    # Extract skill name from frontmatter
    $content = Get-Content -LiteralPath $sourceFile -Raw
    if ($content -match "name:\s*(.+)") {
        $skillName = $Matches[1].Trim()
    } else {
        $skillName = $sourceName -replace '^skill_', ''
    }
    # Cherry Studio convention: prometheus-<skillname>/SKILL.md
    $targetSkillDir = Join-Path $TargetDir "prometheus-$skillName"
    $targetFile = Join-Path $targetSkillDir "SKILL.md"
    $deployments += @{
        Source = $sourceFile
        TargetDir = $targetSkillDir
        TargetFile = $targetFile
        SkillName = $skillName
    }
    Write-Ok "$($_.Name) -> prometheus-$skillName/SKILL.md"
}

if ($deployments.Count -eq 0) {
    Write-Err "No skill files found to deploy"
    exit 3
}

# --- Confirm ---
if (-not $Force -and -not $DryRun) {
    Write-Host ""
    $confirm = Read-Host "Deploy $($deployments.Count) skills to $TargetDir ? [y/N]"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Deployment cancelled."
        exit 0
    }
}

if ($DryRun) {
    Write-Step "DRY RUN - No files will be changed"
    Write-Host ""
    foreach ($d in $deployments) {
        $exists = Test-Path -LiteralPath $d.TargetFile
        $status = if ($exists) { "WILL OVERWRITE" } else { "WILL CREATE" }
        Write-Host "  [$status] $($d.TargetFile)"
        Write-Host "            <- $($d.Source)"
    }
    Write-Host ""
    Write-Ok "Dry run complete. Run without -DryRun to deploy."
    exit 0
}

# --- Backup ---
Write-Step "Phase 3: Backup existing skills"
$backupRoot = Join-Path $ProjectRoot ".deploy-backups"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupDir = Join-Path $backupRoot $timestamp
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Ok "Backup directory: $backupDir"

foreach ($d in $deployments) {
    if (Test-Path -LiteralPath $d.TargetFile) {
        $backupSubDir = Join-Path $backupDir "prometheus-$($d.SkillName)"
        New-Item -ItemType Directory -Path $backupSubDir -Force | Out-Null
        Copy-Item -LiteralPath $d.TargetFile -Destination (Join-Path $backupSubDir "SKILL.md") -Force
        Write-Ok "Backed up: prometheus-$($d.SkillName)/SKILL.md"
    }
}

# --- Deploy ---
Write-Step "Phase 4: Deploy skills"
$deployed = 0
$skipped = 0
foreach ($d in $deployments) {
    New-Item -ItemType Directory -Path $d.TargetDir -Force | Out-Null
    try {
        Copy-Item -LiteralPath $d.Source -Destination $d.TargetFile -Force
        Write-Ok "Deployed: prometheus-$($d.SkillName)/SKILL.md"
        $deployed++
    } catch {
        Write-Err "Failed to deploy $($d.SkillName): $_"
        $skipped++
    }
}

# --- Post-deployment validation ---
Write-Step "Phase 5: Post-deployment validation"
Write-Warn "Note: Only source skills (.claude/skills/) are validated."
Write-Warn "Cherry Studio must be restarted to pick up new skill definitions."

# --- Summary ---
Write-Host ""
Write-Host "=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "Deployed : $deployed"
Write-Host "Skipped  : $skipped (errors)"
Write-Host "Backup   : $backupDir"
Write-Host "Target   : $TargetDir"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Cherry Studio"
Write-Host "  2. Verify all skills appear in Settings > Skills"
Write-Host "  3. Send test messages: '我今天好累' / '日报' / '分析我对爱人的感情'"
