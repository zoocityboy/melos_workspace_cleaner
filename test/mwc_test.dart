import 'package:mocktail/mocktail.dart';
import 'package:mwc/mwc.dart';
import 'package:test/test.dart';

class MockMwcConfig extends Mock implements MwcConfig {}

class MockMwc extends Mock implements Mwc {}

void main() {
  group('Mwc', () {
    late final MwcConfig config;
    late final Mwc mwc;
    setUpAll(() {
      config = MockMwcConfig();
      mwc = MockMwc();
    });
    test('get config', () {
      when(() => mwc.config).thenReturn(config);
      expect(mwc.config, isA<MwcConfig>());
    });
    test('get config patterns', () {
      when(() => mwc.config).thenReturn(config);
      when(() => config.patterns).thenReturn(['pattern1', 'pattern2']);
      expect(mwc.config.patterns.isNotEmpty, true);
    });
  });
}
