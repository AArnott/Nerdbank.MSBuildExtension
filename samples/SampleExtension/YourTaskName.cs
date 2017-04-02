using Microsoft.Build.Framework;

public class YourTaskName : Nerdbank.MSBuildExtension.ContextIsolatedTask
{
    public string ProjectName { get; set; }

    protected override bool ExecuteIsolated()
    {
#if NET45
        const string MSBuildFlavor = ".NET Framework";
#else
        const string MSBuildFlavor = ".NET Core";
#endif
        this.Log.LogMessage(MessageImportance.High, "Hello, {0}! - {1}", this.ProjectName, MSBuildFlavor);
        return !this.Log.HasLoggedErrors;
    }
}
