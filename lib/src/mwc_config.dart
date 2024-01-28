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
}
