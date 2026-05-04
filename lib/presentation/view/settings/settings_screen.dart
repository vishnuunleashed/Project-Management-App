/*------------------------------------------------------------------------------
AUTHOR		    : Karan Sreyas
CREATED DATE	: 07/08/2025
PURPOSE		    : Settings Screen
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'dart:io';

import 'package:base/data/services/settings.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/provider/settings/settings_provider.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/local/hive/dcc_hive_debug_utility.dart';
import 'package:interior_design/presentation/view/settings/partials/notification_settings.dart';
import 'package:interior_design/presentation/view/settings/partials/theme_setting.dart';
import 'package:interior_design/utils/background_logger.dart';

import 'package:interior_design/presentation/view/settings/partials/optimization_guide_dialog.dart';
import 'package:open_filex/open_filex.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsProvider>(
      provider: settingsProvider,
      appBar: CustomAppBar(
        title: Text("Settings"),
      ),
      initState: (context,provider,ref) {
        provider.initFunctions();
      },
      builder: (context, provider, ref) => ListView(
        physics: ClampingScrollPhysics(),
        children: [
          NotificationSetting(value: provider),
          ThemeSetting(value: provider),
          
          // ── Hive Debug Export ─────────────────────────────────────
          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                color: Theme.of(context).cardColor,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).disabledColor),
                ),
                child: ListTile(
                  onTap: () async {
                    final path = await DccHiveDebugUtility.exportDccDataToJSON();
                    if (path != null) {
                      OpenFilex.open(path);
                    } else {
                      BaseSnackBar().show(
                        message: 'Failed to export data'
                      );
                    }
                  },
                  leading: Icon(Icons.bug_report_outlined,
                    color: Theme.of(context).textTheme.labelMedium?.color),
                  title: Text(
                    "Download Offline Data",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.labelMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    "Export DCC Hive boxes to JSON",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.download_rounded, size: 20),
                ),
              ),
            ),
          ),

          // ── Background Logs Export ────────────────────────────────
          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                color: Theme.of(context).cardColor,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).disabledColor),
                ),
                child: ListTile(
                  onTap: () async {
                    final path = await BackgroundLogger.getExportPath();
                    if (path != null) {
                      OpenFilex.open(path);
                    } else {
                      BaseSnackBar().show(
                        message: 'No background logs found'
                      );
                    }
                  },
                  leading: Icon(Icons.history_edu_rounded,
                    color: Theme.of(context).textTheme.labelMedium?.color),
                  title: Text(
                    "Download Background Logs",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.labelMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    "Debug log for background tasks",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.download_rounded, size: 20),
                ),
              ),
            ),
          ),

          // ── Background Sync Optimization ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              color: Theme.of(context).cardColor,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).disabledColor),
              ),
              child: ListTile(
                onTap: () {
                  OptimizationGuideDialog.show(context);
                },
                leading: Icon(Icons.sync_lock_rounded, 
                  color: Theme.of(context).textTheme.labelMedium?.color),
                title: Text(
                  "Background Sync Optimization",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).textTheme.labelMedium?.color,
                  ),
                ),
                subtitle: Text(
                  "Allow data sync when the app is minimized",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Icon(Icons.chevron_right_rounded, 
                  color: Theme.of(context).iconTheme.color),
              ),
            ),
          ),

          Padding(
              padding: const EdgeInsets.all(8),

              child: Card(
                color: Theme.of(context).cardColor,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).disabledColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,color:  Theme.of(context).textTheme.labelMedium?.color),
                          const SizedBox(width: 16),
                          Text(
                            "App Version",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.labelMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: Platform.isAndroid,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "${Settings.getVersionAndroid()}(Android)",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.labelMedium?.color,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: Platform.isIOS,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "${Settings.getVersionIOS()}(IOs)",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).textTheme.labelMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )

          )

        ],
      ),
    );
  }
}

