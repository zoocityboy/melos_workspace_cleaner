import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_launcher/cli_launcher.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mwc/src/mwc_config.dart';

import 'package:pub_updater/pub_updater.dart';
part 'mwc.g.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
class Mwc {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  Mwc({
    required this.config,
  });

  /// The configuration used by this command.
  final MwcConfig config;

  /// The logger used by this command.
  Logger logger = Logger();

  /// Cleans the given list of [files] by deleting them.
  ///
  /// The cleaning process is performed asynchronously,
  /// and the progress of the operation
  /// can be tracked using the [progress] object.
  ///
  /// Throws an exception if any error occurs during the cleaning process.
  Future<void> clean(List<FileSystemEntity> files, Progress progress) async {
    for (final file in files) {
      progress.update('Cleaning [${file.path}]');
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 50)),
        File(file.path).delete(),
      ]);
    }
  }

  /// Runs the MWC (Melos Workspace Cleaner) command.
  ///
  /// This method executes the MWC command, which is responsible for
  /// cleaning up the Melos workspace.
  /// It performs various cleanup tasks such as removing temporary files,
  /// cleaning build artifacts, etc.
  ///
  /// Usage:
  /// ```dart
  /// await run();
  /// ```
  ///
  /// Throws an exception if an error occurs during the cleanup process.
  Future<void> run() async {
    final progress = logger.progress('Removing...');
    try {
      final files = config.glob.listSync(followLinks: false).toList()
        ..sort(
          (a, b) => b.path.compareTo(a.path),
        );
      if (files.isEmpty) {
        progress.complete('No files to clean');
        logger.info('pattern: ${config.formatedPatterns}');
        return;
      }
      await clean(files, progress);

      progress.complete(
        'Workspace cleaned successfully.',
      );
      logger.detail('removed ${files.length} files.');
    } catch (e) {
      progress.fail('Cleaning failed');
      logger.err('Error: $e');
    }
  }
}

/// Represents the entry point for Mwc.

class MwcRunner {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  MwcRunner() {
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
      ..addMultiOption(
        'patterns',
        abbr: 'p',
        help: 'Patterns to be deleted.',
      );
  }

  /// The parser used by this command.
  late final ArgParser parser;

  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  Future<void> run(List<String> arguments) async {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      stdout
        ..writeln('Melos Workspace Cleaner')
        ..writeln()
        ..writeln('Usage: mwc [options]')
        ..writeln(parser.usage);

      return;
    }
    try {
      final resultPattern = results['patterns'] as List<String>?;

      /// The configuration used by this command.
      late MwcConfig config;

      if (resultPattern != null) {
        config = MwcConfig.manual(patterns: resultPattern);
      } else {
        config = MwcConfig.fromConfig();
      }

      /// Runner initialization
      final cleaner = Mwc(config: config);

      /// Runs the MWC (Melos Workspace Cleaner) command.
      await cleaner.run();
    } catch (e) {
      stderr.writeln(e.toString());
      exit(64); // Exit code 64 indicates a usage error.
    }
  }

  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  Future<void> version(LaunchContext context) async {
    final logger = Logger()..info(packageVersion);

    // No version checks on CIs.
    // if (utils.isCI) return;

    // Check for updates.
    final pubUpdater = PubUpdater();
    const packageName = 'mwc';
    final isUpToDate = await pubUpdater.isUpToDate(
      packageName: packageName,
      currentVersion: packageVersion,
    );
    if (!isUpToDate) {
      final latestVersion = await pubUpdater.getLatestVersion(packageName);
      final isGlobal = context.localInstallation == null;

      if (isGlobal) {
        final shouldUpdate = logger.confirm(
          'There is a new version of $packageName available '
          '($latestVersion). Would you like to update?',
          defaultValue: true,
        );

        if (shouldUpdate) {
          await pubUpdater.update(packageName: packageName);
          logger.success(
            '$packageName has been updated to version $latestVersion.',
          );
        }
      } else {
        logger.warn(
          'There is a new version of $packageName available '
          '($latestVersion).',
        );
      }
    }
    return;
  }
}

/// The entrypoint for the MWC (Melos Workspace Cleaner) command.
@override
FutureOr<void> entryPoint(
  List<String> arguments,
  LaunchContext context,
) async {
  final runner = MwcRunner();
  if (arguments.contains('-v') || arguments.contains('--version')) {
    await runner.version(context);
    return;
  }
  return runner.run(arguments);
}
