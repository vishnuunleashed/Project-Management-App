import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/settings.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/provider/settings/settings_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/services/_connection_props.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';
import 'package:dcc_module/domain/usecase/dcc_sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:interior_design/data/local/hive/project_sync_service.dart';
import 'package:interior_design/data/remote/repository/home/home_repository_impl.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/local/hive/home_projectlist_model_adapter.dart';
import 'package:dcc_module/dcc_module.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/utils/notification_api.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:interior_design/utils/background_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher,isInDebugMode: true);

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(myBackgroundHandler);

  int companyIdProvider = await BaseSecureStorage.getInt(BaseConstants.companyId);
  int userIdProvider = await BaseSecureStorage.getInt(BaseConstants.userID);
  if(companyIdProvider != 0 && userIdProvider != 0){
    await DccModuleConfig.instance.init(
      tokenProvider: () => BaseSecureStorage.getString(BaseConstants.token),
      userIdProvider: () => BaseSecureStorage.getInt(BaseConstants.userID),
      companyIdProvider: () => BaseSecureStorage.getInt(BaseConstants.companyId),
      syncIntervalProvider: () => BaseSecureStorage.getInt(BaseConstants.syncInterval),
      getClientId: ()async=>Connections().clientId
    );
  }

  // Register Main App Hive Adapters (TypeIDs 112)
  if (!Hive.isAdapterRegistered(112)) {
    Hive.registerAdapter(DccProjectHiveAdapter());
  }


  FirebaseMessaging.onMessage.listen((message) async {
    print("message_received_app_opened");
    if (Platform.isAndroid) {
      await showNotification(message);
    }
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);






  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: BaseConsumer<SettingsProvider>(
          provider: settingsProvider,
          initState: (context,provider,ref){
            Settings.initVersion();
            provider.initFunctions();
            if(Platform.isIOS) {
              provider.requestLocalNetworkPermission();
            }
            BaseSecureStorage.setBool(BaseConstants.isInitialLoad, true);

          },
          builder: (context,provider,ref) {
            final variant = provider.currentVariant;
            return MaterialApp.router(
                  title: 'Keechery',
                  debugShowCheckedModeBanner: false,
                  theme: AppThemes.light(variant),
                  darkTheme: AppThemes.dark(variant),
                  themeMode: provider.currentTheme,
                  routerConfig: AppRoutes.router,


                );
          }
        ));
  }
}

@pragma('vm:entry-point')
Future<void> myBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("message_received_app_closed");

  if (Platform.isAndroid) {
    await showNotification(message);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  log('callbackDispatcher called');
  Workmanager().executeTask((taskName, inputData) async {
    try {

      await BackgroundLogger.log('Workmanager task started: $taskName');

      await ProjectSyncService.performRobustBackgroundSync();
      await BackgroundLogger.log('Workmanager task completed successfully');
      return Future.value(true); // success
    } catch (e) {
      await BackgroundLogger.log('Workmanager task failed with error: $e');
      if (e.toString().isNotEmpty) {
        return Future.value(false); // triggers retry via backoff
      }
      return Future.value(false);
    }
  });
}
