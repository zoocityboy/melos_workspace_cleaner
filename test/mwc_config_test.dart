import 'package:glob/glob.dart';
import 'package:mwc/mwc.dart';
import 'package:test/test.dart';

void main() {
  group('MwcConfig', () {
    test('should create a new instance with default patterns', () {
      final config = MwcConfig();
      expect(config.patterns, ['**/pubspec_overrides.yaml', '**/pubspec.lock']);
    });
  });

  group('MwcConfig format', () {
    test('should create a new instance with custom patterns', () {
      final customPatterns = ['pattern1', 'pattern2'];
      final config = MwcConfig(patterns: customPatterns);
      expect(config.patterns, customPatterns);
    });

    test('should return exception if patterns isEmpty', () {
      final customPatterns = <String>[];
      final config = MwcConfig(patterns: customPatterns);
      expect(() => config.formatedPatterns, throwsA(isA<Exception>()));
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1', 'pattern2'];
      final config = MwcConfig(patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, '{pattern1,pattern2}');
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1'];
      final config = MwcConfig(patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, 'pattern1');
    });
  });

  group('MwcConfig glob', () {
    test('should return a Glob object', () {
      final config = MwcConfig();
      expect(config.glob, isA<Glob>());
    });

    test('should return a Glob object', () {
      final config = MwcConfig(patterns: []);
      expect(() => config.glob, throwsA(isA<Exception>()));
    });
  });
}
