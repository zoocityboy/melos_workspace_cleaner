part of 'mwc.dart';

/// Represents the configuration for Melos.
///
/// The [MwcConfig] class contains a list of patterns that specify the files to
/// be cleaned.By default, the patterns include 'pubspec_overrides.yaml'
/// and 'pubspec.lock'.
class MwcConfig {
  /// Creates a new instance of [MwcConfig] for testing purposes.
  factory MwcConfig.manual(Logger logger, {List<String>? patterns}) {
    return MwcConfig._(
      logger: logger,
      patterns: patterns ?? MwcConstants.defaultPatterns,
    );
  }

  /// Creates a new instance of [MwcConfig] from a `melos.yaml` .
  factory MwcConfig.fromConfig(
    Logger logger, {
    required File melosFile,
    required File mwcFile,
  }) {
    final patterns = MwcConfig.parseYamlConfig(mwcFile) ??
        MwcConfig.parseYamlConfig(melosFile) ??
        MwcConstants.defaultPatterns;
    return MwcConfig._(logger: logger, patterns: patterns);
  }

  /// Creates a new instance of [MwcConfig].
  ///
  /// The [patterns] parameter is an optional list of file patterns
  /// to be cleaned.
  /// If no patterns are provided, the default patterns will be used.
  MwcConfig._({
    required this.logger,
    this.patterns = MwcConstants.defaultPatterns,
  });

  /// The logger used by this command.
  final Logger logger;

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
  String get formatedPatterns => patterns.formatedPatterns;

  /// Returns a list of patterns from a `mwc.yaml` file.
  static List<String>? parseYamlConfig(File yaml) {
    if (!yaml.existsSync()) return null;
    // ignore: avoid_dynamic_calls
    final yamlContent = loadYaml(yaml.readAsStringSync()) as YamlMap;
    if (!yamlContent.containsKey(MwcConstants.yamlListNode)) {
      throw const InvalidYamlFormatException();
    }
    final nodeContent = yamlContent[MwcConstants.yamlListNode];
    if (nodeContent is! YamlList) {
      throw const InvalidYamlListFormatException();
    }

    return List<String>.from(nodeContent.value);
  }
}

/// Exception thrown when the format of a YAML file is invalid.
class InvalidYamlFormatException implements Exception {
  const InvalidYamlFormatException();
  @override
  String toString() =>
      'InvalidYamlFormatException: ${MwcStrings.invalidYamlFormat}';
}

/// Exception thrown when the format of a YAML list is invalid.
class InvalidYamlListFormatException implements Exception {
  const InvalidYamlListFormatException();
  @override
  String toString() =>
      'InvalidYamlListFormatException: ${MwcStrings.invalidYamlListFormat}';
}

/// Exception thrown when MWC patterns are not found.
class MwcPatternsNotFound implements Exception {
  /// Creates a new instance of [MwcPatternsNotFound].
  ///
  MwcPatternsNotFound();

  @override
  String toString() => 'MwcPatternsNotFound: ${MwcStrings.noPatternsProvided}';
}
