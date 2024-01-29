import 'package:mwc/mwc.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
Future<void> main(List<String> arguments) async {
  /// The configuration used by this command.
  final config = MwcConfig.fromConfig();

  /// Runner initialization
  final cleaner = Mwc(config: config);

  /// Runs the MWC (Melos Workspace Cleaner) command.
  await cleaner.run();
}
