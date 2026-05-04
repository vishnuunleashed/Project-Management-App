import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BackgroundLogger {
  static const String _logFileName = 'background_logs.txt';

  /// Returns the log file instance.
  static Future<File> get _logFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_logFileName');
  }

  /// Appends a new log entry to the file.
  /// Each entry is a single-line JSON string followed by a newline.
  static Future<void> log(String message) async {
    try {
      final file = await _logFile;
      final entry = {
        'timestamp': DateTime.now().toIso8601String(),
        'message': message,
      };
      
      final logLine = jsonEncode(entry) + '\n';
      await file.writeAsString(logLine, mode: FileMode.append, flush: true);
    } catch (e) {
      // In background tasks, we can't do much if file I/O fails, 
      // but we try to avoid crashing.
      stderr.writeln('BackgroundLogger Error: $e');
    }
  }

  /// Returns the current log file path for export/download.
  static Future<String?> getExportPath() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clears all log entries.
  static Future<void> clearLogs() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      stderr.writeln('BackgroundLogger Clear Error: $e');
    }
  }
}
