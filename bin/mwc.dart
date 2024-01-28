import 'package:mwc/mwc.dart';

Future<void> main(List<String> arguments) async {
  final config = MwcConfig();
  final cleaner = Mwc(config: config);
  await cleaner.run();
}
