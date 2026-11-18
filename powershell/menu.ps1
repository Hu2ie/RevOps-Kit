$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

function Show-Banner {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "         RevOps-Kit :: Windows           " -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Cyan
}

while ($true) {
    Show-Banner
    Write-Host " [1] Static Binary Triage (Get-BinaryInfo)"
    Write-Host " [2] Process Network & DLL Monitor (Watch-ProcNet)"
    Write-Host " [3] Windows Cleanup & Optimization (Invoke-WinTune)"
    Write-Host " [4] Optimization Dry-Run (-WhatIf)"
    Write-Host " [0] Exit"
    Write-Host ""

    $Choice = Read-Host "Select an option"

    switch ($Choice) {
        "1" {
            $Target = Read-Host "Enter target file path (.exe / .dll)"
            if (Test-Path $Target) {
                & "$ScriptRoot\rev\Get-BinaryInfo.ps1" -FilePath $Target
            } else {
                Write-Warning "File not found."
            }
            Pause
        }
        "2" {
            $ProcName = Read-Host "Enter process name (e.g., notepad)"
            & "$ScriptRoot\rev\Watch-ProcNet.ps1" -ProcessName $ProcName
            Pause
        }
        "3" {
            & "$ScriptRoot\opt\Invoke-WinTune.ps1"
            Pause
        }
        "4" {
            & "$ScriptRoot\opt\Invoke-WinTune.ps1" -WhatIf
            Pause
        }
        "0" {
            exit 0
        }
        default {
            Write-Warning "Invalid selection."
            Start-Sleep -Seconds 1
        }
    }
}
