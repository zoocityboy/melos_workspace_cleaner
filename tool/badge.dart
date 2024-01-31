// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

class CovBadgeGen {
  // 60% & below

  CovBadgeGen(
    this.lcovPath,
    this.outputDir, {
    this.subject,
    this.successColor,
    this.warningColor,
    this.errorColor,
    this.warningThreshold,
    this.errorThreshold,
  }) {
    _setupLogger();
    _createFile();
  }
  final _log = Logger('CovBadgeGen');
  final String lcovPath;
  final String outputDir;
  late File _sourceFile;
  late File _outputFile;

  final String? subject;

  final String? successColor;
  final String? warningColor;
  final String? errorColor;

  final int? warningThreshold; // 80 % and below
  final int? errorThreshold;

  // ignore: prefer_constructors_over_static_methods
  static CovBadgeGen parseArguments(List<String> args) {
    final parser = ArgParser();
    parser.addOption(
      'lcov_path',
      abbr: 'p',
      defaultsTo: './coverage/lcov.info',
      help: 'lcov.info file path of test coverage',
    );
    parser.addOption(
      'output_dir',
      abbr: 'o',
      defaultsTo: './coverage',
      help: 'Output dir of generated badge',
    );
    parser.addOption(
      'subject',
      abbr: 't',
      defaultsTo: 'Coverage',
      help: 'This value will be added to left side of badge as title',
    );
    parser.addOption(
      'success_color',
      abbr: 's',
      defaultsTo: '#00e676',
      help:
          'Success color will show when coverage ratio is above warning threshold',
    );
    parser.addOption(
      'warning_color',
      abbr: 'w',
      defaultsTo: '#ff9100',
      help:
          'Warning color will show when coverage ratio is above error threshold',
    );
    parser.addOption(
      'error_color',
      abbr: 'e',
      defaultsTo: '#ff3d00',
      help:
          'Error color will show when coverage ratio is below or equal error threshold',
    );
    parser.addOption(
      'warning_threshold',
      abbr: 'W',
      defaultsTo: '80',
      help: 'Warning threshold will be used to determine warning color',
    );
    parser.addOption(
      'error_threshold',
      abbr: 'E',
      defaultsTo: '60',
      help: 'Error threshold will be used to determine error color',
    );
    final results = parser.parse(args);
    return CovBadgeGen(
      results['lcov_path'] as String,
      results['output_dir'] as String,
      subject: results['subject'] as String,
      successColor: results['success_color'] as String,
      warningColor: results['warning_color'] as String,
      errorColor: results['error_color'] as String,
      warningThreshold: int.parse(results['warning_threshold'] as String),
      errorThreshold: int.parse(results['error_threshold'] as String),
    );
  }

  Future<void> _createFile() async {
    _sourceFile = File(lcovPath);
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync();
      _log.info('Created output dir: $outputDir');
    }
    _outputFile = File(p.join(dir.path, 'coverage_badge.svg'));
  }

  Future<void> generateBadge() async {
    final coverageValue = await coverageRatio();
    _generateAndSaveSvg(coverageValue.toInt());
  }

  Future<double> coverageRatio() {
    return _readAndGetCoverage();
  }

  Future<double> _readAndGetCoverage() {
    final completer = Completer<double>();
    if (_sourceFile.existsSync()) {
      _log.info('lcov file reading started...');
      var instrumentedLines = 0;
      var coveredLines = 0;
      _sourceFile
          .openRead()
          .map(utf8.decode)
          .transform(const LineSplitter())
          .forEach((line) {
        if (line.startsWith('LH:')) {
          coveredLines += double.parse(line.split(':')[1]).round();
        } else if (line.startsWith('LF:')) {
          instrumentedLines += double.parse(line.split(':')[1]).round();
        }
      }).whenComplete(() {
        if (instrumentedLines == 0) {
          completer.complete(0);
        } else {
          completer.complete((coveredLines / instrumentedLines) * 100.0);
        }
      });
    } else {
      _log.warning('File not exists. Returning 0.0');
      completer.complete(0.0);
    }
    return completer.future;
  }

  void _generateAndSaveSvg(int ratio) {
    final badgeSvgStr = generateBadgeSvg(ratio);
    _outputFile.writeAsStringSync(badgeSvgStr, flush: true);
    _log.info('Badge created successfully with Coverage ration of $ratio%');
  }

  String generateBadgeSvg(int ratio) {
    String? selectedColor = '';
    if (ratio <= (errorThreshold ?? 0)) {
      selectedColor = errorColor;
    } else if (ratio <= (warningThreshold ?? 0)) {
      selectedColor = warningColor;
    } else {
      selectedColor = successColor;
    }
    final badgeSvgStr = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="94" height="20">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="a">
    <rect width="94" height="20" rx="0" fill="#fff"/>
  </clipPath>
  <g clip-path="url(#a)">
    <path fill="#555" d="M0 0h59v20H0z"/>
    <path fill="$selectedColor" d="M59 0h35v20H59z"/>
    <path fill="url(#b)" d="M0 0h94v20H0z"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="110">
    <text x="305" y="150" fill="#ffffff" fill-opacity=".3" transform="scale(.1)" textLength="490">$subject</text>
    <text x="305" y="140" transform="scale(.1)" textLength="490">$subject</text>
    <text x="755" y="150" fill="#ffffff" fill-opacity=".3" transform="scale(.1)" textLength="250">$ratio%</text>
    <text x="755" y="140" transform="scale(.1)" textLength="250">$ratio%</text>
  </g>
</svg>
    ''';
    return badgeSvgStr;
  }
}

void _setupLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    stdout.writeln(
      '${record.level.name}: [COV_BADGE_GEN] : ${record.time}: ${record.message}',
    );
  });
}

void main(List<String> args) async {
  final covBadgeGen = CovBadgeGen.parseArguments(args);
  await covBadgeGen.generateBadge();
}
