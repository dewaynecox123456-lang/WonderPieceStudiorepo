# Deploy-Sean.ps1
# Simple static site deploy to GitHub repo (no GUI)

# --- CONFIGURE THESE TWO PATHS ---
$Source   = "C:\Users\cheri\Downloads\sean\SeansSite_v1.7.0"          # Unzipped site build
$RepoPath = "C:\Users\cheri\OneDrive\Documents\GitHub\WonderPieceStudiorepo"  # Local git repo

$Branch   = "main"
$Commit   = "Deploy: Sean site v1.7.0 (Deep Forest theme)"

# --- VALIDATION ---
if (!(Test-Path $Source))   { throw "Source not found: $Source" }
if (!(Test-Path (Join-Path $RepoPath ".git"))) { throw "Repo not valid: $RepoPath" }

# --- CLEAN + COPY ---
Write-Host "Cleaning repo..." -ForegroundColor Yellow
Get-ChildItem $RepoPath -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force

Write-Host "Copying new site files..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $Source "*") -Destination $RepoPath -Recurse -Force

# --- GIT COMMIT ---
Set-Location $RepoPath
git add .
git commit -m $Commit
git push origin $Branch

Write-Host "`n✅ Deploy complete. Netlify should auto-publish." -ForegroundColor Green