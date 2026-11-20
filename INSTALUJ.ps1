$ErrorActionPreference='Stop'
$state=Join-Path $env:APPDATA 'SKUN_EXPRESS_GITHUB'
New-Item -ItemType Directory -Path $state -Force | Out-Null
Write-Host 'SKUN EXPRESS - konfiguracja prywatnego repozytorium GitHub'
Write-Host 'Przyklad: SQN/SKUN-EXPRESS'
$repo=(Read-Host 'Wpisz OWNER/REPO').Trim()
if ($repo -notmatch '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$') { throw 'Niepoprawna nazwa repozytorium.' }
Set-Content -LiteralPath (Join-Path $state 'repository.txt') -Value $repo -Encoding UTF8
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'AKTUALIZUJ.ps1') -Destination (Join-Path $state 'AKTUALIZUJ.ps1') -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'AKTUALIZUJ.cmd') -Destination (Join-Path $state 'AKTUALIZUJ.cmd') -Force
Write-Host 'Skonfigurowano repozytorium. Potrzebujesz GitHub CLI i gh auth login.'
& (Join-Path $state 'AKTUALIZUJ.ps1')
