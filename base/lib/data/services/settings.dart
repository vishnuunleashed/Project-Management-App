import 'dart:io';

class Settings {
  Settings._();

  static String _versionNumberAndroid = "1.11.0";
  static String _versionNumberIOS = "1.11.0";
  static String _versionNumber = "0.0.0";
  static String _ostype = "ANDROID";
  static String _appType = "USER_APP_MOBILE";
  static String _packageNameAndroid = "com.infra.interior_design";
  static String _packageNameIOS = "com.infra.spacendesign";
  static String _iosTestFlightLink = "https://testflight.apple.com/join/KG9jcpEh";


  static String getVersionAndroid() => _versionNumberAndroid;
  static String getVersionIOS() => _versionNumberIOS;
  static String getVersionNumber() => _versionNumber;
  static String getOSType() => _ostype;
  static String getAppType() => _appType;
  static String getPackageNameAndroid() => _packageNameAndroid;
  static String getPackageNameIOS() => _packageNameIOS;
  static String getIOSTestFLightLink() => _iosTestFlightLink;

  /// Sets _ostype based on the current platform.
  /// Call once in main() before runApp.
  static void initVersion() {
    _ostype = Platform.isIOS ? "IOS" : "ANDROID";
    _versionNumber = Platform.isIOS ? _versionNumberIOS : _versionNumberAndroid;
    print("Platform: $_ostype, Version: $_versionNumber");
  }
}

