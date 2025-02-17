import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class LoggerManager {
  static final Logger _logger = Logger('Kaouka');
  static File? _logFile;

  static void setupLogging() async {
    Logger.root.level = Level.ALL;
    await _initializeFile();
    _logger.onRecord.listen((LogRecord record) {
      if (_logFile != null) {
        _logFile!.writeAsStringSync(
            '${record.time} [${record.level.name}] ${record.message}\n',
            mode: FileMode.append);
      }
    });
  }

  static Future<void> _initializeFile() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final logFilePath = '${appDocumentsDirectory.path}/kaouka.log';
    _logFile = File(logFilePath);
    if (!_logFile!.existsSync()) {
      _logFile!.createSync();
    }
  }

  static void logInfo(String message) {
    _logger.info('kaouka -> $message');
  }

  static void logWarning(String message) {
    _logger.warning('kaouka -> $message');
  }

  static void logError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    print(message);
    _logger.severe('kaouka -> $message\n$error', error, stackTrace);
  }
}
