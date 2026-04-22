param(
    [string]$Message = "Sync Codex conversations"
)

$ErrorActionPreference = "Stop"

$remote = git remote
if ($remote -contains "origin") {
    git pull --rebase --autostash
}

& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "export-codex-sessions.ps1")

$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No conversation changes to commit."
    exit 0
}

git add .
git commit -m $Message

if ($remote -contains "origin") {
    git push
}
else {
    Write-Host "Committed locally. Add a GitHub remote named 'origin' before pushing."
}
