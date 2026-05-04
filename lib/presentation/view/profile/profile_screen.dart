import 'dart:io';


import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data_export.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_media_service.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/camera_for_profile_picture.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:dcc_module/presentation/provider/dcc_provider.dart';
import 'package:dcc_module/presentation/view/dcc_screen.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/local/hive/project_sync_service.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/provider/profile/profile_provider.dart';
import 'package:interior_design/presentation/view/profile/personal_information.dart';
import 'package:interior_design/presentation/view/profile/profile_picture.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/notification_api.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:workmanager/workmanager.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String _toCamelCase(String input) {
      if (input.isEmpty) return '';
      return input
          .split(' ')
          .map((word) =>
      word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
          .join(' ');
    }

    return BaseView<ProfileProvider>(
      initState: (context,provider,ref) async{
        provider.getUserName();
      },
      provider: profileProvider,
      appBar: CustomAppBar(
        title: Text("Profile"),
      ),
      builder: (context, provider, ref) => RefreshIndicator(
        color:Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).highlightColor,
        onRefresh: () async {
          await provider.refreshAttachmentsDetail();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          children: [
            const CurvedHeader(),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    _toCamelCase(provider.userName),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Text(
                    provider.departmentName,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Section: Account Info
            const SectionTitle(title: "ACCOUNT INFORMATION"),
            MenuTile(
              icon: Icons.person,
              title: "Personal Information",
              onTap: () {
                GoRouter.of(context).pushNamed(AppRoutes.personalInformation);
              },
            ),
            MenuTile(
              icon: Icons.content_paste_search,
              title: "Observations",
              onTap: () {
                GoRouter.of(context).pushNamed(AppRoutes.myObservationPage,
                    extra: {"isFromProjectDetails": false, "tag": "CREATED"});
              },
            ),
            MenuTile(
              icon: Icons.support_agent,
              title: "Support Requests",
              onTap: () {
                GoRouter.of(context).pushNamed(AppRoutes.mySupportRequestScreen,
                    extra: {"isFromProjectDetails": false, "tag": "CREATED",});
              },
            ),
            const SectionTitle(title: "ACCOUNT SECURITY"),
            MenuTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {
                GoRouter.of(context).pushNamed(AppRoutes.changePasswordScreen);
              },
            ),

            const SectionTitle(title: "OTHER"),
            MenuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () {
                logOutPopUp(context, ref);
              },
              isLogout: true,
            ),
            const SizedBox(height: 12),
            Visibility(
              visible: Platform.isAndroid,
              child: Text("APP VERSION ANDROID: ${Settings.getVersionAndroid()}",
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,),
            ),
            Visibility(
              visible: Platform.isIOS,
              child: Text("APP VERSION IOS : ${Settings.getVersionIOS()}",
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,),
            ),

            Text("CLIENT ID : "+Connections().clientId,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,),

            const SizedBox(height: 50),
          ],
        ),
      ),

    );
  }}


logOutPopUp(BuildContext context, WidgetRef ref) async {
  final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
    BaseSnackBar().show(
      message: "Logout is not allowed when you are offline.",
    );
    return;
  }

  return BaseDialog.show(
      context: context,
      title: "Logout",
      message: "Do you want to logout?",
      actions: [
        Row(
          spacing: 8,
          children: [
            Expanded(
                child: BaseElevatedButton(
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              text: "Yes",
              onPressed: () async {
                ref.read(profileProvider).clearProfileProviderData();
                ref.read(homeProvider).onTabSelected(0);
                ref.read(homeProvider).resetSelectedIndex();

                ref.read(loginProvider).unsubscribeTopics();
                flutterLocalNotificationsPlugin.cancelAll();
                // Save theme values before clearing
                final router = GoRouter.of(context); // capture router before await
                final theme = await BaseSecureStorage.getString(BaseConstants.startingTheme);
                final variant = await BaseSecureStorage.getString(BaseConstants.startingThemeVariant);

                await BaseSecureStorage.clearAll();

                ///________________________DCC RELATED_________________________//

                await DccLocalStorageService().clearAll();
                ProjectSyncService().clearCache();
                DccProvider().disposeConnections();
                ref.read(dccProvider).reset();
                ref.read(dccProjectProvider).reset();
                Workmanager().cancelAll();

                ///____________________________________________________________//
                // Restore theme values after clearing
                if (theme.isNotEmpty) {
                  await BaseSecureStorage.setString(BaseConstants.startingTheme, theme);
                }
                if (variant.isNotEmpty) {
                  await BaseSecureStorage.setString(BaseConstants.startingThemeVariant, variant);
                }
                router.pushReplacement(AppRoutes.login);
              },
            )),
            Expanded(
                child: BaseElevatedButton(
              borderRadius: 24,
              onPressed: () {
                GoRouter.of(context).pop();
              },
              backgroundColor: bayaInfraDisabledColor,
              text: "No",
            )),
          ],
        ),
      ]);
}


class CurvedHeader extends StatelessWidget {
  const CurvedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseConsumer(
      provider: profileProvider,
      builder: (context, provider, ref) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 200,
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Pattern background
                    SvgPicture.asset(
                      'assets/svgs/profile_doodle_two.svg',
                      fit: BoxFit.cover,
                    ),

                    // Optional: gradient overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.inversePrimary,
                            Theme.of(context).colorScheme.onInverseSurface,
                            Theme.of(context).colorScheme.inverseSurface
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile avatar positioned over the curve
            Positioned(
              bottom: -15,
              child: ProfileAvatar(
                fileName: provider.profileImageUrl.isEmpty
                    ? ""
                    : provider.profileImageUrl,
                onClickEdit: () async {
                  final File? image =
                  await SingleImageService.instance.pickImageWithCrop(context: context,showGalleryUpload: true);
                  if (image != null) {
                    provider.uploadImageFile([image]);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}




class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80); // start lower for more depth

    // Make the curve deeper by pulling the control point further down
    path.quadraticBezierTo(
      size.width / 2, size.height + 40, // control point lower
      size.width, size.height - 80,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ---------------- Section Title ----------------
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------- Menu Tile ----------------
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).cardColor,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isLogout ? Colors.red : null,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red : Colors.blueGrey,
        ),
        onTap: onTap,
      ),
    );
  }
}
