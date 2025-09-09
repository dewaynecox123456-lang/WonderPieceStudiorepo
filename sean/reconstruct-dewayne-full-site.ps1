# Reconstructs the full-site ZIP from Base64 parts in the same folder.
Param(
  [string]$Out = "dewayne-full-site-FULL.zip"
)

# Collect all parts in order
$parts = Get-ChildItem -Path . -Filter "dewayne-full-site-FINAL.part*.txt" | Sort-Object Name
if(-not $parts){ Write-Error "No parts found."; exit 1 }

Write-Host "Reading parts..."
$b64 = ""
foreach($p in $parts){
  $b64 += Get-Content $p -Raw
}

Write-Host "Decoding Base64..."
$bytes = [System.Convert]::FromBase64String($b64)
[IO.File]::WriteAllBytes($Out, $bytes)

Write-Host "Wrote $Out (" + $bytes.Length + " bytes)" -ForegroundColor Green
