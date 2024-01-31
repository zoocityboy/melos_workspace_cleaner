// ignore_for_file: avoid_print

import 'dart:io' show Directory, File;

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main() {
  final outputPath = p.joinAll([
    Directory.current.path,
    'lib',
    'src',
    'mwc.g.dart',
  ]);
  final pubspecPath = p.joinAll([
    Directory.current.path,
    'pubspec.yaml',
  ]);
  print('Updating generated file $outputPath');

  final yamlMap = loadYaml(File(pubspecPath).readAsStringSync()) as YamlMap;
  final currentVersion = yamlMap['version'] as String;
  final fileContents = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: eol_at_end_of_file, public_member_api_docs

part of 'mwc.dart';

/// Current version of the MWC in pubspec.yaml.
@internal
const packageVersion = '$currentVersion';
''';
  File(outputPath).writeAsStringSync(fileContents);
  print('Updated version to $currentVersion in generated file $outputPath');
}
