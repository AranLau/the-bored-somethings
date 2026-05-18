<#
.SYNOPSIS
    Prometheus-0 Skill Validator
.DESCRIPTION
    Scans .claude/skills/skill_*.md, extracts YAML frontmatter, validates
    against schema/skill-schema.json, and checks for cross-skill conflicts.
    Returns exit code 0 on success, 1 on errors, 2 on warnings only.
.PARAMETER SkillsDir
    Path to the skills directory (default: .claude\skills)
.PARAMETER SchemaFile
    Path to the JSON schema (default: schema\skill-schema.json)
.PARAMETER Quiet
    Suppress per-file output, only show summary
.EXAMPLE
    .\scripts\validate.ps1
#>

param(
    [string]$SkillsDir = ".claude\skills",
    [string]$SchemaFile = "schema\skill-schema.json",
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$script:errors = @()
$script:warnings = @()
$script:skills = @{}

function Write-ValidationError {
    param([string]$File, [string]$Message)
    $script:errors += "[ERROR] $File : $Message"
    if (-not $Quiet) { Write-Host "[ERROR] $File : $Message" -ForegroundColor Red }
}

function Write-ValidationWarning {
    param([string]$File, [string]$Message)
    $script:warnings += "[WARN]  $File : $Message"
    if (-not $Quiet) { Write-Host "[WARN]  $File : $Message" -ForegroundColor Yellow }
}

function Write-ValidationOk {
    param([string]$File, [string]$Message)
    if (-not $Quiet) { Write-Host "[OK]    $File : $Message" -ForegroundColor Green }
}

# --- Load schema ---
if (-not (Test-Path -LiteralPath $SchemaFile)) {
    Write-Host "[FATAL] Schema file not found: $SchemaFile" -ForegroundColor Red
    exit 3
}
try {
    $schema = Get-Content -LiteralPath $SchemaFile -Raw | ConvertFrom-Json
} catch {
    Write-Host "[FATAL] Failed to parse schema: $_" -ForegroundColor Red
    exit 3
}

# --- Find skill files ---
$skillFiles = Get-ChildItem -LiteralPath $SkillsDir -Filter "skill_*.md" -ErrorAction SilentlyContinue
if (-not $skillFiles -or $skillFiles.Count -eq 0) {
    Write-Host "[FATAL] No skill_*.md files found in $SkillsDir" -ForegroundColor Red
    exit 3
}

if (-not $Quiet) {
    Write-Host "`n=== Prometheus-0 Skill Validator ===" -ForegroundColor Cyan
    Write-Host "Skills dir : $(Resolve-Path $SkillsDir)"
    Write-Host "Schema     : $(Resolve-Path $SchemaFile)"
    Write-Host "Files found: $($skillFiles.Count)`n"
}

# --- Parse YAML frontmatter from a markdown file ---
function Parse-Frontmatter {
    param([string]$Content, [string]$FilePath)

    $lines = $Content -split "`r?`n"
    if ($lines.Count -lt 3) {
        Write-ValidationError $FilePath "File too short (need at least 3 lines for YAML frontmatter)"
        return $null
    }
    if ($lines[0].Trim() -ne "---") {
        Write-ValidationError $FilePath "Missing opening '---' for YAML frontmatter"
        return $null
    }

    $fm = @{}
    $inFrontmatter = $false
    for ($i = 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Trim() -eq "---") {
            if ($inFrontmatter) { break }
            $inFrontmatter = $true
            continue
        }
        $inFrontmatter = $true
        if ($line.Trim() -eq "") { continue }
        if ($line -match '^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.*)') {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            if ($fm.ContainsKey($key)) {
                Write-ValidationWarning $FilePath "Duplicate key '$key' in frontmatter"
            }
            $fm[$key] = $value
        } else {
            Write-ValidationWarning $FilePath "Skipping non-key-value line in frontmatter: '$line'"
        }
    }
    return $fm
}

# --- Validate a single skill against schema ---
function Test-SkillAgainstSchema {
    param([hashtable]$Frontmatter, [string]$FilePath)

    $valid = $true

    # Check required fields
    foreach ($req in $schema.required) {
        if (-not $Frontmatter.ContainsKey($req) -or [string]::IsNullOrWhiteSpace($Frontmatter[$req])) {
            Write-ValidationError $FilePath "Missing required field: '$req'"
            $valid = $false
        }
    }

    if (-not $valid) { return $false }

    # Validate name
    if ($Frontmatter['name'].Length -lt 1) {
        Write-ValidationError $FilePath "Field 'name' must not be empty"
        $valid = $false
    }

    # Validate priority
    $prio = $Frontmatter['priority']
    try {
        $prioInt = [int]$prio
        if ($prioInt -lt 0 -or $prioInt -gt 100) {
            Write-ValidationError $FilePath "Field 'priority' = $prioInt out of range [0, 100]"
            $valid = $false
        }
    } catch {
        Write-ValidationError $FilePath "Field 'priority' = '$prio' is not a valid integer"
        $valid = $false
    }

    # Validate description
    if ($Frontmatter['description'].Length -lt 10) {
        Write-ValidationWarning $FilePath "Field 'description' is very short (< 10 chars)"
    }

    # Validate trigger
    $triggers = $Frontmatter['trigger'] -split '\s*,\s*' | Where-Object { $_ -ne "" }
    if ($triggers.Count -eq 0) {
        Write-ValidationError $FilePath "Field 'trigger' has no keywords"
        $valid = $false
    }

    # Check unknown fields
    $knownFields = $schema.properties.PSObject.Properties.Name
    foreach ($key in $Frontmatter.Keys) {
        if ($key -notin $knownFields) {
            Write-ValidationWarning $FilePath "Unknown field in frontmatter: '$key'"
        }
    }

    return $valid
}

# --- Cross-skill conflict detection ---
function Test-CrossSkillConflicts {
    $priorityMap = @{}
    $triggerMap = @{}

    foreach ($entry in $script:skills.GetEnumerator()) {
        $file = $entry.Key
        $fm = $entry.Value.Frontmatter

        $prio = [int]$fm['priority']
        if (-not $priorityMap.ContainsKey($prio)) { $priorityMap[$prio] = @() }
        $priorityMap[$prio] += $file

        $triggers = $fm['trigger'] -split '\s*,\s*' | Where-Object { $_ -ne "" } | ForEach-Object { $_.ToLower().Trim() }
        foreach ($t in $triggers) {
            if (-not $triggerMap.ContainsKey($t)) { $triggerMap[$t] = @() }
            $triggerMap[$t] += $file
        }
    }

    # Check priority collisions (warn if >2 share same priority)
    foreach ($entry in $priorityMap.GetEnumerator()) {
        if ($entry.Value.Count -gt 2) {
            Write-ValidationWarning "PRIORITY" "Priority $($entry.Key) shared by $($entry.Value.Count) skills: $($entry.Value -join ', ')"
        }
    }

    # Check trigger keyword overlap
    foreach ($entry in $triggerMap.GetEnumerator()) {
        if ($entry.Value.Count -gt 1) {
            Write-ValidationWarning "TRIGGER" "Keyword '$($entry.Key)' triggers $($entry.Value.Count) skills: $($entry.Value -join ', ')"
        }
    }
}

# --- Check file references in skill bodies ---
function Test-FileReferences {
    foreach ($entry in $script:skills.GetEnumerator()) {
        $file = $entry.Key
        $content = $entry.Value.RawContent

        # Look for Prometheus-0/ path references (exclude markdown backticks, quotes, shell artifacts)
        $refs = [regex]::Matches($content, 'Prometheus-0/([^\s\)\`\"\\\|\>\<]+)')
        foreach ($ref in $refs) {
            $refPath = $ref.Groups[1].Value -replace '[`"\\]$', ''
            if ($refPath -match '^(logs|daily-archive)\b') {
                $fullPath = Join-Path $PSScriptRoot "..\$refPath"
                if (-not (Test-Path -LiteralPath $fullPath)) {
                    Write-ValidationWarning $file "Referenced path does not exist: Prometheus-0/$refPath"
                }
            }
        }
    }
}

# --- Main validation loop ---
foreach ($file in $skillFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) {
        Write-ValidationError $file.Name "Failed to read file"
        continue
    }

    $fm = Parse-Frontmatter -Content $content -FilePath $file.Name
    if (-not $fm) { continue }

    $script:skills[$file.Name] = @{
        Frontmatter = $fm
        RawContent  = $content
    }

    $valid = Test-SkillAgainstSchema -Frontmatter $fm -FilePath $file.Name
    if ($valid) {
        Write-ValidationOk $file.Name "Valid (priority=$($fm['priority']), triggers=$($fm['trigger']))"
    }
}

# --- Cross-skill checks ---
if ($script:skills.Count -gt 0) {
    if (-not $Quiet) { Write-Host "`n--- Cross-Skill Checks ---" -ForegroundColor Cyan }
    Test-CrossSkillConflicts
    Test-FileReferences
}

# --- Summary ---
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Skills scanned : $($skillFiles.Count)"
Write-Host "Skills parsed  : $($script:skills.Count)"
Write-Host "Errors         : $($script:errors.Count)" -ForegroundColor $(if ($script:errors.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings       : $($script:warnings.Count)" -ForegroundColor $(if ($script:warnings.Count -gt 0) { "Yellow" } else { "Green" })

if ($script:errors.Count -gt 0) {
    exit 1
} elseif ($script:warnings.Count -gt 0) {
    exit 2
} else {
    exit 0
}
