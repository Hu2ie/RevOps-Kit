[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [switch]$SkipRestorePoint
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

if (-not $SkipRestorePoint -and $PSCmdlet.ShouldProcess("System", "Create Restore Point")) {
    Write-Host "[*] Creating system restore point..." -ForegroundColor Cyan
    Checkpoint-Computer -Description "RevOps-Kit Pre-Optimize" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
}

$TempPaths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\SoftwareDistribution\Download\*")
foreach ($Path in $TempPaths) {
    if ($PSCmdlet.ShouldProcess($Path, "Clean temporary files")) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Cleaned: $Path" -ForegroundColor Green
    }
}

$RegTweaks = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0 },
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name = "Enabled"; Value = 0 }
)

foreach ($Tweak in $RegTweaks) {
    if ($PSCmdlet.ShouldProcess("$($Tweak.Path)\$($Tweak.Name)", "Set value to $($Tweak.Value)")) {
        if (-not (Test-Path $Tweak.Path)) { New-Item -Path $Tweak.Path -Force | Out-Null }
        Set-ItemProperty -Path $Tweak.Path -Name $Tweak.Name -Value $Tweak.Value -Type DWord
        Write-Host "[+] Applied tweak: $($Tweak.Name) = $($Tweak.Value)" -ForegroundColor Green
    }
}

if ($PSCmdlet.ShouldProcess("DNS Client", "Flush DNS Cache")) {
    Clear-DnsClientCache
    Write-Host "[+] DNS cache flushed." -ForegroundColor Green
}

