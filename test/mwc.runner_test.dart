import 'dart:io';

import 'package:cli_launcher/cli_launcher.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/src/mwc.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import 'fixture/mwc_melos_yaml.dart';
import 'mock.dart';

void main() {
  late MwcRunner mwcRunner;
  late Logger logger;

  setUp(() {
    logger = MockLogger();
    mwcRunner = MockMwcRunner();
  });

  group('MwcRunner', () {
    group('run()', () {
      test('should create a new instance of MwcRunner', () {
        expect(mwcRunner, isA<MwcRunner>());
      });

      test('should parse arguments and print usage information', () async {
        final arguments = ['--help'];
        final runner = MwcRunner()..logger = Logger();
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
        final runner = MwcRunner();
        await runner.run(arguments);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.level = Level.verbose,
        ]);
      });

      test('should parse arguments and create MwcConfig manually', () async {
        final arguments = ['--patterns', 'pattern1,pattern2'];
        final runner = MwcRunner();
        await runner.run(arguments);
        // ignore: unused_local_variable
        MwcConfig config;
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.detail('Config manual: pattern1,pattern2'),
          () => config =
              MwcConfig.manual(logger, patterns: ['pattern1,pattern2']),
        ]);
      });

      test('should parse arguments and create MwcConfig from config files',
          () async {
        final melosFile = testMelosConfigFile
          ..createSync(recursive: true)
          ..writeAsStringSync(melosYamlContent);
        final mwcFile = testMwcConfigFile
          ..createSync(recursive: true)
          ..writeAsStringSync(mwcYamlContent);

        final arguments = <String>['--verbose'];
        final runner = MwcRunner.test(
          melosFile: melosFile,
          mwcFile: mwcFile,
          pubUpdater: PubUpdater(),
        );
        await runner.run(arguments);
        // ignore: unused_local_variable
        MwcConfig config;
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.logger.detail('Config fromConfig'),
          () => config = MwcConfig.fromConfig(
                logger,
                melosFile: melosFile,
                mwcFile: mwcFile,
              ),
        ]);
      });

      test('should handle exception and print error message', () async {
        final arguments = <String>[];
        final runner = MwcRunner();

        await runner.run(arguments);
        verifyInOrder([
          () => runner.parser.parse(arguments),
          () =>
              runner.logger.err(const InvalidYamlFormatException().toString()),
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

        final runner = MwcRunner.test(
          pubUpdater: pubUpdater,
          melosFile: File(''),
          mwcFile: File(''),
        );

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
          () => runner.logger.confirm(
            any(),
            defaultValue: any(named: 'defaultValue'),
          ),
        ).thenReturn(true);
        when(() => pubUpdater.update(packageName: any(named: 'packageName')))
            .thenAnswer(
          (invocation) async => ProcessResult(1, 0, stdout, stderr),
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
      skip: true,
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
