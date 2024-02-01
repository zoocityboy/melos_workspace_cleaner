import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mwc/src/mwc.dart';
import 'package:test/test.dart';

import 'mock.dart';

void main() {
  late Logger logger;
  setUpAll(() {
    logger = Logger();
  });
  group('MwcConfig', () {
    test('should create a new instance with default patterns', () {
      final config = MwcConfig.manual(logger);
      expect(config.patterns, ['**/pubspec_overrides.yaml', '**/pubspec.lock']);
    });
  });

  group('MwcConfig format', () {
    test('should create a new instance with custom patterns', () {
      final customPatterns = ['pattern1', 'pattern2'];
      final config = MwcConfig.manual(logger, patterns: customPatterns);
      expect(config.patterns, customPatterns);
    });

    test('should return exception if patterns isEmpty', () {
      final customPatterns = <String>[];
      final config = MwcConfig.manual(logger, patterns: customPatterns);
      expect(() => config.formatedPatterns, throwsA(isA<Exception>()));
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1', 'pattern2'];
      final config = MwcConfig.manual(logger, patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, '{pattern1,pattern2}');
    });

    test('should formated patterns', () {
      final customPatterns = <String>['pattern1'];
      final config = MwcConfig.manual(logger, patterns: customPatterns);
      expect(config.formatedPatterns, isA<String>());
      expect(config.formatedPatterns, 'pattern1');
    });
  });

  group('MwcConfig glob', () {
    test('should return a Glob object', () {
      final config = MwcConfig.manual(logger);
      expect(config.glob, isA<Glob>());
    });

    test('should return a Glob object', () {
      final config = MwcConfig.manual(logger, patterns: []);
      expect(() => config.glob, throwsA(isA<Exception>()));
    });
  });

  group('MwcConfig parseConfig', () {
    test(
        'should return default patterns if melos.yaml and mwc.yaml do not exist',
        () {
      final melosFile = FakeMelosFile(isExists: false);
      final mwcFile = FakeMwcFile(isExists: false);

      final config =
          MwcConfig.fromConfig(logger, melosFile: melosFile, mwcFile: mwcFile);
      expect(config.patterns, MwcConstants.defaultPatterns);
    });

    test('should return patterns from mwc.yaml', () {
      final mwcFile =
          FakeMwcFile(content: 'mwc:\n  - "pattern1"\n  - "pattern2"\n');
      final logger = mockLogger();
      final config = MwcConfig.parseYamlConfig(logger, mwcFile);
      expect(config, ['pattern1', 'pattern2']);
    });

    test('should return patterns from melos.yaml', () {
      final melosFile =
          FakeMelosFile(content: 'mwc:\n  - "pattern3"\n  - "pattern4"\n');
      final logger = mockLogger();
      final config = MwcConfig.parseYamlConfig(logger, melosFile);
      expect(config, ['pattern3', 'pattern4']);
    });

    test('should throw exception for invalid yaml format', () {
      final mwcFile = FakeMwcFile(
        content: 'mwx: invalid"\n',
      );
      final logger = mockLogger();
      expect(
        () => MwcConfig.parseYamlConfig(logger, mwcFile),
        throwsA(isA<InvalidYamlFormatException>()),
      );
    });

    test('should throw exception for invalid yaml list format', () {
      final mwcFile = FakeMwcFile(content: 'mwc: pattern');
      final logger = mockLogger();
      expect(
        () => MwcConfig.parseYamlConfig(logger, mwcFile),
        throwsA(isA<InvalidYamlListFormatException>()),
      );
    });
  });

  group('Exceptions', () {
    test('InvalidYamlFormat', () {
      final file = FakeMwcFile();
      final exception = InvalidYamlFormatException(file);
      expect(
        exception.toString(),
        '''
${exception.runtimeType}: 
- ${MwcStrings.invalidYamlFormat}
- file: ${file.path}
''',
      );
    });

    test('InvalidYamlListFormat', () {
      final file = FakeMwcFile();
      final exception = InvalidYamlListFormatException(file);
      expect(
        exception.toString(),
        '''
${exception.runtimeType}: 
- ${MwcStrings.invalidYamlFormat}
- file: ${file.path}
''',
      );
    });

    test('MwcPatternsNotFound', () {
      final exception = MwcPatternsNotFound();
      expect(
        exception.toString(),
        'MwcPatternsNotFound: ${MwcStrings.noPatternsProvided}',
      );
    });
  });
}
