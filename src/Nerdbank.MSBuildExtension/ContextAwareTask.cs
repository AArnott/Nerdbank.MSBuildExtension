namespace MSBuildExtensionTask
{
    using System;
    using System.IO;
    using System.Reflection;
    using System.Threading;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;

    /// <summary>
    /// A base class to use for an MSBuild Task that needs to supply its own dependencies
    /// independently of the assemblies that the hosting build engine may be willing to supply.
    /// </summary>
    public abstract partial class ContextAwareTask : ICancelableTask
    {
        /// <summary>
        /// The source of the <see cref="CancellationToken" /> that is canceled when
        /// <see cref="ICancelableTask.Cancel" /> is invoked.
        /// </summary>
        private readonly CancellationTokenSource cts = new CancellationTokenSource();

        /// <summary>
        /// Gets a value indicating whether this is the isolated instance (as opposed to the outer instance).
        /// </summary>
        public bool IsIsolated { get; private set; }

        /// <summary>Gets a token that is canceled when MSBuild is requesting that we abort.</summary>
        public CancellationToken CancellationToken => this.cts.Token;

        /// <summary>Gets the path to the directory containing managed dependencies.</summary>
        protected virtual string ManagedDllDirectory => Path.GetDirectoryName(new Uri(this.GetType().GetTypeInfo().Assembly.CodeBase).LocalPath);

        /// <summary>
        /// Gets the path to the directory containing native dependencies.
        /// May be null if no native dependencies are required.
        /// </summary>
        protected virtual string UnmanagedDllDirectory => null;

        /// <inheritdoc />
        public void Cancel() => this.cts.Cancel();

        /// <summary>
        /// The body of the Task to execute within the isolation boundary.
        /// </summary>
        protected abstract bool ExecuteIsolated();

        /// <summary>
        /// Loads an assembly with a given name.
        /// </summary>
        /// <param name="assemblyName">The name of the assembly to load.</param>
        /// <returns>The loaded assembly, if one could be found; otherwise <c>null</c>.</returns>
        /// <remarks>
        /// The default implementation searches the <see cref="ManagedDllDirectory"/> folder for
        /// any assembly with a matching simple name.
        /// Derived types may use <see cref="LoadAssemblyByPath(string)"/> to load an assembly
        /// from a given path once some path is found.
        /// </remarks>
        protected virtual Assembly LoadAssemblyByName(AssemblyName assemblyName)
        {
            string assemblyPath = Path.Combine(this.ManagedDllDirectory, assemblyName.Name) + ".dll";
            if (File.Exists(assemblyPath))
            {
                return this.LoadAssemblyByPath(assemblyPath);
            }

            return null;
        }
    }
}
