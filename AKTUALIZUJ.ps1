param([switch]$Install)
$ErrorActionPreference = 'Stop'
$state = Join-Path $env:APPDATA 'SKUN_EXPRESS_GITHUB'
$config = Join-Path $state 'repository.txt'
$extParent = Join-Path $env:APPDATA 'Adobe\CEP\extensions'
$target = Join-Path $extParent 'SKUN_EXPRESS'
function Fail([string]$msg) { throw $msg }
function DoUpdate {
    if (-not (Test-Path -LiteralPath $config -PathType Leaf)) {
        Fail 'Brak konfiguracji repozytorium. Uruchom INSTALUJ.cmd.'
    }
    $repo = (Get-Content -LiteralPath $config -Raw -Encoding UTF8).Trim().Trim([char]0xFEFF)
    if ($repo -notmatch '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$') { Fail 'Nieprawidlowa nazwa repozytorium (OWNER/REPO).' }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Fail 'Nie znaleziono GitHub CLI (gh). Zainstaluj je z https://cli.github.com i zaloguj sie: gh auth login'
    }
    & gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail 'Zaloguj sie w terminalu poleceniem: gh auth login' }
    Write-Host "Repozytorium: $repo"
    $tag = (& gh release view --repo $repo --json tagName --jq '.tagName' 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { Fail "Nie moge odczytac Releases. Sprawdz dostep do repozytorium: $tag" }
    if ($tag -notmatch '^v([0-9]+\.[0-9]+\.[0-9]+)$') { Fail "Nieobslugiwany tag wydania: $tag" }
    $version = $Matches[1]
    $existing = '0.0.0'
    $vf=Join-Path $target 'version.txt'
    if (Test-Path -LiteralPath $vf -PathType Leaf) { $existing = (Get-Content -LiteralPath $vf -Raw).Trim() }
    if ($existing -notmatch '^\d+\.\d+\.\d+$') { $existing='0.0.0' }
    Write-Host "Zainstalowana: v$existing; na GitHubie: v$version"
    if ([version]$existing -ge [version]$version) {
        Write-Host 'Masz aktualna wersje SKUN EXPRESS.' -ForegroundColor Green
        return
    }
    $asset = "SKUN_EXPRESS_$version.zip"
    $temp=Join-Path $env:TEMP ('SKUN_GITHUB_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    try {
        Write-Host "Pobieranie: $asset"
        $output = & gh release download $tag --repo $repo --pattern $asset --dir $temp 2>&1
        if ($LASTEXITCODE -ne 0) { Fail "Nie udalo sie pobrac paczki: $output" }
        $archive=Join-Path $temp $asset
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { Fail 'Brak paczki w GitHub Release.' }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip=[IO.Compression.ZipFile]::OpenRead($archive)
        try {
            foreach($item in $zip.Entries) {
                $p=$item.FullName.Replace('\','/')
                if (-not $p.StartsWith('SKUN_EXPRESS/',[StringComparison]::Ordinal) -or
                    $p.Contains('../') -or $p.Contains('/./') -or $p.Contains('//') -or
                    $p.Contains(':') -or $p.StartsWith('/')) { Fail "Niedozwolona sciezka w ZIP: $p" }
            }
        } finally { $zip.Dispose() }
        $extract=Join-Path $temp 'unpacked'
        Expand-Archive -LiteralPath $archive -DestinationPath $extract -Force
        $source=Join-Path $extract 'SKUN_EXPRESS'
        foreach($file in @('CSXS\manifest.xml','index.html','version.txt','jsx\mockup.jsx','jsx\media.jsx','jsx\artboards.jsx','jsx\prowadnice.jsx','jsx\warianty.jsx')) {
            if (-not (Test-Path -LiteralPath (Join-Path $source $file) -PathType Leaf)) { Fail "Brak pliku: $file" }
        }
        if ((Get-Content -LiteralPath (Join-Path $source 'version.txt') -Raw).Trim() -ne $version) { Fail 'Wersja w paczce nie pasuje do GitHub Release.' }
        if (Get-Process -Name Photoshop -ErrorAction SilentlyContinue) {
            Write-Host 'ZAPISZ prace i zamknij Photoshopa. Program nie zostanie zamkniety automatycznie.' -ForegroundColor Yellow
            Read-Host 'Po zamknieciu Photoshopa nacisnij Enter'
            if (Get-Process -Name Photoshop -ErrorAction SilentlyContinue) { Fail 'Photoshop nadal dziala. Przerwano.' }
        }
        New-Item -ItemType Directory -Path $extParent -Force | Out-Null
        $backup=Join-Path $extParent ('SKUN_EXPRESS_BACKUP_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
        $hadOld=Test-Path -LiteralPath $target
        if ($hadOld) { Move-Item -LiteralPath $target -Destination $backup }
        try { Move-Item -LiteralPath $source -Destination $target }
        catch {
            if ($hadOld -and -not (Test-Path -LiteralPath $target)) { Move-Item -LiteralPath $backup -Destination $target }
            throw
        }
        Write-Host "Zainstalowano SKUN EXPRESS v$version" -ForegroundColor Green
        if ($hadOld) { Write-Host "Kopia poprzedniej wersji: $backup" }
        Write-Host 'Uruchom Photoshopa ponownie.'
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -Recurse -ErrorAction SilentlyContinue }
    }
}
try { DoUpdate } catch { Write-Host "BLAD: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }
