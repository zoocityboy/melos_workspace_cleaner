import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_launcher/cli_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:file/file.dart' as f;
import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/mwc.dart';
import 'package:pub_updater/pub_updater.dart';

import 'fixture/mwc_melos_yaml.dart';

class MockLaunchContext extends Mock implements LaunchContext {}

class MockExecutableInstallation extends Mock
    implements ExecutableInstallation {}

class MockMwcConfig extends Mock implements MwcConfig {}

class MockMwc extends Mock implements Mwc {}

class MockMwcRunner extends Mock implements MwcRunner {}

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

class MockGlob extends Mock implements Glob {}

class MockFile extends Mock implements File {}

class FakeMelosFile extends Fake implements File {
  FakeMelosFile({this.isExists = true, this.content = melosYamlContent});
  final bool isExists;
  final String content;
  @override
  String get path => 'melos.yaml';
  @override
  bool existsSync() => isExists;
  @override
  Future<String> readAsString({Encoding encoding = utf8}) async => content;
  @override
  String readAsStringSync({Encoding encoding = utf8}) => content;
}

class FakeMwcFile extends Fake implements File {
  FakeMwcFile({this.isExists = true, this.content = mwcYamlContent});
  final bool isExists;
  final String content;
  @override
  String get path => 'mwc.yaml';
  @override
  bool existsSync() => isExists;
  @override
  Future<String> readAsString({Encoding encoding = utf8}) async => content;
  @override
  String readAsStringSync({Encoding encoding = utf8}) => content;
}

class MockFileSystemEntity extends Mock implements f.FileSystemEntity {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockArgParser extends Mock implements ArgParser {}

class MockArgResults extends Mock implements ArgResults {}

final testMwcConfigFile = File(
  [
    Directory.current.path,
    'tmp',
    DateTime.now().toUtc().toIso8601String(),
    'mwc.yaml',
  ].join(Platform.pathSeparator),
);
final testMelosConfigFile = File(
  [
    Directory.current.path,
    'tmp',
    DateTime.now().toUtc().toIso8601String(),
    'melos.yaml',
  ].join(Platform.pathSeparator),
);

///
T testRunZoned<T>(
  T Function() body, {
  Map<Object?, Object?>? zoneValues,
  Stdin Function()? stdin,
  Stdout Function()? stdout,
}) {
  return runZoned(
    () => IOOverrides.runZoned(body, stdout: stdout, stdin: stdin),
    zoneValues: zoneValues,
  );
}

Logger mockLogger({Progress? progress}) {
  final logger = MockLogger();
  when(() => logger.detail(any())).thenReturn(null);
  when(() => logger.err(any())).thenReturn(null);
  when(() => logger.info(any())).thenReturn(null);
  when(() => logger.success(any())).thenReturn(null);
  when(() => logger.warn(any())).thenReturn(null);
  when(() => logger.progress(any())).thenReturn(progress ?? MockProgress());
  return logger;
}
