part of 'mwc.dart';

/// Represents the entry point for Mwc.

class MwcRunner {
  factory MwcRunner() => MwcRunner._(
        mwcFile: MwcConstants.defaultConfigFileName,
        melosFile: MwcConstants.defaultMelosConfigFileName,
        pubUpdater: PubUpdater(),
      );

  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  MwcRunner._({
    required this.mwcFile,
    required this.melosFile,
    required this.pubUpdater,
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

  factory MwcRunner.test({
    required File mwcFile,
    required File melosFile,
    required PubUpdater pubUpdater,
  }) =>
      MwcRunner._(
        mwcFile: mwcFile,
        melosFile: melosFile,
        pubUpdater: pubUpdater,
      );

  /// The logger used by this command.
  Logger logger = Logger();

  /// The pub updater used by this command.
  final PubUpdater pubUpdater;

  late File mwcFile;
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
      // exit(0);
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
      // coverage:ignore-start
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
      // coverage:ignore-end
    }
    return;
  }
}

/// The entrypoint for the MWC (Melos Workspace Cleaner) command.
class EntryPointClass {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  EntryPointClass({
    required this.arguments,
    required this.context,
    this.runner,
  });
  final List<String> arguments;
  final LaunchContext context;
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