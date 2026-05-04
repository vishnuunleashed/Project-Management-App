import 'dart:io';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatefulWidget {
  final String androidVersion;
  final String iosVersion;
  final String androidPackageName;
  final String iosPackageName;
  final String iosTestFlightUrl;
  final String latestVersion;
  final bool isMandatory;

  const UpdateDialog({
    Key? key,
    required this.androidVersion,
    required this.iosVersion,
    required this.androidPackageName,
    required this.iosPackageName,
    required this.iosTestFlightUrl,
    required this.latestVersion,
    required this.isMandatory,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required String androidVersion,
    required String iosVersion,
    required String androidPackageName,
    required String iosPackageName,
    required String iosTestFlightUrl,
    required String latestVersion,
    required bool isMandatory,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: UpdateDialog(
          androidVersion: androidVersion,
          iosVersion: iosVersion,
          androidPackageName: androidPackageName,
          iosPackageName: iosPackageName,
          iosTestFlightUrl: iosTestFlightUrl,
          latestVersion: latestVersion,
          isMandatory: isMandatory,
        ),
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _SimpleUpdateDialogState();
}

class _SimpleUpdateDialogState extends State<UpdateDialog> {
  bool _isLoading = false;
  bool _testFlightAvailable = false;
  final bool _isIOS = Platform.isIOS;

  @override
  void initState() {
    super.initState();
    if (_isIOS) _checkTestFlight();
  }

  Future<void> _checkTestFlight() async {
    final canOpen = await canLaunchUrl(Uri.parse('itms-beta://'));
    if (mounted) setState(() => _testFlightAvailable = canOpen);
  }

  Future<void> _openStore() async {
    setState(() => _isLoading = true);

    Uri url;
    final packageName = _isIOS ? widget.iosPackageName : widget.androidPackageName;

    if (_isIOS) {
      url = _testFlightAvailable
          ? Uri.parse(widget.iosTestFlightUrl.replaceFirst('https://', 'itms-beta://'))
          : Uri.parse('itms-apps://itunes.apple.com/app/$packageName');
    } else {
      url = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
    }

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      final fallback = _isIOS
          ? widget.iosTestFlightUrl
          : 'https://play.google.com/store/apps/details?id=$packageName';
      await launchUrl(Uri.parse(fallback), mode: LaunchMode.platformDefault);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _handleMaybeLater() {
    GoRouter.of(context).pushReplacement(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // Title
             Text(
              'Update Alert !',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,

              ),
            ),

            const SizedBox(height: 8),

            // Description
             Text(
              'There\'s a newer version of the  app\n available',
              textAlign: TextAlign.center,
              style:  Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,

                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),


            // Buttons Row
            Visibility(
              visible: !widget.isMandatory,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Maybe later" button (only if optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.045,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextButton(

                          onPressed: _handleMaybeLater,
                          child: Text('Maybe later',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              ),
                            ),
                            ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.045,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextButton(
                          onPressed: _openStore,
                          child: Text('Update',style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          )

                      ),
                    ),
                  ),

                ],
              ),
            ),
            Visibility(
              visible: widget.isMandatory,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextButton(

                      onPressed: _openStore,
                      child: Text('Update',style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      )

                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOW TO USE:
// ─────────────────────────────────────────────
//
// // Mandatory Update (user cannot dismiss, no "Maybe later" button)
// if (apiResponse.forceUpdate) {
//   SimpleUpdateDialog.show(
//     context: context,
//     androidVersion:      'x.x.x',
//     iosVersion:          'x.x.x',
//     androidPackageName:  'com.example.app',
//     iosPackageName:      'com.example.app',
//     iosTestFlightUrl:    'https://testflight.apple.com/join/xxxxxxxx',
//     latestVersion:       'x.x.x',
//     isMandatory:         true,
//   );
// }
//
// // Optional Update (user can click "Maybe later" to navigate to home)
// // Dialog is non-dismissible - must click a button
// if (apiResponse.updateAvailable && !apiResponse.forceUpdate) {
//   SimpleUpdateDialog.show(
//     context: context,
//     androidVersion:      'x.x.x',
//     iosVersion:          'x.x.x',
//     androidPackageName:  'com.example.app',
//     iosPackageName:      'com.example.app',
//     iosTestFlightUrl:    'https://testflight.apple.com/join/xxxxxxxx',
//     latestVersion:       'x.x.x',
//     isMandatory:         false,
//   );
// }
//
// Note: Clicking "Maybe later" will execute:
//       GoRouter.of(context).pushReplacement(AppRoutes.home);
//
// ─────────────────────────────────────────────