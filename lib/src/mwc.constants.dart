part of 'mwc.dart';

abstract class MwcConstants {
  /// Current version of the MWC from generated script.
  static String get cliVersion => packageVersion;

  /// Package name
  static String cliName = 'mwc';

  /// MWC node in yaml.
  static String get yamlListNode => cliName;

  /// The default patterns used by the MWCConfig class.
  static const List<String> defaultPatterns = [
    '**/pubspec_overrides.yaml',
    '**/pubspec.lock',
  ];

  /// The default name of the `mwc.yaml` file.
  static File defaultConfigFileName =
      File([Directory.current.path, 'mwc.yaml'].join(Platform.pathSeparator));

  /// The default name of the `melos.yaml` file.
  static File defaultMelosConfigFileName =
      File([Directory.current.path, 'melos.yaml'].join(Platform.pathSeparator));
}

/// Convert a list of strings to Glob pattern string.
extension PatternsString on List<String> {
  String get formatedPatterns {
    String pattern;
    if (isEmpty) {
      throw MwcPatternsNotFound();
    }
    if (length == 1) {
      pattern = first;
    } else {
      pattern = '{${join(',')}}';
    }
    return pattern;
  }
}
