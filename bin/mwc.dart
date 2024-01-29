import 'package:cli_launcher/cli_launcher.dart';
import 'package:mwc/mwc.dart';

/// A class that represents the MWC (Melos Workspace Cleaner) command.
Future<void> main(List<String> arguments) async {
  return launchExecutable(
    arguments,
    LaunchConfig(
      name: ExecutableName('mwc'),
      launchFromSelf: false,
      entrypoint: entryPoint,
    ),
  );
}
