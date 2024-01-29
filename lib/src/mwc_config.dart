import 'dart:io';

import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// Represents the configuration for Melos.
///
/// The [MwcConfig] class contains a list of patterns that specify the files to
/// be cleaned.By default, the patterns include 'pubspec_overrides.yaml'
/// and 'pubspec.lock'.
class MwcConfig {
  /// Creates a new instance of [MwcConfig].
  ///
  /// The [patterns] parameter is an optional list of file patterns
  /// to be cleaned.
  /// If no patterns are provided, the default patterns will be used.
  MwcConfig._({
    this.patterns = defaultPatterns,
  });

  /// Creates a new instance of [MwcConfig] for testing purposes.
  @visibleForTesting
  factory MwcConfig.dartTest({List<String>? patterns}) {
    return MwcConfig._(patterns: patterns ?? defaultPatterns);
  }

  /// Creates a new instance of [MwcConfig] from a `melos.yaml` .
  factory MwcConfig.fromConfig() {
    final patterns = MwcConfig.parseConfig();
    return MwcConfig._(patterns: patterns ?? defaultPatterns);
  }

  /// The default patterns used by the MWCConfig class.
  static const List<String> defaultPatterns = [
    '**/pubspec_overrides.yaml',
    '**/pubspec.lock',
  ];

  /// The list of patterns to be cleaned.
  final List<String> patterns;

  /// Returns a [Glob] object based on the formatted patterns.
  ///
  /// The formatted patterns are obtained by joining the elements
  /// of the [patterns] list using commas and enclosing them in curly braces
  /// if there is more than one pattern.
  /// If the [patterns] list is empty, an exception is thrown.
  Glob get glob => Glob(formatedPatterns);

  /// Returns a string with the formatted patterns.
  String get formatedPatterns {
    String pattern;
    if (patterns.isEmpty) {
      throw Exception('No patterns provided');
    }

    if (patterns.length > 1) {
      pattern = '{${patterns.join(',')}}';
    } else {
      pattern = patterns.first;
    }
    return pattern;
  }

  /// Returns a list of patterns from a `melos.yaml` file.
  static List<String>? parseConfig() {
    final melosFile = File('melos.yaml');
    final mwcFile = File('mwc.yaml');
    return parseYamlConfig(mwcFile) ?? parseYamlConfig(melosFile);
  }

  /// Returns a list of patterns from a `mwc.yaml` file.
  static List<String>? parseYamlConfig(File yaml) {
    if (!yaml.existsSync()) return null;
    final node = loadYaml(yaml.readAsStringSync())['mwc'] as YamlList?;
    if (node != null) {
      return List<String>.from(node.value);
    }
    return null;
  }
}
