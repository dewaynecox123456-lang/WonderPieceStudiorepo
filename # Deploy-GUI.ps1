# Deploy-GUI.ps1
# Minimal Windows Forms UI for universal static-site deploys (Netlify/Vercel-ready)
# Run:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\Deploy-GUI.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------- Helpers ----------
function Fail($msg) {
  [System.Windows.Forms.MessageBox]::Show($msg, "Deploy Error", 'OK', 'Error') | Out-Null
  throw $msg
}
function Log($text) {
  $LogBox.AppendText("$(Get-Date -Format HH:mm:ss)  $text`r`n")
  $LogBox.ScrollToCaret()
}
function Ensure-Git($repoPath) {
  if (-not (Test-Path (Join-Path $repoPath ".git"))) {
    Fail "Repo path invalid or not a git repo (missing .git): `n$repoPath"
  }
}
function Resolve-SitePath($path) {
  $site = Join-Path $path "site"
  if (Test-Path $site) { return $site }
  return $path
}
function Backup-Repo($repo) {
  $stamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
  $dest = Join-Path (Split-Path $repo -Parent) ("backup-" + (Split-Path $repo -Leaf) + "-$stamp")
  Log "Backup → $dest"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Get-ChildItem $repo -Force | Where-Object { $_.Name -ne ".git" } | Copy-Item -Destination $dest -Recurse -Force
}
function Clean-Copy($content, $repo) {
  Log "Cleaning repo (except .git)…"
  Get-ChildItem $repo -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force
  Log "Copying site files…"
  Copy-Item -Path (Join-Path $content "*") -Destination $repo -Recurse -Force
  Get-ChildItem $repo -Recurse -Include *.ps1,*.js,*.html,*.css,*.json | Unblock-File -ErrorAction SilentlyContinue
}

# ---------- Form ----------
$form                  = New-Object System.Windows.Forms.Form
$form.Text             = "Universal Site Deploy"
$form.Size             = New-Object System.Drawing.Size(740,580)
$form.StartPosition    = "CenterScreen"

$lblSourceType         = New-Object System.Windows.Forms.Label
$lblSourceType.Text    = "Source:"
$lblSourceType.Location= "20,20"
$lblSourceType.AutoSize= $true

$rbFolder              = New-Object System.Windows.Forms.RadioButton
$rbFolder.Text         = "Folder"
$rbFolder.Location     = "90,18"
$rbFolder.Checked      = $true

$rbZip                 = New-Object System.Windows.Forms.RadioButton
$rbZip.Text            = "ZIP"
$rbZip.Location        = "160,18"

$rbUrl                 = New-Object System.Windows.Forms.RadioButton
$rbUrl.Text            = "ZIP URL"
$rbUrl.Location        = "210,18"

$tbSource              = New-Object System.Windows.Forms.TextBox
$tbSource.Size         = New-Object System.Drawing.Size(520,22)
$tbSource.Location     = "20,50"

$btnBrowse             = New-Object System.Windows.Forms.Button
$btnBrowse.Text        = "Browse…"
$btnBrowse.Location    = "550,48"
$btnBrowse.Add_Click({
  if ($rbFolder.Checked) {
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq 'OK') { $tbSource.Text = $dlg.SelectedPath }
  } elseif ($rbZip.Checked) {
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "ZIP files|*.zip"
    if ($dlg.ShowDialog() -eq 'OK') { $tbSource.Text = $dlg.FileName }
  } else {
    [System.Windows.Forms.MessageBox]::Show("Enter a full https:// URL in the box.", "Info", 'OK', 'Information') | Out-Null
  }
})

$lblRepo               = New-Object System.Windows.Forms.Label
$lblRepo.Text          = "Git repo path (contains .git):"
$lblRepo.Location      = "20,85"
$lblRepo.AutoSize      = $true

$tbRepo                = New-Object System.Windows.Forms.TextBox
$tbRepo.Size           = New-Object System.Drawing.Size(520,22)
$tbRepo.Location       = "20,105"

$btnRepo               = New-Object System.Windows.Forms.Button
$btnRepo.Text          = "Browse…"
$btnRepo.Location      = "550,103"
$btnRepo.Add_Click({
  $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
  if ($dlg.ShowDialog() -eq 'OK') { $tbRepo.Text = $dlg.SelectedPath }
})

$lblBranch             = New-Object System.Windows.Forms.Label
$lblBranch.Text        = "Branch:"
$lblBranch.Location    = "20,140"
$lblBranch.AutoSize    = $true

$tbBranch              = New-Object System.Windows.Forms.TextBox
$tbBranch.Text         = "main"
$tbBranch.Location     = "80,138"
$tbBranch.Size         = New-Object System.Drawing.Size(120,22)

$lblCommit             = New-Object System.Windows.Forms.Label
$lblCommit.Text        = "Commit message:"
$lblCommit.Location    = "220,140"
$lblCommit.AutoSize    = $true

$tbCommit              = New-Object System.Windows.Forms.TextBox
$tbCommit.Text         = "Deploy: site update via GUI"
$tbCommit.Location     = "340,138"
$tbCommit.Size         = New-Object System.Drawing.Size(330,22)

$cbBackup              = New-Object System.Windows.Forms.CheckBox
$cbBackup.Text         = "Backup repo before overwrite"
$cbBackup.Checked      = $true
$cbBackup.Location     = "20,170"
$cbBackup.AutoSize     = $true

$lblHint               = New-Object System.Windows.Forms.Label
$lblHint.Text          = "Hint: If your content has a /site folder, the deploy will use its CONTENTS at repo root."
$lblHint.Location      = "20,198"
$lblHint.Size          = New-Object System.Drawing.Size(650,32)

$btnDeploy             = New-Object System.Windows.Forms.Button
$btnDeploy.Text        = "Deploy"
$btnDeploy.Location    = "20,235"
$btnDeploy.Size        = New-Object System.Drawing.Size(90,32)

$LogBox                = New-Object System.Windows.Forms.TextBox
$LogBox.Multiline      = $true
$LogBox.ScrollBars     = "Vertical"
$LogBox.Location       = "20,280"
$LogBox.Size           = New-Object System.Drawing.Size(650,230)
$LogBox.Font           = New-Object System.Drawing.Font("Consolas",9)

$form.Controls.AddRange(@(
  $lblSourceType,$rbFolder,$rbZip,$rbUrl,
  $tbSource,$btnBrowse,$lblRepo,$tbRepo,$btnRepo,
  $lblBranch,$tbBranch,$lblCommit,$tbCommit,
  $cbBackup,$lblHint,$btnDeploy,$LogBox
))

# ---------- Deploy Click ----------
$btnDeploy.Add_Click({
  try {
    $source = $tbSource.Text.Trim()
    $repo   = $tbRepo.Text.Trim()
    $branch = $tbBranch.Text.Trim()
    $msg    = $tbCommit.Text.Trim()
    if (-not $source) { Fail "Select a source (folder/ZIP/URL)." }
    if (-not $repo)   { Fail "Select a Git repo path." }
    Ensure-Git $repo

    $tempRoot = Join-Path $env:TEMP "DeployGUI-$(Get-Date -Format yyyyMMddHHmmss)"
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    # Resolve contentRoot from the three source modes
    $contentRoot = $null
    if ($rbFolder.Checked) {
      if (-not (Test-Path $source)) { Fail "Folder not found: $source" }
      $contentRoot = Resolve-SitePath $source
      if (-not (Test-Path (Join-Path $contentRoot "index.html"))) {
        Log "Warning: index.html not found at $contentRoot (continuing)."
      }
    } elseif ($rbZip.Checked) {
      if (-not (Test-Path $source)) { Fail "ZIP not found: $source" }
      $extract = Join-Path $tempRoot "unzipped"
      Log "Expanding ZIP → $extract"
      Expand-Archive -Path $source -DestinationPath $extract -Force
      $contentRoot = Resolve-SitePath $extract
    } elseif ($rbUrl.Checked) {
      if ($source -notmatch "^https?://") { Fail "Invalid ZIP URL." }
      $dl = Join-Path $tempRoot "download.zip"
      Log "Downloading ZIP → $dl"
      Invoke-WebRequest -Uri $source -OutFile $dl -UseBasicParsing
      $extract = Join-Path $tempRoot "unzipped"
      Log "Expanding ZIP → $extract"
      Expand-Archive -Path $dl -DestinationPath $extract -Force
      $contentRoot = Resolve-SitePath $extract
    }

    Log "Content Path : $contentRoot"
    Log "Repo Path    : $repo"
    Log "Branch       : $branch"
    Log "Commit       : $msg"

    if ($cbBackup.Checked) { Backup-Repo $repo }
    Clean-Copy -content $contentRoot -repo $repo

    Push-Location $repo
    Log "git add ."
    git add . | Out-Null
    $pending = (git status --porcelain)
    if (-not $pending) {
      Log "Nothing to commit."
    } else {
      Log "git commit"
      git commit -m $msg | Out-Null
      Log "git push origin $branch"
      git push origin $branch | Out-Null
      Log "Pushed to $branch."
    }
    Pop-Location

    Log ""
    Log "✅ Done. Netlify publish directory tips:"
    Log " - Files at repo ROOT  → Publish directory = /"
    Log " - Files under /site    → Publish directory = site"
  }
  catch {
    Fail $_.Exception.Message
  }
})

[void]$form.ShowDialog()
