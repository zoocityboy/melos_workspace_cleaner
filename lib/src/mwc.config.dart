part of 'mwc.dart';

/// Represents the configuration for the MWC (Melos Workspace Cleaner) tool.
///
/// The [MwcConfig] class provides factory methods and properties to create
/// and access the configuration settings for the MWC tool.
class MwcConfig {
  /// Creates a [MwcConfig] instance manually with the given [logger] and optional [patterns].
  ///
  /// If [patterns] is not provided, the default patterns defined in [MwcConstants.defaultPatterns]
  /// will be used.
  factory MwcConfig.manual(Logger logger, {List<String>? patterns}) {
    logger
      ..detail('mwc: [manual]')
      ..detail('- patterns: $patterns');
    return MwcConfig._(
      logger: logger,
      patterns: patterns ?? MwcConstants.defaultPatterns,
    );
  }

  /// Creates a [MwcConfig] instance from the configuration files.
  ///
  /// The [logger] is required, and the [melosFile] and [mwcFile] are the paths to
  /// the Melos and MWC configuration files respectively.
  ///
  /// The method attempts to parse the MWC configuration from the [mwcFile] first,
  /// and if it fails, it falls back to parsing the Melos configuration from the [melosFile].
  /// If neither file contains valid configuration, the default patterns defined in
  /// [MwcConstants.defaultPatterns] will be used.
  factory MwcConfig.fromConfig(
    Logger logger, {
    required File melosFile,
    required File mwcFile,
  }) {
    logger
      ..detail('mwcc: [fromConfig]')
      ..detail('Folder: ${Directory.current.path}')
      ..detail(
        'mwc.yaml: ${mwcFile.existsSync() ? '✔' : '✗'} - ${mwcFile.path.replaceAll(Directory.current.path, '')}',
      )
      ..detail(
        'melos.yaml: ${melosFile.existsSync() ? '✔' : '✗'} - ${melosFile.path.replaceAll(Directory.current.path, '')}',
      );

    final patterns = MwcConfig.parseYamlConfig(logger, mwcFile) ??
        MwcConfig.parseYamlConfig(logger, melosFile) ??
        MwcConstants.defaultPatterns;
    logger
      ..detail('patterns:')
      ..detail(patterns.toString());
    return MwcConfig._(logger: logger, patterns: patterns);
  }

  /// Private constructor for [MwcConfig].
  ///
  /// The [logger] is required, and [patterns] is an optional list of patterns to be cleaned.
  /// If [patterns] is not provided, the default patterns defined in [MwcConstants.defaultPatterns]
  /// will be used.
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
  ///
  /// The [yaml] parameter is the path to the `mwc.yaml` file.
  /// If the file does not exist, `null` is returned.
  ///
  /// This method attempts to parse the YAML content of the file and extract
  /// the list of patterns defined in the `mwc.yaml` file.
  /// If the YAML content is invalid or does not contain the expected structure,
  /// an exception is thrown.
  static List<String>? parseYamlConfig(Logger logger, File yaml) {
    logger.detail('- checking: ${yaml.path}');
    if (!yaml.existsSync()) return null;

    final yamlContent = loadYaml(yaml.readAsStringSync()) as YamlMap;
    logger.detail('''
content: 
$yamlContent[MwcConstants.yamlListNode]
''');

    if (!yamlContent.containsKey(MwcConstants.yamlListNode)) {
      throw InvalidYamlFormatException(yaml);
    }
    final nodeContent = yamlContent[MwcConstants.yamlListNode];
    if (nodeContent is! YamlList) {
      throw InvalidYamlListFormatException(yaml);
    }

    return List<String>.from(nodeContent.value);
  }
}

/// Exception thrown when the format of a YAML file is invalid.
class InvalidYamlFormatException implements Exception {
  /// Creates a new instance of [InvalidYamlFormatException].
  const InvalidYamlFormatException(this.file);

  ///
  final File file;

  /// Returns a string representation of the exception.
  @override
  String toString() => '''
InvalidYamlFormatException: 
- ${MwcStrings.invalidYamlFormat}
- file: ${file.path}
''';
}

/// Exception thrown when the format of a YAML list is invalid.
class InvalidYamlListFormatException implements Exception {
  /// Creates a new instance of [InvalidYamlListFormatException].
  const InvalidYamlListFormatException(this.file);

  ///
  final File file;

  /// Returns a string representation of the exception.
  @override
  String toString() => '''
InvalidYamlListFormatException: 
- ${MwcStrings.invalidYamlFormat}
- file: ${file.path}
''';
}

/// Exception thrown when MWC patterns are not found.
class MwcPatternsNotFound implements Exception {
  /// Creates a new instance of [MwcPatternsNotFound].
  MwcPatternsNotFound();

  /// Returns a string representation of the exception.
  @override
  String toString() => 'MwcPatternsNotFound: ${MwcStrings.noPatternsProvided}';
}
