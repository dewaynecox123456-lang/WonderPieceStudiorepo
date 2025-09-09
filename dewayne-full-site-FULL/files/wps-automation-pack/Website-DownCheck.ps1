Param([string]$Url='https://your-site.netlify.app')
try{
  $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15
  if($r.StatusCode -eq 200){ Write-Host "[OK] Site is UP: $Url" -ForegroundColor Green }
  else{ Write-Warning "[WARN] Site returned $($r.StatusCode)" }
}catch{ Write-Error "[FAIL] Unable to reach $Url. Error: $($_.Exception.Message)" }
