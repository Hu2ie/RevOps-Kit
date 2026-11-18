param (
    [Parameter(Mandatory=$true)]
    [string]$ProcessName
)

$Processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if (-not $Processes) {
    Write-Warning "Process '$ProcessName' not found."
    exit 1
}

foreach ($Proc in $Processes) {
    Write-Host "`n[+] Process: $($Proc.ProcessName) (PID: $($Proc.Id))" -ForegroundColor Cyan
    Write-Host "Path: $($Proc.Path)"

    Write-Host "`n[*] Active TCP Connections:" -ForegroundColor Yellow
    $Conns = Get-NetTCPConnection -OwningProcess $Proc.Id -ErrorAction SilentlyContinue
    if ($Conns) {
        $Conns | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Format-Table -AutoSize
    } else {
        Write-Host "  No active TCP connections." -ForegroundColor Gray
    }

    Write-Host "[*] Loaded Non-System Modules (Outside System32):" -ForegroundColor Yellow
    $Proc.Modules | Where-Object { $_.FileName -notlike "*\Windows\System32\*" } | Select-Object ModuleName, FileName | Format-Table -AutoSize
}

