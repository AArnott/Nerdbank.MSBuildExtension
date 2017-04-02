# Contributing to Nerdbank.MSBuildExtension

Pull requests and issues are welcome.

## Building

Building this project can be done with either `dotnet build` or MSBuild 15.1 as found in Visual Studio 2017.
Run either of these commands from within the `src` directory of this repo.

### Issues

Note that `dotnet build` currently cannot strong-name sign assemblies, so you can get strong name validation
failed messages at times when using it. Instead, use `msbuild.exe` directly to avoid these issues.

## Testing

Test by running the `src\test.ps1` script, which builds, packages, and then applies those packs to the
projects in the samples directory and builds it.
Watch for multiple "Hello!" messages in the build log to confirm that the extension works.

## NuGet packages from CI/PR

The Appveyor build for this project publishes NuGet packages to:
https://ci.appveyor.com/nuget/nerdbank-msbuildextension
