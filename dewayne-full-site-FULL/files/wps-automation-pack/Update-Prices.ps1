Param([string]$JsonPath='data/products.json',[double]$Percent=0)
$j = Get-Content $JsonPath -Raw | ConvertFrom-Json
$j | ForEach-Object { $_.price = [Math]::Round($_.price * (1+$Percent/100),2) }
$j | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
Write-Host "Updated prices in $JsonPath by $Percent%"
