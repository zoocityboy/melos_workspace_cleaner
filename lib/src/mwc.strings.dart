part of 'mwc.dart';

/// This class represents a collection of strings used in the Mwc library.
/// It provides an abstraction for accessing and managing these strings.
/// A class that contains string constants used in the Mwc package.
abstract class MwcStrings {
  /// Error message for invalid YAML format.
  static const String invalidYamlFormat = '''
Invalid YAML format.
> Node `mwc` not found.''';

  /// Error message for invalid YAML list format.
  static const String invalidYamlListFormat = '''
Invalid YAML list format. 
> `mwc` is not a list.''';

  /// Error message for when no patterns are provided.
  static const String noPatternsProvided = 'No patterns provided.';

  /// Returns a string indicating the path being cleaned.
  static String mwcCleanUpdate(String path) => 'Cleaning [$path]';

  /// Returns a string indicating the number of files removed.
  static String mwcRemovedCount(int count) => 'removed $count files.';

  /// Returns a string indicating that the cleaning process is running.
  static String mwcRuning = 'Removing ...';

  /// Error message for when no files are found.
  static String filesNotFound = 'No files found.';

  /// Success message for when the workspace is cleaned successfully.
  static String workspaceCleanedSuccessfully =
      'Workspace cleaned successfully.';

  /// Error message for when the workspace cleaning fails.
  static String workspaceCleaningFailed = 'Workspace cleaning failed.';

  /// Error message for when patterns are not found.
  static String mwcPatternsNotFound = 'Patterns not found.';

  /// Label for the version information.
  static String mwcVersionLabel = 'version';

  /// Returns an error message with the provided object.
  static String error(Object e) => 'Error: $e';

  /// Title for the usage information.
  static String usageTitle = 'Melos Workspace Cleaner';

  /// Description for the usage information.
  static String usageDescription = 'Usage: mwc [options]';

  /// Current version information.
  static String currentVersion = 'Current version';

  /// Returns a prompt to update to the latest version.
  static String shouldUpdate(String latestVersion) => '''
There is a new version of [${MwcConstants.cliName}] available 
($latestVersion). Would you like to update?''';

  /// Returns a success message after updating to the latest version.
  static String updateSuccess(String latestVersion) =>
      '${MwcConstants.cliName} has been updated to version $latestVersion.';

  /// Returns a message indicating an available update.
  static String updateAvailable(String latestVersion) => '''
A new version of ${MwcConstants.cliName} is available!
($latestVersion)
''';
}
