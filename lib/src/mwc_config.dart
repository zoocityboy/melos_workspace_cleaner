import 'package:glob/glob.dart';

/// Represents the configuration for Melos.
///
/// The [MwcConfig] class contains a list of patterns that specify the files to be cleaned.
/// By default, the patterns include 'pubspec_overrides.yaml' and 'pubspec.lock'.
class MwcConfig {
  final List<String> patterns;

  /// Creates a new instance of [MwcConfig].
  ///
  /// The [patterns] parameter is an optional list of file patterns to be cleaned.
  /// If no patterns are provided, the default patterns will be used.
  MwcConfig({
    this.patterns = const ['**/pubspec_overrides.yaml', '**/pubspec.lock'],
  });

  /// Returns a [Glob] object based on the formatted patterns.
  ///
  /// The formatted patterns are obtained by joining the elements of the [patterns] list
  /// using commas and enclosing them in curly braces if there is more than one pattern.
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
}
