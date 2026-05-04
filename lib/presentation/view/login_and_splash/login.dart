import 'package:base/data/services/settings.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/utility/base_password_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation_export.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interior_design/data/local/hive/project_sync_service.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/login_and_splash/login_provider.dart';
import 'package:interior_design/presentation/view/login_and_splash/update_prompt.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:go_router/go_router.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color _primary    = Color(0xFF0298DB);
  static const Color _topBgLight = Color(0xFF0D2137);
  static const Color _topBgDark  = Color(0xFF060F16);
  static const Color _bottomBgLight = Color(0xFFF5F8FA);
  static const Color _bottomBgDark  = Color(0xFF0D1A24);

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginProvider>(
      initState: (context, provider, ref) {
        provider.initValues();
      },
      provider: loginProvider,
      builder: (context, provider, ref) {
        final ThemeMode currentTheme = ref.watch(
            settingsProvider.select((settings) => settings.currentTheme));
        bool isDarkTheme =
            (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark &&
                currentTheme == ThemeMode.system) ||
                currentTheme == ThemeMode.dark;
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          backgroundColor: isDarkTheme ? _topBgDark : _topBgLight,
          body: WillPopScope(
            onWillPop: () async {
              SystemNavigator.pop();
              return false;
            },
            child: SafeArea(
              bottom: false,
              child: _bodyWidget(
                context: context,
                provider: provider,
                isDarkTheme: isDarkTheme,
                screenHeight: screenHeight,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bodyWidget({
    required BuildContext context,
    required LoginProvider provider,
    required bool isDarkTheme,
    required double screenHeight,
  }) {
    final Color topBg    = isDarkTheme ? _topBgDark : _topBgLight;
    final Color bottomBg = isDarkTheme ? _bottomBgDark : _bottomBgLight;
    final Color cardBg   = isDarkTheme
        ? Colors.white.withOpacity(0.06)
        : Colors.white;

    return Stack(
      children: [
        // ── Top charcoal blue section (unchanged) ───────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenHeight * 0.40,
          child: Container(color: topBg),
        ),

        // ── Bottom section (unchanged) ──────────────────────────────
        Positioned(
          top: screenHeight * 0.40,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: bottomBg),
        ),

        // ── Diagonal clip (unchanged) ───────────────────────────────
        Positioned(
          top: screenHeight * 0.32,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _DiagonalClipper(),
            child: Container(
              height: 80,
              color: bottomBg,
            ),
          ),
        ),



        // ── Fixed logo — sits above scroll, never moves ─────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenHeight * 0.36,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/logo_sky_blue.svg',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 14),
              const Text(
                'Keechery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Design your dream space',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.50),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable content — form card only ─────────────────────
        Positioned(
          top: MediaQuery.of(context).viewInsets.bottom > 0
              ? screenHeight * 0.30  // ← shrinks logo space when keyboard opens
              : screenHeight * 0.36, // ← normal position
          left: 0,
          right: 0,
          bottom: 0,

          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: provider.loginFormKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.07)
                          : const Color(0xFFE2EBF0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A1F2E)
                            .withOpacity(isDarkTheme ? 0.45 : 0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDarkTheme
                              ? Colors.white
                              : const Color(0xFF0A1F2E),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      BaseUserNameField(
                        maxLength: 50,
                        controller: provider.userNameController,
                        displayTitle: "Username",
                        hintText: "",
                        isRequiredField: true,
                        hintTextNeeded: false,
                        customValidationMessage: "This field is required",
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      BasePasswordField(
                        maxLength: 50,
                        controller: provider.passwordController,
                        displayTitle: "Password",
                        hintText: "",
                        hintTextNeeded: false,
                        validator: (val) {
                          return val == null || val.isEmpty
                              ? "Please enter Password"
                              : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed('forgotPasswordScreen');
                          },
                          child: const Text(
                            "Forgot your password?",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      BaseElevatedButton(
                        text: 'Log In',
                        height: 52,
                        borderRadius: 12,
                        onPressed: () {

                          if (provider.loginFormKey.currentState!.validate()) {
                            provider.authenticate(
                              onSuccess: (mobileVersion) async {
                                if (mobileVersion == null) {
                                  ///to ensure the hive box is cleared.
                                  await DccLocalStorageService().clearAll();
                                  ProjectSyncService().clearCache();
                                  GoRouter.of(context)
                                      .pushReplacement(AppRoutes.home);
                                  return;
                                }
                                UpdateDialog.show(
                                  context: context,
                                  androidVersion: Settings.getVersionAndroid(),
                                  iosVersion: Settings.getVersionIOS(),
                                  androidPackageName:
                                  Settings.getPackageNameAndroid(),
                                  iosPackageName: Settings.getPackageNameIOS(),
                                  iosTestFlightUrl:
                                  Settings.getIOSTestFLightLink(),
                                  latestVersion: mobileVersion.version,
                                  isMandatory: mobileVersion.mandatoryyn == "Y",
                                );
                              },
                            );
                          }
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Unchanged — exactly as original
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}