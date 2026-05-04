import 'package:hive_flutter/hive_flutter.dart';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';
import 'package:dcc_module/data/local/dcc_hive_models.dart';

/// Configuration and initialization for the DCC module.
class DccModuleConfig {
  static final DccModuleConfig instance = DccModuleConfig._internal();
  DccModuleConfig._internal();

  bool _isInitialized = false;

  /// Initialize the DCC module.
  /// [tokenProvider] is optional. [userIdProvider] and [companyIdProvider] are mandatory.
  /// Values fetched from these providers are stored in [DccSecureStorage] for module use.
  Future<void> init({
    Future<String?> Function()? tokenProvider,
    required Future<int?> Function() userIdProvider,
    required Future<int?> Function() companyIdProvider,
    required Future<int?> Function() syncIntervalProvider,
    required Future<String?> Function() getClientId,
  }) async {
    // Always re-seed credentials (handles re-login and auto-login)
    if (tokenProvider != null) {
      final token = await tokenProvider();
      if (token != null) {
        await DccSecureStorage.setString(DccConstants.token, token);
      }
    }

    final userId = await userIdProvider();
    if (userId != null) {
      await DccSecureStorage.setInt(DccConstants.userId, userId);
    }

    final companyId = await companyIdProvider();
    if (companyId != null) {
      await DccSecureStorage.setInt(DccConstants.companyId, companyId);
    }

    final syncInterval = await syncIntervalProvider();
    if (syncInterval != null) {
      await DccSecureStorage.setInt(DccConstants.syncInterval, syncInterval);
    }
    final clientId = await getClientId();
    if (clientId != null) {
      await DccSecureStorage.setString(DccConstants.clientId, clientId);
    }

    // Initialize Hive only once
    if (!_isInitialized) {
      await _initHive();
      _isInitialized = true;
    }
  }

  /// Manually update user info in the module's secure storage.
  Future<void> setUserInfo({String? token, int? userId, int? companyId,int? syncInterval}) async {
    if (token != null) await DccSecureStorage.setString(DccConstants.token, token);
    if (userId != null) await DccSecureStorage.setInt(DccConstants.userId, userId);
    if (companyId != null) await DccSecureStorage.setInt(DccConstants.companyId, companyId);
    if (companyId != null) await DccSecureStorage.setInt(DccConstants.syncInterval, syncInterval??30);
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    // Register DCC specific Hive adapters
    if (!Hive.isAdapterRegistered(110)) {
      Hive.registerAdapter(DccFolderHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(111)) {
      Hive.registerAdapter(DccFileHiveAdapter());
    }
  }
}
