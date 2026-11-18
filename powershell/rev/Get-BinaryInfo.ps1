param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$FilePath
)

$File = Get-Item $FilePath
Write-Host "`n[+] Analyzing file: $($File.Name) ($([math]::Round($File.Length / 1KB, 2)) KB)" -ForegroundColor Cyan

$SHA256 = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
$MD5 = (Get-FileHash -Path $FilePath -Algorithm MD5).Hash
Write-Host "SHA256   : $SHA256"
Write-Host "MD5      : $MD5"

$Sig = Get-AuthenticodeSignature -FilePath $FilePath
Write-Host "Signature: $($Sig.Status) ($($Sig.SignerCertificate.Subject))" -ForegroundColor $(if($Sig.Status -eq 'Valid'){'Green'}else{'Yellow'})

$Bytes = [System.IO.File]::ReadAllBytes($FilePath)
$Freq = @{}
foreach ($b in $Bytes) { $Freq[$b]++ }

$Entropy = 0.0
$Len = $Bytes.Length
foreach ($count in $Freq.Values) {
    $p = $count / $Len
    $Entropy -= $p * [Math]::Log($p, 2)
}
$EntropyRounded = [Math]::Round($Entropy, 3)
$PackerHint = if ($EntropyRounded -gt 7.2) { "[!] High (Likely packed or encrypted)" } else { "[OK] Normal" }
Write-Host "Entropy  : $EntropyRounded / 8.0 $PackerHint" -ForegroundColor $(if($EntropyRounded -gt 7.2){'Red'}else{'Green'})

Write-Host "`n[+] Interesting Strings (URL / IP / Registry):" -ForegroundColor Cyan
$RawText = [System.Text.Encoding]::ASCII.GetString($Bytes)
$Matches = [regex]::Matches($RawText, '(https?://[^\s"''<>]+|\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b|HKEY_[A-Z_]+\\[^\s"''<>]+)')
$Matches.Value | Select-Object -Unique | Select-Object -First 25 | ForEach-Object {
    Write-Host "  -> $_" -ForegroundColor Gray
}
