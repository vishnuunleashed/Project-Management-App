/*------------------------------------------------------------------------------
AUTHOR		    : Karan Sreyas
CREATED DATE	: 07/08/2025
PURPOSE		    : Settings Provider
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ThemeConfig { auto, dark, light }

class SettingsProvider extends BaseProvider {


  ThemeMode currentTheme = ThemeMode.system;

  ThemeConfig themeConfig = ThemeConfig.auto;

  final MethodChannel platform = MethodChannel('com.infra.interior_design/resourceResolver');

  // ── Colour Variant ─────────────────────────────────────────────────────────
  AppThemeVariant _currentVariant = AppThemeVariant.skyBlue;
  AppThemeVariant get currentVariant => _currentVariant;
  bool _variantInitialized = false;


  Future<void> initFunctions() async {
    isExpaned = false;
    await initTheme();
    await initColorVariant();
  }


  void changeTheme(ThemeConfig themeConfig)  {
    switch (themeConfig) {
      case ThemeConfig.dark:
        BaseSecureStorage.setString(BaseConstants.startingTheme, "dark");
        currentTheme = ThemeMode.dark;
        notifyListeners();
        return;
      case ThemeConfig.light:
        BaseSecureStorage.setString(BaseConstants.startingTheme, "light");
        currentTheme = ThemeMode.light;
        notifyListeners();
        return;
      default:
        BaseSecureStorage.setString(BaseConstants.startingTheme, "system");
        currentTheme = ThemeMode.system;
        notifyListeners();
        return;

    }
  }

  Future<void> requestLocalNetworkPermission() async {
    try {
      await platform.invokeMethod("requestLocalNetworkPermission");
    } catch (e) {
      print("Failed to request local network permission: $e");
    }
  }

  Future<void> initTheme() async {
    String theme = await BaseSecureStorage.getString(BaseConstants.startingTheme);
    switch (theme) {
      case "dark":
        currentTheme = ThemeMode.dark;
        notifyListeners();
        return;
      case "light":
        currentTheme = ThemeMode.light;
        notifyListeners();
        return;
      default:
        currentTheme = ThemeMode.system;
        notifyListeners();
        return;
    }
  }

// ── Colour Variant ─────────────────────────────────────────────────────────
  Future<void> changeColorVariant(AppThemeVariant variant) async {
    _currentVariant = variant;
    await BaseSecureStorage.setString(BaseConstants.startingThemeVariant, variant.name);
    notifyListeners();
  }

  Future<void> initColorVariant() async {
    if (_variantInitialized) return;
    final saved = await BaseSecureStorage.getString(BaseConstants.startingThemeVariant);
    _currentVariant = AppThemeVariant.values.firstWhere(
          (v) => v.name == saved,
      orElse: () => AppThemeVariant.skyBlue,
    );
    _variantInitialized = true;
    notifyListeners();
  }

  bool isExpaned = false;

  void changeExpandFlagStatus(bool expanded){
    isExpaned = expanded;
    notifyListeners();
  }


}
