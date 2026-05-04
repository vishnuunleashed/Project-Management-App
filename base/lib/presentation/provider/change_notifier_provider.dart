import 'package:base/presentation/provider/base_change_notifier.dart';
import 'package:base/presentation/provider/settings/settings_provider.dart';

final settingsProvider = baseChangeNotifier<SettingsProvider>(() => SettingsProvider());