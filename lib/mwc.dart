/// MWC - Melos Workspace Cleaner
///
/// Melos Workspace Cleaner is a tool designed for cleaning monorepo workspaces built on the [Melos](https://melos.invertase.dev/~melos-latest).
/// This tool provides an straightforward solution for maintaining and managing your monorepo project,
/// especially when dealing with an extensive codebase or a multi-project environment.
library;

export 'src/mwc.dart'
    show
        EntryPointClass,
        Mwc,
        MwcConfig,
        MwcPatternsNotFound,
        MwcRunner,
        packageVersion;
