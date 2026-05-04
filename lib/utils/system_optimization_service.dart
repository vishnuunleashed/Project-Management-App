import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class SystemOptimizationService {
  /// Checks if the app is already ignoring battery optimizations (Android only).
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  /// Requests the user to ignore battery optimizations (Android only).
  /// This triggers the system dialog.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  /// Opens the App Info settings page so the user can manually configure
  /// background data and other restrictions.
  static Future<void> openAppRestrictionsSettings() async {
    await openAppSettings();
  }
}
