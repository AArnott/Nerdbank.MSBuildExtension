# Nerdbank.MSBuildExtension

Scaffolding for MSBuild extensions that work both with MSBuild Core and MSBuild (Full).

[![Build status](https://ci.appveyor.com/api/projects/status/h5ifdo1brnns3rvv/branch/master?svg=true)](https://ci.appveyor.com/project/AArnott/nerdbank-msbuildextension/branch/master)

## Sample MSBuild extension

Your MSBuild extension's project file can be as minimal as this:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFrameworks>netcoreapp1.0;net45</TargetFrameworks>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Nerdbank.MSBuildExtension" Version="0.1.0-beta" PrivateAssets="all" />
  </ItemGroup>
</Project>
```

Your MSBuild task can be as minimal as:

```csharp
public class MyTask : Nerdbank.MSBuildExtension.ContextIsolatedTask
{
    public string ProjectName { get; set; }

    protected override bool ExecuteIsolated()
    {
        this.Log.LogMessage("Hello, {0}!", this.ProjectName);
        return !this.Log.HasLoggedErrors;
    }
}
```

Then add an MSBuild .targets file to your package that invokes your Task.
In your project directory, create the file `build\YourPackageName.props` with this content:

```xml
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <YourPackageNameToolsRootPath Condition=" '$(YourPackageNameToolsRootPath)' == '' ">$(MSBuildThisFileDirectory)</YourPackageNameToolsRootPath>
    <YourPackageNameToolsSubPath Condition=" '$(MSBuildRuntimeType)' == 'Core' ">netcoreapp1.0\</YourPackageNameToolsSubPath>
    <YourPackageNameToolsSubPath Condition=" '$(MSBuildRuntimeType)' != 'Core' ">net46\</YourPackageNameToolsSubPath>
  </PropertyGroup>
</Project>
```

Also create the `build\YourPackageName.targets` file with this content:

```xml
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <YourPackageNameToolsPath Condition=" '$(YourPackageNameToolsPath)' == '' ">$(YourPackageNameToolsRootPath)$(YourPackageNameToolsSubPath)</YourPackageNameToolsPath>
  </PropertyGroup>

  <UsingTask TaskName="YourTaskName" AssemblyFile="$(YourPackageNameToolsPath)YourPackageName.dll" />

  <Target Name="YourPackageNameBuildExtension" AfterTargets="Build">
    <YourPackageName
      ProjectName="$(MSBuildProjectName)" />
  </Target>
</Project>
```

Now package up your project using `dotnet pack` or `msbuild /t:pack`.
