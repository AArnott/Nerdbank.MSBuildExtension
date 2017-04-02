namespace Nerdbank.MSBuildExtension
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Reflection;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;

    partial class ContextIsolatedTask : AppDomainIsolatedTask
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContextIsolatedTask"/> class.
        /// </summary>
        public ContextIsolatedTask()
        {
            // MSBuild Full provides this isolation.
            this.isIsolated = true;
        }

        /// <inheritdoc />
        public sealed override bool Execute()
        {
            try
            {
                AppDomain.CurrentDomain.AssemblyResolve += this.CurrentDomain_AssemblyResolve;

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
            catch (OperationCanceledException)
            {
                this.Log.LogMessage(MessageImportance.High, "Canceled.");
                return false;
            }
            finally
            {
                AppDomain.CurrentDomain.AssemblyResolve -= this.CurrentDomain_AssemblyResolve;
            }
        }

        /// <summary>
        /// Loads the assembly at the specified path within the isolated context.
        /// </summary>
        /// <param name="assemblyPath">The path to the assembly to be loaded.</param>
        /// <returns>The loaded assembly.</returns>
        protected Assembly LoadAssemblyByPath(string assemblyPath)
        {
            return Assembly.LoadFile(assemblyPath);
        }

        private Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
        {
            return this.LoadAssemblyByName(new AssemblyName(args.Name));
        }
    }
}
