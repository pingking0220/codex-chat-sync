param(
    [string]$RepoName = "codex-chat-sync",
    [string]$Description = "Codex chat history sync across computers"
)

$ErrorActionPreference = "Stop"

function Get-GhPath {
    $command = Get-Command gh -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $fallbacks = @(
        "$env:ProgramFiles\GitHub CLI\gh.exe",
        "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe"
    )

    foreach ($path in $fallbacks) {
        if (Test-Path $path) { return $path }
    }

    throw "GitHub CLI is not installed. Install it with: winget install --id GitHub.cli -e --source winget"
}

$gh = Get-GhPath

& $gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub CLI is not logged in yet."
    Write-Host "A browser/device-code login will start now. Finish GitHub authorization, then run this script again if it stops here."
    & $gh auth login --hostname github.com --git-protocol https --web --clipboard --scopes repo
}

& $gh auth status
if ($LASTEXITCODE -ne 0) {
    throw "GitHub login was not completed."
}

$remote = git remote
if ($remote -contains "origin") {
    Write-Host "Remote 'origin' already exists:"
    git remote -v
}
else {
    & $gh repo create $RepoName --private --source . --remote origin --push --description $Description
}

git push -u origin main

Write-Host "Done. Repository is ready for Codex chat sync."
