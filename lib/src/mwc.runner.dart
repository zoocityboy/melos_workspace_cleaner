part of 'mwc.dart';

/// Represents the entry point for Mwc.
///
/// This class serves as the entry point for the Mwc (Melos Workspace Cleaner) command.
/// It provides methods for running the command and checking for updates.
/// The `MwcRunner` class is responsible for parsing command line arguments, initializing the logger and pub updater,
/// and executing the Mwc command based on the provided arguments.
/// The `EntryPointClass` class acts as a wrapper for the `MwcRunner` class and provides an entrypoint method for executing the command.

class MwcRunner {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  factory MwcRunner() => MwcRunner._(
        mwcFile: MwcConstants.defaultConfigFileName,
        melosFile: MwcConstants.defaultMelosConfigFileName,
        pubUpdater: PubUpdater(),
        logger: Logger(),
      );

  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  MwcRunner._({
    required this.mwcFile,
    required this.melosFile,
    required this.pubUpdater,
    required this.logger,
  }) {
    parser = ArgParser(usageLineLength: 80)
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      )
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        help: 'Print verbose output.',
      )
      ..addMultiOption(
        'patterns',
        abbr: 'p',
        help: 'Patterns to be deleted.',
      );
  }

  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  @visibleForTesting
  factory MwcRunner.test({
    required File mwcFile,
    required File melosFile,
    required PubUpdater pubUpdater,
    Logger? logger,
  }) =>
      MwcRunner._(
        mwcFile: mwcFile,
        melosFile: melosFile,
        pubUpdater: pubUpdater,
        logger: logger ?? Logger(),
      );

  /// The logger used by this command.
  Logger logger;

  /// The pub updater used by this command.
  final PubUpdater pubUpdater;

  /// The default MWC configuration file name.
  late File mwcFile;

  /// The default Melos configuration file name.
  late File melosFile;

  /// The parser used by this command.
  late ArgParser parser;

  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  Future<void> run(List<String> arguments) async {
    final results = parser.parse(arguments);

    if (results['verbose'] as bool) {
      logger = Logger(level: Level.verbose);
      logger
        ..detail('Results')
        ..detail('name: ${results.name}')
        ..detail('arguments: ${results.arguments}')
        ..detail('command: ${results.command}')
        ..detail('options: ${results.options}')
        ..detail('rest: ${results.rest}')
        ..detail('------------------')
        ..detail('help[${results['help']}]')
        ..detail('verbose[${results['verbose']}]')
        ..detail('patterns - ${results['patterns']}');
    }

    if (results['help'] as bool) {
      logger
        ..success(MwcStrings.usageTitle)
        ..info('')
        ..info(MwcStrings.usageDescription)
        ..info(parser.usage);

      return;
    }
    try {
      final resultPattern = results['patterns'] as List<String>?;
      logger.detail('patterns: $resultPattern');

      /// The configuration used by this command.
      late MwcConfig config;

      if (resultPattern != null && resultPattern.isNotEmpty) {
        config = MwcConfig.manual(logger, patterns: resultPattern);
        logger.detail('Config manual: ${config.formatedPatterns}');
      } else {
        logger.detail('Config fromConfig');
        config = MwcConfig.fromConfig(
          logger,
          melosFile: mwcFile,
          mwcFile: melosFile,
        );
      }

      /// Runner initialization
      final cleaner = Mwc(
        logger: logger,
        config: config,
      );

      /// Runs the MWC (Melos Workspace Cleaner) command.
      await cleaner.run();
    } catch (e) {
      logger.err(e.toString());
    }
  }

  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  Future<void> version(LaunchContext context) async {
    logger
      ..info(MwcStrings.currentVersion)
      ..info(MwcConstants.cliVersion);

    // Check for updates.
    final isUpToDate = await pubUpdater.isUpToDate(
      packageName: MwcConstants.cliName,
      currentVersion: MwcConstants.cliVersion,
    );
    if (!isUpToDate) {
      final latestVersion =
          await pubUpdater.getLatestVersion(MwcConstants.cliName);
      final isGlobal = context.localInstallation == null;

      if (isGlobal) {
        final shouldUpdate = logger.confirm(
          MwcStrings.shouldUpdate(latestVersion),
          defaultValue: true,
        );

        if (shouldUpdate) {
          await pubUpdater.update(packageName: MwcConstants.cliName);
          logger.success(MwcStrings.updateSuccess(latestVersion));
        }
      } else {
        logger.warn(MwcStrings.updateAvailable(latestVersion));
      }
    }
    return;
  }
}

/// The entrypoint for the MWC (Melos Workspace Cleaner) command.
///
/// This class is responsible for creating an instance of the `MwcRunner` class and executing the command based on the provided arguments.
/// It also provides an option to check for updates and update the Mwc CLI if a new version is available.
class EntryPointClass {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  EntryPointClass({
    required this.arguments,
    required this.context,
    this.runner,
  });

  /// The arguments passed to the command.
  final List<String> arguments;

  /// The context used by this command.
  final LaunchContext context;

  /// The runner used by this command.
  final MwcRunner? runner;

  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  FutureOr<void> entrypoint() async {
    final app = runner ?? MwcRunner();
    if (arguments.contains('-v') || arguments.contains('--version')) {
      app.logger.detail(MwcStrings.mwcVersionLabel);
      await app.version(context);
      return;
    }
    return app.run(arguments);
  }
}
