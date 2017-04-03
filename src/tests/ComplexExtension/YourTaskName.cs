using System.Collections.Immutable;
using System.Reflection;
using ImmutableCollectionsConsumers;
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

        // Verify that binding redirects allow us to all get along.
        ImmutableArray<string> a;
        a = ImmutableCollectionsConsumer1.GetArray();
        a = ImmutableCollectionsConsumer2.GetArray();

        this.Log.LogMessage(MessageImportance.High, "Running with: {0}", a.GetType().GetTypeInfo().Assembly.GetName());

        return !this.Log.HasLoggedErrors;
    }
}
