param(
    [Parameter(Mandatory = $true)][string]$PackageDirectory,
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$DownloadBaseUrl,
    [Parameter(Mandatory = $true)][string]$Notes,
    [string]$OutputPath = '.\updates\update-manifest.json'
)

$ErrorActionPreference = 'Stop'
$filesToPublish = @(
    'MyMPLauncher.exe',
    'MyMPLauncher.dll',
    'MyMPLauncher.deps.json',
    'MyMPLauncher.runtimeconfig.json',
    'MyMP.MSCLoader.dll',
    'LiteNetLib.dll',
    'MyMP-Launcher-Hero.png',
    'MyMP-Logo.png'
)
$baseUri = [Uri]$DownloadBaseUrl
if ($baseUri.Scheme -ne 'https') { throw 'DownloadBaseUrl must use HTTPS.' }
$base = $DownloadBaseUrl.TrimEnd('/')
$entries = foreach ($name in $filesToPublish) {
    $path = Join-Path $PackageDirectory $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing release file: $path" }
    [ordered]@{
        path = $name
        sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        url = "$base/$name"
    }
}
$manifest = [ordered]@{
    version = $Version
    notes = $Notes
    files = @($entries)
}
$output = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $PSScriptRoot $OutputPath }
$output = [System.IO.Path]::GetFullPath($output)
$parent = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$json = $manifest | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($output, $json, [System.Text.UTF8Encoding]::new($false))
Write-Host "Created update manifest: $output"
