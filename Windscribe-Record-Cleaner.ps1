#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$NoBackup,
    [string]$BackupDir,
    [switch]$KillClient
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProcessName  = 'Windscribe'
$SubKey       = 'Software\Microsoft\Windows\CurrentVersion\NetControlPort'
$NativePath   = "HKCU\$SubKey"
$ProviderPath = "HKCU:\$SubKey"
$ValueNames   = @('Version', 'State')

if ([string]::IsNullOrWhiteSpace($BackupDir)) {
    $BackupDir = Join-Path $PSScriptRoot 'backups'
}

function Write-Info($Text) { Write-Host "  $Text" }
function Write-Ok($Text)   { Write-Host "  [OK] $Text" -ForegroundColor Green }
function Write-Warn($Text) { Write-Host "  [!]  $Text" -ForegroundColor Yellow }
function Write-Fail($Text) { Write-Host "  [X]  $Text" -ForegroundColor Red }

function Invoke-Reg {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $null = & reg.exe @Arguments 2>&1
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

function Stop-Client {
    $processes = @(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)
    if ($processes.Count -eq 0) {
        Write-Info "$ProcessName is not running."
        return
    }

    Write-Info "Stopping $($processes.Count) $ProcessName process(es)..."
    foreach ($process in $processes) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            $null = $process.WaitForExit(5000)
        }
        catch {
            Write-Warn "Could not stop PID $($process.Id): $($_.Exception.Message)"
        }
    }
    Write-Ok 'Client stopped.'
}

function Show-KeyValues {
    Write-Info 'Current values:'
    try {
        $item = Get-ItemProperty -Path $ProviderPath
        foreach ($name in $ValueNames) {
            if (-not ($item.PSObject.Properties.Name -contains $name)) { continue }

            $value = $item.$name
            if ($value -is [byte[]]) {
                $hex = [BitConverter]::ToString($value).Replace('-', '')
                if ($hex.Length -gt 64) { $hex = $hex.Substring(0, 64) + '...' }
                Write-Host "        $name = $hex ($($value.Length) bytes, encrypted)"
            }
            else {
                Write-Host "        $name = $value"
            }
        }
    }
    catch {
        Write-Warn "Could not read values: $($_.Exception.Message)"
    }
}

function Backup-Key {
    if (-not (Test-Path -Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $file  = Join-Path $BackupDir "netcontrolport-$stamp.reg"

    $code = Invoke-Reg -Arguments @('export', $NativePath, $file, '/y')
    if ($code -eq 0 -and (Test-Path -Path $file)) {
        Write-Ok "Backup saved: $file"
        return $true
    }

    Write-Fail 'Backup failed. Use -NoBackup to delete without a backup.'
    return $false
}

function Remove-Key {
    $code = Invoke-Reg -Arguments @('delete', $NativePath, '/f')

    if (Test-Path -Path $ProviderPath) {
        Write-Fail "Delete failed (exit=$code). The key still exists."
        return $false
    }

    Write-Ok 'Record deleted.'
    return $true
}

function Main {
    Write-Host ''
    Write-Host 'Windscribe Record Cleaner' -ForegroundColor Cyan
    Write-Host '==========================' -ForegroundColor Cyan
    Write-Host "  Target: $NativePath"
    Write-Host ''

    if ($KillClient) { Stop-Client }

    if (-not (Test-Path -Path $ProviderPath)) {
        Write-Ok 'No record found.'
        Write-Host ''
        return 0
    }

    Show-KeyValues

    if ($NoBackup) {
        Write-Warn 'Backup skipped (-NoBackup).'
    }
    elseif (-not (Backup-Key)) {
        Write-Host ''
        return 1
    }

    $success = Remove-Key
    Write-Host ''
    return [int](-not $success)
}

[int]$exitCode = Main
exit $exitCode
