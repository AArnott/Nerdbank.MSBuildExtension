namespace MSBuildExtensionTask
{
    using System;
    using System.IO;
    using System.Reflection;
    using Microsoft.Build.Utilities;

    /// <summary>
    /// A base class to use for an MSBuild Task that needs to supply its own dependencies
    /// independently of the assemblies that the hosting build engine may be willing to supply.
    /// </summary>
    public abstract partial class ContextAwareTask : Task
    {
        /// <summary>Gets the path to the directory containing managed dependencies.</summary>
        protected virtual string ManagedDllDirectory => Path.GetDirectoryName(new Uri(this.GetType().GetTypeInfo().Assembly.CodeBase).LocalPath);

        /// <summary>
        /// Gets the path to the directory containing native dependencies.
        /// May be null if no native dependencies are required.
        /// </summary>
        protected virtual string UnmanagedDllDirectory => null;

        /// <summary>
        /// The body of the Task to execute within the isolation boundary.
        /// </summary>
        protected abstract bool ExecuteIsolated();
    }
}
