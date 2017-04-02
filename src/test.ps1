[CmdletBinding()]
Param(
    [switch]$Core,
    [switch]$Full,
    [switch]$All,
    [switch]$NoScaffoldingPack
)

if ($All) {
    $Core = $true
    $Full = $true
}

if (!($Core -or $Full)) {
    Write-Error "No test framework specified."
    return
}

# AppVeyor may be building for release with an environment variable. But paths in sample nuget.config files depend on debug builds.
$env:Configuration='debug'

$RepoRoot = "$PSScriptRoot\.."
$SampleExtensionPath = "$RepoRoot\samples\SampleExtension\SampleExtension.csproj"
$ExtensionConsumerPath = "$RepoRoot\samples\ExtensionConsumer\ExtensionConsumer.csproj"

if (!$NoScaffoldingPack) {
    Write-Host "Packing scaffolding..." -ForegroundColor Green
    msbuild /nr:false /nologo /v:quiet /t:restore "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"
    if ($LASTEXITCODE -ne 0) { return }
    msbuild /nr:false /nologo /v:quiet /t:pack "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"
    if ($LASTEXITCODE -ne 0) { return }
}

Write-Host "Installing scaffolding to sample extension..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\Nerdbank.MSBuildExtension" -ErrorAction SilentlyContinue
$versionInfo = & "$env:userprofile\.nuget\packages\Nerdbank.GitVersioning\1.6.25\tools\Get-Version.ps1" -ProjectDirectory $PSScriptRoot
msbuild /nr:false /nologo /v:quiet /t:restore $SampleExtensionPath /p:DogfoodingVersion="$($versionInfo.NuGetPackageVersion)"
if ($LASTEXITCODE -ne 0) { return }

Write-Host "Packing sample extension..." -ForegroundColor Green
msbuild /nr:false /nologo /v:quiet /t:pack $SampleExtensionPath /p:DogfoodingVersion="$($versionInfo.NuGetPackageVersion)"
if ($LASTEXITCODE -ne 0) { return }

Write-Host "Installing sample extension to sample consumer..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\SampleExtension" -ErrorAction SilentlyContinue
msbuild /nr:false /nologo /v:quiet /t:restore $ExtensionConsumerPath
if ($LASTEXITCODE -ne 0) { return }

$Failures = 0

if ($Core) {
    Write-Host "Building sample consumer with MSBuild Core..." -ForegroundColor Green
    dotnet build $ExtensionConsumerPath /nologo
    if ($LASTEXITCODE -ne 0) { $Failures += 1 }
}

if ($Full) {
    Write-Host "Building sample consumer with MSBuild Full..." -ForegroundColor Green
    msbuild /nr:false /nologo /v:minimal $ExtensionConsumerPath
    if ($LASTEXITCODE -ne 0) { $Failures += 1 }
}

if ($Failures -ne 0) {
    Write-Error "$Failures failures occurred."
}
