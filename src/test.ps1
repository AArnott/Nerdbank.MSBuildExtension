[CmdletBinding()]
Param(
    [switch]$Core,
    [switch]$Full,
    [switch]$All,
    [switch]$NoScaffoldingPack,
    [ValidateSet('quiet','minimal','normal','detailed','diagnostic')]
    $verbosity='quiet'
)

# If no msbuild flavors were specified, test them all.
if (!($Core -or $Full)) {
    $All = $true
}

if ($All) {
    $Core = $true
    $Full = $true
}

# AppVeyor may be building for release with an environment variable. But paths in sample nuget.config files depend on debug builds.
$env:Configuration='debug'

$RepoRoot = Resolve-Path "$PSScriptRoot\.."
$TestRoot = "$PSScriptRoot\tests"
$Script:Failures = 0

if (!$NoScaffoldingPack) {
    Write-Host "Packing scaffolding..." -ForegroundColor Yellow
    msbuild /nr:false /nologo /v:$verbosity /t:restore "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"
    if ($LASTEXITCODE -ne 0) { Write-Error "Test failed."; exit 1 }
    msbuild /nr:false /nologo /v:$verbosity /t:pack "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"
    if ($LASTEXITCODE -ne 0) { Write-Error "Test failed."; exit 1 }
}

Remove-Item -rec "$env:userprofile\.nuget\packages\Nerdbank.MSBuildExtension" -ErrorAction SilentlyContinue
Remove-Item -rec "$env:userprofile\.nuget\packages\SampleExtension" -ErrorAction SilentlyContinue
Remove-Item -rec "$env:userprofile\.nuget\packages\ComplexExtension" -ErrorAction SilentlyContinue

$versionInfo = & "$env:userprofile\.nuget\packages\Nerdbank.GitVersioning\1.6.25\tools\Get-Version.ps1" -ProjectDirectory $PSScriptRoot
$dogfoodPackageVersion = $versionInfo.NuGetPackageVersion

function PackExtension($extensionProjectPath) {
    Write-Host "Installing scaffolding to `"$extensionProjectPath`"..." -ForegroundColor Yellow
    msbuild /nr:false /nologo /v:$verbosity /t:restore $extensionProjectPath /p:DogfoodingVersion="$dogfoodPackageVersion"
    if ($LASTEXITCODE -ne 0) { Write-Error "Test failed."; exit 1 }

    Write-Host "Packing `"$extensionProjectPath`"..." -ForegroundColor Yellow
    msbuild /nr:false /nologo /v:$verbosity /t:pack $extensionProjectPath /p:DogfoodingVersion="$dogfoodPackageVersion"
    if ($LASTEXITCODE -ne 0) { Write-Error "Test failed."; exit 1 }
}

function TestExtensionConsumer($consumerProjectPath) {
    Write-Host "Installing msbuild extension to `"$consumerProjectPath`"..." -ForegroundColor Yellow
    msbuild /nr:false /nologo /v:$verbosity /t:restore $consumerProjectPath
    if ($LASTEXITCODE -ne 0) { Write-Error "Test failed."; exit 1 }

    if ($Core) {
        Write-Host "Building `"$consumerProjectPath`" with MSBuild Core..." -ForegroundColor Yellow
        dotnet build $consumerProjectPath /nologo
        if ($LASTEXITCODE -ne 0) { $Script:Failures += 1 }
    }

    if ($Full) {
        Write-Host "Building `"$consumerProjectPath`" with MSBuild Full..." -ForegroundColor Yellow
        msbuild /nr:false /nologo /v:minimal $consumerProjectPath
        if ($LASTEXITCODE -ne 0) { $Script:Failures += 1 }
    }
}

PackExtension "$RepoRoot\samples\SampleExtension\SampleExtension.csproj"
TestExtensionConsumer "$RepoRoot\samples\ExtensionConsumer\ExtensionConsumer.csproj"

PackExtension "$TestRoot\ComplexExtension\ComplexExtension.csproj"
TestExtensionConsumer "$TestRoot\ComplexExtensionConsumer\ComplexExtensionConsumer.csproj"

if ($Script:Failures -ne 0) {
    Write-Error "$Script:Failures failures occurred."
    exit $Script:Failures
} else {
    Write-Host "Tests passed" -ForegroundColor Green
}
