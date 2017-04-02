[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Core', 'Full')]
    $MSBuildFlavor
)

$RepoRoot = "$PSScriptRoot\.."

Write-Host "Packing scaffolding..." -ForegroundColor Green
msbuild /nologo /v:quiet /t:pack "$RepoRoot\src\Nerdbank.MSBuildExtension\Nerdbank.MSBuildExtension.csproj"

Write-Host "Installing scaffolding to sample extension..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\Nerdbank.MSBuildExtension" -ErrorAction SilentlyContinue
msbuild /nologo /v:quiet /t:restore "$RepoRoot\samples\SampleExtension"

Write-Host "Packing sample extension..." -ForegroundColor Green
msbuild /nologo /v:quiet /t:pack "$RepoRoot\samples\SampleExtension\SampleExtension.csproj"

Write-Host "Installing sample extension to sample consumer..." -ForegroundColor Green
Remove-Item -rec "$env:userprofile\.nuget\packages\SampleExtension" -ErrorAction SilentlyContinue
msbuild /nologo /v:quiet /t:restore "$RepoRoot\samples\ExtensionConsumer\ExtensionConsumer.csproj"

if ($MSBuildFlavor -eq 'Core') {
    Write-Host "Building sample consumer with MSBuild Core..." -ForegroundColor Green
    dotnet build "$RepoRoot\samples\ExtensionConsumer" /nologo
} else {
    Write-Host "Building sample consumer with MSBuild Full..." -ForegroundColor Green
    msbuild /nologo /v:minimal "$RepoRoot\samples\ExtensionConsumer\ExtensionConsumer.csproj"
}
