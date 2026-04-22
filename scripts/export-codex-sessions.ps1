param(
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [string]$OutputDir = (Join-Path (Get-Location) "conversations"),
    [switch]$IncludeTools
)

$ErrorActionPreference = "Stop"

function Escape-Md {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return "" }
    return $Text.Replace("|", "\|").Replace("`r`n", "`n")
}

function Get-ContentText {
    param($Content)
    if ($null -eq $Content) { return "" }

    $parts = New-Object System.Collections.Generic.List[string]

    if ($Content -is [string]) {
        $parts.Add($Content)
    }
    else {
        foreach ($item in $Content) {
            if ($null -ne $item.text) {
                $parts.Add([string]$item.text)
            }
            elseif ($null -ne $item.input_text) {
                $parts.Add([string]$item.input_text)
            }
            elseif ($null -ne $item.output_text) {
                $parts.Add([string]$item.output_text)
            }
        }
    }

    return ($parts -join "`n`n").Trim()
}

function Safe-FileName {
    param([string]$Name)
    $safe = $Name -replace '[\\/:*?"<>|]', "-"
    $safe = $safe -replace "\s+", " "
    return $safe.Trim()
}

$sessionsDir = Join-Path $CodexHome "sessions"
if (-not (Test-Path $sessionsDir)) {
    throw "找不到 Codex sessions 資料夾：$sessionsDir"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$files = Get-ChildItem -Path $sessionsDir -Recurse -File -Filter "*.jsonl" |
    Where-Object { $_.Length -gt 0 } |
    Sort-Object FullName

$indexRows = New-Object System.Collections.Generic.List[string]
$indexRows.Add("# Codex Conversations")
$indexRows.Add("")
$indexRows.Add("| Date | Session | Messages | File |")
$indexRows.Add("| --- | --- | ---: | --- |")

foreach ($file in $files) {
    $meta = $null
    $messages = New-Object System.Collections.Generic.List[object]
    $toolEvents = New-Object System.Collections.Generic.List[string]

    Get-Content -LiteralPath $file.FullName -Encoding UTF8 | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_)) { return }

        try {
            $record = $_ | ConvertFrom-Json
        }
        catch {
            return
        }

        if ($record.type -eq "session_meta") {
            $meta = $record.payload
            return
        }

        if ($record.type -eq "response_item" -and $record.payload.type -eq "message") {
            $role = [string]$record.payload.role
            if ($role -in @("user", "assistant")) {
                $text = Get-ContentText $record.payload.content
                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    $messages.Add([pscustomobject]@{
                        Timestamp = [string]$record.timestamp
                        Role = $role
                        Text = $text
                    })
                }
            }
        }
        elseif ($IncludeTools) {
            $compact = $record | ConvertTo-Json -Depth 30 -Compress
            $toolEvents.Add($compact)
        }
    }

    if ($null -eq $meta) {
        $sessionId = [IO.Path]::GetFileNameWithoutExtension($file.Name)
        $sessionTime = $file.LastWriteTime.ToString("yyyy-MM-ddTHH-mm-ss")
        $cwd = ""
    }
    else {
        $sessionId = [string]$meta.id
        $sessionTime = ([datetime]$meta.timestamp).ToString("yyyy-MM-ddTHH-mm-ss")
        $cwd = [string]$meta.cwd
    }

    $datePart = $sessionTime.Substring(0, 10)
    $dayDir = Join-Path $OutputDir $datePart
    New-Item -ItemType Directory -Force -Path $dayDir | Out-Null

    $baseName = Safe-FileName "$sessionTime-$sessionId"
    $outFile = Join-Path $dayDir "$baseName.md"

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Codex Session $sessionTime")
    $lines.Add("")
    $lines.Add("| Field | Value |")
    $lines.Add("| --- | --- |")
    $lines.Add("| Session ID | ``$(Escape-Md $sessionId)`` |")
    $lines.Add("| Source file | ``$(Escape-Md $file.FullName)`` |")
    if (-not [string]::IsNullOrWhiteSpace($cwd)) {
        $lines.Add("| Working directory | ``$(Escape-Md $cwd)`` |")
    }
    $lines.Add("")
    $lines.Add("## Conversation")
    $lines.Add("")

    foreach ($message in $messages) {
        $label = if ($message.Role -eq "user") { "User" } else { "Assistant" }
        $lines.Add("### $label")
        if (-not [string]::IsNullOrWhiteSpace($message.Timestamp)) {
            $lines.Add("")
            $lines.Add("_$($message.Timestamp)_")
        }
        $lines.Add("")
        $lines.Add($message.Text)
        $lines.Add("")
    }

    if ($IncludeTools -and $toolEvents.Count -gt 0) {
        $lines.Add("## Tool And Event Records")
        $lines.Add("")
        foreach ($event in $toolEvents) {
            $lines.Add('```json')
            $lines.Add($event)
            $lines.Add('```')
            $lines.Add("")
        }
    }

    Set-Content -LiteralPath $outFile -Value $lines -Encoding UTF8

    $relative = Resolve-Path -LiteralPath $outFile -Relative
    $relative = $relative -replace "\\", "/"
    $indexRows.Add("| $datePart | ``$(Escape-Md $sessionId)`` | $($messages.Count) | [$relative]($relative) |")
}

Set-Content -LiteralPath (Join-Path $OutputDir "index.md") -Value $indexRows -Encoding UTF8

Write-Host "Exported $($files.Count) session file(s) to $OutputDir"
