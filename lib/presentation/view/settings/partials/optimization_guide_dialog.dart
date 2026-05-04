/*------------------------------------------------------------------------------
AUTHOR		    : Antigravity
CREATED DATE	: 24/04/2026
PURPOSE		    : Optimization Guide Dialog
MODULE/TOPIC	: Settings
REMARKS		    : Guides user to enable background sync permissions
--------------------------------------------------------------------------------*/
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/utils/system_optimization_service.dart';

class OptimizationGuideDialog extends StatelessWidget {
  const OptimizationGuideDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OptimizationGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: theme.primaryColor),
          const SizedBox(width: 12),
          const Expanded(child: Text("Background Sync Setup")),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "To ensure your data stays updated even when the app is minimized, please enable unrestricted battery usage and allow background data access.",
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "This prevents the system from pausing sync tasks while you are using other apps.",
            style: theme.textTheme.labelSmall?.copyWith(

              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await SystemOptimizationService.requestIgnoreBatteryOptimizations();
              },
              icon: const Icon(Icons.battery_saver_rounded, size: 20,color: bayaInfraWhiteColor,),
              label: Text("Optimize Battery",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: bayaInfraWhiteColor )),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await SystemOptimizationService.openAppRestrictionsSettings();
              },
              icon: const Icon(Icons.settings_applications_rounded, size: 20,color: bayaInfraWhiteColor,),
              label: Text("Background Data & Restrictions",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: bayaInfraWhiteColor ) ,),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Done",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: bayaInfraWhiteColor )),
            ),
          ],
        ),
      ],
    );
  }
}
