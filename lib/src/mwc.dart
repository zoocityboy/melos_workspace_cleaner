// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:glob/list_local_fs.dart';
import 'package:mason_logger/mason_logger.dart';

import 'mwc_config.dart';

class Mwc {
  final MwcConfig config;
  final Logger logger = Logger();
  Mwc({
    required this.config,
  });

  /// Cleans the given list of [files] by deleting them.
  ///
  /// The cleaning process is performed asynchronously, and the progress of the operation
  /// can be tracked using the [progress] object.
  ///
  /// Throws an exception if any error occurs during the cleaning process.
  Future<void> clean(List<FileSystemEntity> files, Progress progress) async {
    for (final file in files) {
      progress.update('Cleaning [${file.path}]');
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 50)),
        File(file.path).delete(),
      ]);
    }
  }

  /// Runs the MWC (Melos Workspace Cleaner) command.
  ///
  /// This method executes the MWC command, which is responsible for cleaning up the Melos workspace.
  /// It performs various cleanup tasks such as removing temporary files, cleaning build artifacts, etc.
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
        ..sort((a, b) => b.path.compareTo(a.path));
      if (files.isEmpty) {
        progress.complete('No files to clean');
        logger.detail('pattern: ${config.formatedPatterns}');
        return;
      }
      await clean(files, progress);

      progress.complete('Workspace cleaned');
    } catch (e) {
      progress.fail('Cleaning failed');
      logger.err('Error: $e');
    }
  }
}
