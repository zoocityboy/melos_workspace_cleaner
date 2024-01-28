import 'package:melos_workspace_cleaner/mwc.dart';
import 'package:melos_workspace_cleaner/src/mwc_config.dart';

Future<void> main(List<String> arguments) async {
  final config = MwcConfig();
  final cleaner = Mwc(config: config);
  await cleaner.run();
}
