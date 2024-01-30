import 'dart:io';

import 'package:cli_launcher/cli_launcher.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/src/mwc.dart';
import 'package:test/test.dart';

import 'mock.dart';

void main() {
  late MwcConfig config;
  late Mwc mwc;
  late Logger logger;
  late Progress progress;
  late Glob glob;

  setUpAll(() {
    config = MockMwcConfig();
    logger = MockLogger();
    progress = MockProgress();
    glob = MockGlob();
    mwc = Mwc(logger: logger, config: config);

    when(() => config.glob).thenReturn(glob);
  });

  group('Mwc', () {
    group('clean', () {
      test('should delete files', () async {
        final file1 = MockFileSystemEntity();
        final file2 = MockFileSystemEntity();
        final files = [file1, file2];
        when(() => file1.path).thenReturn('path1');
        when(() => file2.path).thenReturn('path2');
        when(() => file1.delete(recursive: any(named: 'recursive')))
            .thenAnswer((_) async => file1);
        when(() => file2.delete(recursive: any(named: 'recursive')))
            .thenAnswer((_) async => file2);

        await mwc.clean(files, progress);

        verifyInOrder([
          () => progress.update('Cleaning [path1]'),
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
          file1.delete,
          () => progress.update('Cleaning [path2]'),
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
          file2.delete,
        ]);
      });
    });

    group('run', () {
      test('should clean workspace successfully', () async {
        final file1 = MockFileSystemEntity();
        final file2 = MockFileSystemEntity();
        final files = [file1, file2];

        when(() => config.glob).thenReturn(glob);
        when(() => config.formatedPatterns).thenReturn('pattern1,pattern2');
        when(() => glob.listSync(followLinks: false)).thenReturn(files);
        when(() => file1.path).thenReturn('path1');
        when(() => file2.path).thenReturn('path2');
        when(() => file1.delete(recursive: any(named: 'recursive')))
            .thenAnswer((_) async => file1);
        when(() => file2.delete(recursive: any(named: 'recursive')))
            .thenAnswer((_) async => file2);

        when(() => logger.progress(any())).thenReturn(progress);
        when(() => progress.complete(any())).thenReturn(null);
        when(() => logger.detail(any())).thenReturn(null);

        await mwc.run();

        verifyInOrder([
          () => logger.progress(MwcStrings.mwcRuning),
          () => config.glob.listSync(followLinks: false),
          () => progress.complete(MwcStrings.workspaceCleanedSuccessfully),
          () => logger.detail(MwcStrings.mwcRemovedCount(files.length)),
        ]);
      });

      test('should handle empty workspace', () async {
        when(() => logger.progress(any())).thenReturn(progress);
        when(() => config.glob).thenReturn(glob);
        when(() => config.formatedPatterns).thenReturn('pattern1,pattern2');
        when(() => glob.listSync(followLinks: false)).thenReturn([]);
        when(() => progress.complete(any())).thenReturn(null);
        when(() => logger.info(any())).thenReturn(null);

        await mwc.run();

        verifyInOrder([
          () => logger.progress(MwcStrings.mwcRuning),
          () => config.glob.listSync(followLinks: false),
          () => progress.complete(MwcStrings.filesNotFound),
        ]);
      });

      test('should handle cleaning failure', () async {
        final file1 = MockFileSystemEntity();
        final file2 = MockFileSystemEntity();
        final files = [file1, file2];
        final excp = Exception('Delete failed');

        when(() => config.glob).thenReturn(glob);
        when(() => config.formatedPatterns).thenReturn('pattern1,pattern2');
        when(() => glob.listSync(followLinks: false)).thenReturn(files);
        when(() => file1.path).thenReturn('path1');
        when(() => file1.delete(recursive: any(named: 'recursive')))
            .thenAnswer((_) async => file1);
        when(() => file2.path).thenReturn('path2');
        when(file2.delete).thenThrow(excp);
        when(() => logger.progress(any())).thenReturn(progress);
        when(() => progress.fail(any())).thenReturn(null);
        when(() => logger.err(any())).thenReturn(null);

        await mwc.run();

        verifyInOrder([
          () => logger.progress(MwcStrings.mwcRuning),
          () => glob.listSync(followLinks: false),
          () => file2.delete(recursive: captureAny(named: 'recursive')),
          () => progress.fail(MwcStrings.workspaceCleaningFailed),
          () => logger.err(MwcStrings.error(excp)),
        ]);
      });
    });

    group('entry point', () {
      test('should run Mwc command', () async {
        final arguments = <String>['-h'];
        final runner = MwcRunner();
        final ep = EntryPointClass(
          arguments: arguments,
          context: LaunchContext(
            directory: Directory.systemTemp,
          ),
          runner: runner,
        );

        await ep.entrypoint();

        verifyInOrder([
          () => runner.parser.parse(arguments),
          () => runner.run(arguments),
        ]);
      });

      test('should run version', () async {
        final arguments = <String>['--version'];
        final runner = MwcRunner();
        final context = LaunchContext(
          directory: Directory.systemTemp,
        );
        final ep = EntryPointClass(
          arguments: arguments,
          context: context,
          runner: runner,
        );

        await ep.entrypoint();

        expect(arguments.contains('--version'), isTrue);

        verifyInOrder([
          () => runner.logger.detail('version'),
          () => runner.version(context),
        ]);
      });
    });
  });
}
