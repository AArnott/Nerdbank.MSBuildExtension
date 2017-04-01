namespace MSBuildExtensionTask
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Reflection;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;

    partial class ContextAwareTask : Task
    {
        /// <inheritdoc />
        public sealed override bool Execute()
        {
            // On .NET Framework (on Windows), we find native binaries by adding them to our PATH.
            if (this.UnmanagedDllDirectory != null)
            {
                string pathEnvVar = Environment.GetEnvironmentVariable("PATH");
                string[] searchPaths = pathEnvVar.Split(Path.PathSeparator);
                if (!searchPaths.Contains(this.UnmanagedDllDirectory, StringComparer.OrdinalIgnoreCase))
                {
                    pathEnvVar += Path.PathSeparator + this.UnmanagedDllDirectory;
                    Environment.SetEnvironmentVariable("PATH", pathEnvVar);
                }
            }

            return this.ExecuteIsolated();
        }
    }
}
