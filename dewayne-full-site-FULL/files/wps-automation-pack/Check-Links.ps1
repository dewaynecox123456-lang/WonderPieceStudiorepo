Param([string[]]$Urls)
foreach($u in $Urls){
  try{
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20
    Write-Host "[OK] $u -> $($r.StatusCode)"
  } catch {
    Write-Warning "[FAIL] $u -> $($_.Exception.Message)"
  }
}
