<#
.SYNOPSIS
    Rollback Prometheus-0 skills to a previous deployment.
.DESCRIPTION
    Lists available backups from .deploy-backups/ and restores skills
    to Cherry Studio from a selected backup. If no backup is specified,
    restores the most recent.
.PARAMETER TargetDir
    Path to Cherry Studio's Data/Skills/ directory.
.PARAMETER BackupName
    Specific backup timestamp to restore (e.g., "2026-05-08_182500").
    If omitted, the most recent backup is used.
.PARAMETER List
    List all available backups without restoring.
.PARAMETER Force
    Skip confirmation prompt.
.EXAMPLE
    .\scripts\rollback.ps1 -List
.EXAMPLE
    .\scripts\rollback.ps1 -TargetDir "C:\Users\aran\AppData\Roaming\Cherry Studio\Data\Skills"
.EXAMPLE
    .\scripts\rollback.ps1 -BackupName "2026-05-08_182500" -Force
#>

param(
    [string]$TargetDir,
    [string]$BackupName,
    [switch]$List,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptRoot "..")
$BackupRoot = Join-Path $ProjectRoot ".deploy-backups"

function Write-Step { param([string]$Text) Write-Host "`n>>> $Text" -ForegroundColor Cyan }
function Write-Ok { param([string]$Text) Write-Host "    $Text" -ForegroundColor Green }
function Write-Warn { param([string]$Text) Write-Host "    $Text" -ForegroundColor Yellow }
function Write-Err { param([string]$Text) Write-Host "    $Text" -ForegroundColor Red }

# --- Check backup directory ---
if (-not (Test-Path -LiteralPath $BackupRoot)) {
    Write-Err "No backups found. Directory does not exist: $BackupRoot"
    Write-Err "Run deploy.ps1 first to create backups."
    exit 1
}

$backups = Get-ChildItem -LiteralPath $BackupRoot -Directory | Sort-Object Name -Descending
if ($backups.Count -eq 0) {
    Write-Err "No backups found in $BackupRoot"
    exit 1
}

# --- List mode ---
if ($List) {
    Write-Host "`n=== Available Backups ===" -ForegroundColor Cyan
    foreach ($b in $backups) {
        $skillCount = (Get-ChildItem -LiteralPath $b.FullName -Directory).Count
        Write-Host "  $($b.Name)  ($skillCount skills)"
    }
    Write-Host ""
    exit 0
}

# --- Select backup ---
if ($BackupName) {
    $selected = $backups | Where-Object { $_.Name -eq $BackupName }
    if (-not $selected) {
        Write-Err "Backup '$BackupName' not found. Available:"
        foreach ($b in $backups) { Write-Host "  $($b.Name)" }
        exit 2
    }
} else {
    $selected = $backups[0]
    Write-Ok "Using most recent backup: $($selected.Name)"
}

# --- Detect target ---
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
        Write-Err "Could not auto-detect Cherry Studio. Please provide -TargetDir."
        exit 3
    }
}

if (-not (Test-Path -LiteralPath $TargetDir)) {
    Write-Err "Target directory does not exist: $TargetDir"
    exit 3
}

# --- Confirm ---
if (-not $Force) {
    Write-Host ""
    Write-Warn "This will OVERWRITE the current Cherry Studio skills with backup: $($selected.Name)"
    $confirm = Read-Host "Proceed? [y/N]"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Rollback cancelled."
        exit 0
    }
}

# --- Restore ---
Write-Step "Restoring from backup: $($selected.Name)"
$restored = 0
$skipped = 0

Get-ChildItem -LiteralPath $selected.FullName -Directory | ForEach-Object {
    $skillName = $_.Name
    $backupFile = Join-Path $_.FullName "SKILL.md"
    $targetSkillDir = Join-Path $TargetDir $skillName
    $targetFile = Join-Path $targetSkillDir "SKILL.md"

    if (Test-Path -LiteralPath $backupFile) {
        New-Item -ItemType Directory -Path $targetSkillDir -Force | Out-Null
        try {
            Copy-Item -LiteralPath $backupFile -Destination $targetFile -Force
            Write-Ok "Restored: $skillName/SKILL.md"
            $restored++
        } catch {
            Write-Err "Failed to restore $skillName : $_"
            $skipped++
        }
    } else {
        Write-Warn "No SKILL.md found in backup for: $skillName"
        $skipped++
    }
}

# --- Summary ---
Write-Host ""
Write-Host "=== Rollback Summary ===" -ForegroundColor Cyan
Write-Host "Restored : $restored"
Write-Host "Skipped  : $skipped (errors/missing)"
Write-Host "Backup   : $($selected.Name)"
Write-Host ""
Write-Host "Next step: Restart Cherry Studio" -ForegroundColor Yellow
