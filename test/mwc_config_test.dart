import 'dart:io';

import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/mwc.dart';
import 'package:test/test.dart';

import 'mock.dart';

void main() {
  group('MwcConfig', () {
    test('should create a new instance with default patterns', () {
      final config = MwcConfig.dartTest();
      expect(config.patterns, ['**/pubspec_overrides.yaml', '**/pubspec.lock']);
    });
  });

  group('MwcConfig format', () {
    test('should create a new instance with custom patterns', () {
      final customPatterns = ['pattern1', 'pattern2'];
      final config = MwcConfig.dartTest(patterns: customPatterns);
      expect(config.patterns, customPatterns);
    });

    test('should return exception if patterns isEmpty', () {
      final customPatterns = <String>[];
      final config = MwcConfig.dartTest(patterns: customPatterns);
      expect(() => config.formatedPatterns, throwsA(isA<Exception>()));
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1', 'pattern2'];
      final config = MwcConfig.dartTest(patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, '{pattern1,pattern2}');
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1'];
      final config = MwcConfig.dartTest(patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, 'pattern1');
    });
  });

  group('MwcConfig glob', () {
    test('should return a Glob object', () {
      final config = MwcConfig.dartTest();
      expect(config.glob, isA<Glob>());
    });

    test('should return a Glob object', () {
      final config = MwcConfig.dartTest(patterns: []);
      expect(() => config.glob, throwsA(isA<Exception>()));
    });
  });

  group('Mwc', () {
    late final MwcConfig config;
    late final Mwc mwc;
    late final Logger logger;
    late final Progress prog;
    setUpAll(() {
      registerFallbackValue(MockProgress());
      prog = MockProgress();
      logger = MockLogger();
      config = MockMwcConfig();
      mwc = MockMwc();
    });

    test('get run called', () {
      when(() => mwc.config).thenReturn(config);
      when(() => config.patterns).thenReturn(['pattern1', 'pattern2']);
      when(() => config.formatedPatterns).thenReturn('{pattern1,pattern2}');
      when(() => mwc.logger).thenReturn(logger);
      when(() => mwc.run()).thenAnswer((_) async {});
      expect(mwc.run(), completion(null));
      verify(() => mwc.run()).called(1);
    });

    test('get clean called', () async {
      when(() => mwc.config).thenReturn(config);
      when(() => config.patterns).thenReturn(['pattern1', 'pattern2']);
      when(() => config.formatedPatterns).thenReturn('{pattern1,pattern2}');
      when(() => mwc.logger).thenReturn(logger);
      when(() => mwc.clean(any(), any())).thenAnswer((_) async {});

      expect(mwc.logger, logger);

      expect(mwc.clean([File('path1'), File('path2')], prog), completion(null));

      verify(() => mwc.clean(any(), any())).called(1);
    });
  });
}
