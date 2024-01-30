import 'package:cli_launcher/cli_launcher.dart';
import 'package:mwc/mwc.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
Future<void> main(List<String> arguments) async {
  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  return launchExecutable(
    arguments,
    LaunchConfig(
      name: ExecutableName('mwc'),
      launchFromSelf: false,
      entrypoint: (arguments, context) {
        return EntryPointClass(
          arguments: arguments,
          context: context,
        ).entrypoint();
      },
    ),
  );
}
