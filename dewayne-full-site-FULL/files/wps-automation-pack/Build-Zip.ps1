Param([string]$Source='.', [string]$Out='site_bundle.zip')
if(Test-Path $Out){ Remove-Item $Out -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory((Resolve-Path $Source), (Resolve-Path $Out))
Write-Host "Bundle created at $Out"
