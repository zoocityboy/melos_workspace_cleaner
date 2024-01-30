part of 'mwc.dart';

abstract class MwcStrings {
  static const String invalidYamlFormat = '''
Invalid YAML format.
> Node `mwc` not found.''';
  static const String invalidYamlListFormat = '''
Invalid YAML list format. 
> `mwc` is not a list.''';
  static const String noPatternsProvided = 'No patterns provided.';

  static String mwcCleanUpdate(String path) => 'Cleaning [$path]';
  static String mwcRemovedCount(int count) => 'removed $count files.';
  static String mwcRuning = 'Removing ...';
  static String filesNotFound = 'No files found.';
  static String workspaceCleanedSuccessfully =
      'Workspace cleaned successfully.';
  static String workspaceCleaningFailed = 'Workspace cleaning failed.';
  static String mwcPatternsNotFound = 'Patterns not found.';
  static String mwcVersionLabel = 'version';

  static String error(Object e) => 'Error: $e';

  static String usageTitle = 'Melos Workspace Cleaner';
  static String usageDescription = 'Usage: mwc [options]';

  /// Version update
  static String currentVersion = 'Current version';
  static String shouldUpdate(String latestVersion) => '''
There is a new version of [${MwcConstants.cliName}] available 
($latestVersion). Would you like to update?''';
  static String updateSuccess(String latestVersion) =>
      '${MwcConstants.cliName} has been updated to version $latestVersion.';
  static String updateAvailable(String latestVersion) => '''
A new version of ${MwcConstants.cliName} is available!
($latestVersion)
''';
}
