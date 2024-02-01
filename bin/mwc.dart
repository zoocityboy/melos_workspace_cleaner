import 'package:cli_launcher/cli_launcher.dart';
import 'package:mwc/src/mwc.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
Future<void> main(List<String> arguments) async {
  /// The entrypoint for the MWC (Melos Workspace Cleaner) command.
  return launchExecutable(
    arguments,
    LaunchConfig(
      name: ExecutableName(MwcConstants.cliName),
      launchFromSelf: false,
      entrypoint: (arguments, context) {
        return EntryPointClass(
          arguments: arguments,
          context: context,
          runner: MwcRunner(),
        ).entrypoint();
      },
    ),
  );
}
