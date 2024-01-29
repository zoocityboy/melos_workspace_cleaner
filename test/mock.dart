import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwc/mwc.dart';

class MockMwcConfig extends Mock implements MwcConfig {}

class MockMwc extends Mock implements Mwc {}

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

class MockGlob extends Mock implements Glob {}
