import 'dart:io';

import 'package:cli_launcher/cli_launcher.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/src/mwc.dart';
import 'package:test/test.dart';

import 'mock.dart';

void main() {
  late MwcRunner mwcRunner;
  setUp(() {
    mwcRunner = MockMwcRunner();
  });

  group('MwcRunner', () {
    group('run()', () {
      test('should create a new instance of MwcRunner', () {
        expect(mwcRunner, isA<MwcRunner>());
      });

      test('should parse arguments and print usage information', () async {
        final arguments = ['--help'];
        final runner = MwcRunner.test(
          mwcFile: FakeMwcFile(),
          melosFile: FakeMelosFile(),
        );
        await runner.run(arguments);

        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.parser.usage,
          () => runner.logger
            ..success(MwcStrings.usageTitle)
            ..info('')
            ..info(MwcStrings.usageDescription)
            ..info(runner.parser.usage),
        ]);
      });

      test('should parse arguments and set logger level to verbose', () async {
        final arguments = ['--help', '--verbose'];
        final runner = MwcRunner.test(
          mwcFile: FakeMwcFile(),
          melosFile: FakeMelosFile(),
        );
        await runner.run(arguments);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.level = Level.verbose,
        ]);
      });

      test('should parse arguments and create MwcConfig manually', () async {
        final arguments = ['--patterns', 'pattern1,pattern2'];
        final runner = MwcRunner.test(
          mwcFile: FakeMwcFile(),
          melosFile: FakeMelosFile(),
        );
        await runner.run(arguments);
        // ignore: unused_local_variable
        MwcConfig config;
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.detail('Config manual: {pattern1,pattern2}'),
          () => config =
              MwcConfig.manual(runner.logger, patterns: ['pattern1,pattern2']),
        ]);
      });

      test('should parse arguments and create MwcConfig from config files',
          () async {
        final mwcFile = FakeMwcFile();
        final melosFile = FakeMelosFile();

        final arguments = <String>['--verbose'];
        final runner = MwcRunner.test(
          melosFile: melosFile,
          mwcFile: mwcFile,
        );
        await runner.run(arguments);
        // ignore: unused_local_variable
        MwcConfig config;
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.detail('Config fromConfig'),
          () => config = MwcConfig.fromConfig(
                runner.logger,
                melosFile: melosFile,
                mwcFile: mwcFile,
              ),
        ]);
      });

      test('should handle exception and print error message', () async {
        final arguments = <String>[];
        final brokeFile = FakeMelosFile(content: 'xxx:');
        final runner = MwcRunner.test(
          melosFile: brokeFile,
          mwcFile: FakeMwcFile(isExists: false),
        );
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger
              .err(InvalidYamlFormatException(brokeFile).toString()),
        ]);
      });

      test(
          'should return default patterns when: '
          '1. mwc.yaml is missing '
          '2. melos.yaml is invalid format '
          '3. return default patterns', () async {
        final arguments = <String>[];
        final melosFileWrong = FakeMelosFile(content: 'xxx:');
        final mwcFileWrong = FakeMelosFile(content: 'mwc: invalid content');
        final runner = MwcRunner.test(
          melosFile: melosFileWrong,
          mwcFile: mwcFileWrong,
        );
        await runner.run(arguments);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger
              .err(InvalidYamlFormatException(mwcFileWrong).toString()),
          () => runner.logger
              .err(InvalidYamlListFormatException(melosFileWrong).toString()),
        ]);
      });
      test(
          'should return default patterns when: '
          '1. mwc.yaml is missing '
          '2. melos.yaml not missing mwc: '
          '3. return default patterns', () async {
        final arguments = <String>[];
        final mwcFileWrong = FakeMelosFile(isExists: false);
        final melosFileWrong = FakeMelosFile(content: 'xxx:');

        final runner = MwcRunner.test(
          melosFile: melosFileWrong,
          mwcFile: mwcFileWrong,
        );
        await runner.run(arguments);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger
              .err(InvalidYamlListFormatException(melosFileWrong).toString()),
        ]);
      });
    });
  });
  group('version()', () {
    test('should return the version', () async {
      final arguments = <String>[];
      final runner = MwcRunner();

      await runner.run(arguments);
      verifyInOrder([
        () => runner.parser.parse(arguments),
        () => runner.logger.info(MwcStrings.currentVersion),
      ]);
    });

    test('return if is up to date', () async {
      final arguments = <String>['--version'];
      final pubUpdater = MockPubUpdater();
      final context = LaunchContext(directory: Directory.current);
      when(
        () => pubUpdater.isUpToDate(
          packageName: any(named: 'packageName'),
          currentVersion: any(named: 'currentVersion'),
        ),
      ).thenAnswer((_) async => true);
      final runner = MwcRunner.test(
        pubUpdater: pubUpdater,
        melosFile: File(''),
        mwcFile: File(''),
      );

      await runner.version(context);
      verifyInOrder([
        () => runner.parser.parse(arguments),
        () => runner.logger.info(MwcStrings.currentVersion),
        () => pubUpdater.isUpToDate(
              packageName: any(named: 'packageName'),
              currentVersion: any(named: 'currentVersion'),
            ),
      ]);
    });
    test('update available', () async {
      const latestVersion = '1.0.0';
      final arguments = <String>['--version'];
      final pubUpdater = MockPubUpdater();
      final context = MockLaunchContext();
      final localInstallation = MockExecutableInstallation();
      when(() => context.localInstallation).thenReturn(localInstallation);
      when(
        () => pubUpdater.isUpToDate(
          packageName: any(named: 'packageName'),
          currentVersion: any(named: 'currentVersion'),
        ),
      ).thenAnswer((_) async => false);
      when(() => pubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => latestVersion);
      final runner = MwcRunner.test(
        pubUpdater: pubUpdater,
        melosFile: File(''),
        mwcFile: File(''),
      );

      await runner.version(context);

      verifyInOrder([
        () => runner.parser.parse(arguments),
        () => runner.logger.info(MwcStrings.currentVersion),
        () => pubUpdater.isUpToDate(
              packageName: any(named: 'packageName'),
              currentVersion: any(named: 'currentVersion'),
            ),
        () => pubUpdater.getLatestVersion(any()),
        () => runner.logger.warn(MwcStrings.updateAvailable(latestVersion)),
      ]);
    });

    test(
      'update global ',
      () async {
        const latestVersion = '1.0.0';
        final arguments = <String>['--version', '--verbose'];
        final pubUpdater = MockPubUpdater();
        final context = MockLaunchContext();
        final logger = MockLogger();

        final runner = MwcRunner.test(
          pubUpdater: pubUpdater,
          melosFile: File(''),
          mwcFile: File(''),
          logger: logger,
        );

        when(() => logger.info(any())).thenReturn(null);
        when(() => logger.detail(any())).thenReturn(null);
        when(() => logger.success(any())).thenReturn(null);
        when(
          () => logger.confirm(
            any(),
            defaultValue: any(named: 'defaultValue'),
          ),
        ).thenReturn(true);

        when(() => context.localInstallation).thenReturn(null);
        when(
          () => pubUpdater.isUpToDate(
            packageName: any(named: 'packageName'),
            currentVersion: any(named: 'currentVersion'),
          ),
        ).thenAnswer((_) async => false);
        when(() => pubUpdater.getLatestVersion(any()))
            .thenAnswer((_) async => latestVersion);
        when(
          () => pubUpdater.update(packageName: any(named: 'packageName')),
        ).thenAnswer(
          (invocation) async {
            return ProcessResult(1, 0, stdout, stderr);
          },
        );
        await runner.version(context);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.info(MwcStrings.currentVersion),
          () => pubUpdater.isUpToDate(
                packageName: any(named: 'packageName'),
                currentVersion: any(named: 'currentVersion'),
              ),
          () => pubUpdater.getLatestVersion(any()),
          () => runner.logger.confirm(
                any(),
                defaultValue: any(named: 'defaultValue'),
              ),
          () => pubUpdater.update(packageName: any(named: 'packageName')),
          () => runner.logger.success(MwcStrings.updateSuccess(latestVersion)),
        ]);
      },
    );
  });

  group('strings', () {
    test('should return error message', () {
      expect(MwcStrings.error('error'), 'Error: error');
    });
    test('should return mwcCleanUpdate', () {
      const myPath = 'customPath';
      expect(MwcStrings.mwcCleanUpdate(myPath), contains(myPath));
    });
    test('should return mwcRemovedCount', () {
      const count = 10;
      expect(MwcStrings.mwcRemovedCount(10), contains('$count'));
    });
    test('should return shouldUpdate', () {
      const latestVersion = '1.0.0';
      expect(
        MwcStrings.shouldUpdate(latestVersion),
        contains(latestVersion),
      );
    });
    test('should return updateSuccess', () {
      const latestVersion = '1.0.0';
      expect(
        MwcStrings.updateSuccess(latestVersion),
        contains(latestVersion),
      );
    });
    test('should return updateAvailable', () {
      const latestVersion = '1.0.0';
      expect(
        MwcStrings.updateAvailable(latestVersion),
        contains(latestVersion),
      );
    });
  });
}
