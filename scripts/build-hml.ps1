param(
    [string]$OsrmBaseUrl = $env:OSRM_BASE_URL
)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..'))
if (-not $env:GRADLE_USER_HOME) {
    $env:GRADLE_USER_HOME = Join-Path $env:TEMP 'frota-mobile-gradle'
}
New-Item -ItemType Directory -Path $env:GRADLE_USER_HOME -Force | Out-Null

$api = 'https://api.frota-contratada.hml.seara.com.br'
$web = 'https://frota-contratada.hml.seara.com.br/acompanhamento'
$defines = @(
    "--dart-define=BASE_URL=$api",
    "--dart-define=TRIP_WEBAPP_URL=$web",
    "--dart-define=TRIP_SOCKET_URL=$api",
    "--dart-define=TRIP_TRACKING_BASE_URL=$api/corridas"
)

if ($OsrmBaseUrl) {
    $osrm = [uri]$OsrmBaseUrl
    if ($osrm.Scheme -ne 'https' -or $osrm.Host -eq 'router.project-osrm.org') {
        throw 'OSRM_BASE_URL deve ser HTTPS corporativo, nunca o serviço público de demonstração.'
    }
    $defines += "--dart-define=OSRM_BASE_URL=$OsrmBaseUrl"
}

flutter build apk --release --no-pub @defines
if ($LASTEXITCODE -ne 0) { throw 'Build HML falhou.' }

$sourceSha = (git rev-parse --short=12 HEAD).Trim()
$source = 'build/app/outputs/flutter-apk/app-release.apk'
$target = "build/app/outputs/flutter-apk/frota-mobile-hml-$sourceSha.apk"
Copy-Item -LiteralPath $source -Destination $target -Force
$artifact = Get-Item -LiteralPath $target
$sha256 = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
[pscustomobject]@{
    SourceSHA = $sourceSha
    BuildMode = 'release'
    Defines = ($defines -join ' ')
    APK = $artifact.FullName
    Bytes = $artifact.Length
    SHA256 = $sha256
} | Format-List
