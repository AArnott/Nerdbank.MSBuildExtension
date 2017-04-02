using Microsoft.Build.Framework;

public class YourTaskName : Nerdbank.MSBuildExtension.ContextIsolatedTask
{
    public string ProjectName { get; set; }

    protected override bool ExecuteIsolated()
    {
        this.Log.LogMessage(MessageImportance.High, "Hello, {0}!", this.ProjectName);
        return !this.Log.HasLoggedErrors;
    }
}
