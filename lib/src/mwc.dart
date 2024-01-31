// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_launcher/cli_launcher.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:yaml/yaml.dart';

part 'mwc.config.dart';
part 'mwc.constants.dart';
part 'mwc.g.dart';
part 'mwc.runner.dart';
part 'mwc.strings.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
class Mwc {
  /// Creates a new instance of the MWC (Melos Workspace Cleaner) command.
  ///
  /// The [config] parameter is the configuration used by this command.
  /// The [logger] parameter is the logger used by this command.
  Mwc({
    required this.config,
    required this.logger,
  });

  /// The configuration used by this command.
  final MwcConfig config;

  /// The logger used by this command.
  final Logger logger;

  /// Cleans the given list of [files] by deleting them.
  ///
  /// The cleaning process is performed asynchronously,
  /// and the progress of the operation
  /// can be tracked using the [progress] object.
  ///
  /// Throws an exception if any error occurs during the cleaning process.
  Future<void> clean(List<FileSystemEntity> files, Progress progress) async {
    for (final file in files) {
      progress.update(MwcStrings.mwcCleanUpdate(file.path));
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 50)),
        file.delete(),
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
    final progress = logger.progress(MwcStrings.mwcRuning);
    try {
      final files = config.glob.listSync(followLinks: false).toList()
        ..sort(
          (a, b) => b.path.compareTo(a.path),
        );
      if (files.isEmpty) {
        progress.complete(MwcStrings.filesNotFound);
        return;
      }
      await clean(files, progress);

      progress.complete(MwcStrings.workspaceCleanedSuccessfully);
      logger.detail(MwcStrings.mwcRemovedCount(files.length));
    } catch (e) {
      progress.fail(MwcStrings.workspaceCleaningFailed);
      logger.err(MwcStrings.error(e));
    }
  }
}
