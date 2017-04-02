[CmdletBinding()]
Param(
    [switch]$Core,
    [switch]$Full
)

$RepoRoot = "$PSScriptRoot\.."
$SampleExtensionPath = "$RepoRoot\samples\SampleExtension\SampleExtension.csproj"
$ExtensionConsumerPath = "$RepoRoot\samples\ExtensionConsumer\ExtensionConsumer.csproj"

Write-Host "Packing scaffolding..." -ForegroundColor Green
msbuild /nr:false /nologo /v:quiet /t:restore "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"
msbuild /nr:false /nologo /v:quiet /t:pack "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"

Write-Host "Installing scaffolding to sample extension..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\Nerdbank.MSBuildExtension" -ErrorAction SilentlyContinue
$versionInfo = & "$env:userprofile\.nuget\packages\Nerdbank.GitVersioning\1.6.25\tools\Get-Version.ps1" -ProjectDirectory $PSScriptRoot
msbuild /nr:false /nologo /v:quiet /t:restore $SampleExtensionPath /p:DogfoodingVersion="$($versionInfo.NuGetPackageVersion)"

Write-Host "Packing sample extension..." -ForegroundColor Green
msbuild /nr:false /nologo /v:quiet /t:pack $SampleExtensionPath /p:DogfoodingVersion="$($versionInfo.NuGetPackageVersion)"

Write-Host "Installing sample extension to sample consumer..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\SampleExtension" -ErrorAction SilentlyContinue
msbuild /nr:false /nologo /v:quiet /t:restore $ExtensionConsumerPath

if ($Core) {
    Write-Host "Building sample consumer with MSBuild Core..." -ForegroundColor Green
    dotnet build $ExtensionConsumerPath /nologo
}

if ($Full) {
    Write-Host "Building sample consumer with MSBuild Full..." -ForegroundColor Green
    msbuild /nr:false /nologo /v:minimal $ExtensionConsumerPath
}
