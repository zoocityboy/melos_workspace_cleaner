// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mason_logger/mason_logger.dart';

import 'mwc_config.dart';

class Mwc {
  final MwcConfig config;
  final Logger logger = Logger();
  Mwc({
    required this.config,
  });
  Future<void> clean(Glob glob, Progress progress) async {
    final files = glob.listSync(followLinks: false).toList()..sort((a, b) => b.path.compareTo(a.path));
    for (final file in files) {
      progress.update('Cleaning [${file.path}]');
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 50)),
        File(file.path).delete(),
      ]);
    }
  }

  Future<void> run() async {
    final progress = logger.progress('Removing...');
    try {
      String pattern;
      if (config.patterns.isEmpty) {
        throw Exception('No patterns provided');
      }
      if (config.patterns.length > 1) {
        pattern = '{${config.patterns.join(',')}}';
      } else {
        pattern = config.patterns.first;
      }

      final glob = Glob(pattern);

      final files = glob.listSync(followLinks: false);
      if (files.isEmpty) {
        progress.complete('No files to clean');
        logger.detail('pattern: $pattern');
        return;
      }
      await clean(glob, progress);

      progress.complete('Workspace cleaned');
    } catch (e) {
      progress.fail('Cleaning failed');
      logger.err('Error: $e');
    }
  }
}
