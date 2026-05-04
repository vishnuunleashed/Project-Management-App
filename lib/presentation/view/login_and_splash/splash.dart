import 'package:base/core/constants.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/settings.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/login_and_splash/login_provider.dart';
import 'package:interior_design/presentation/view/login_and_splash/update_prompt.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginProvider>(
      provider: loginProvider,
      initState: (context, provider, ref) {

        provider.checkFirstLaunch(onAutoLogin: () async {
          final connectivityResult = await Connectivity().checkConnectivity();
          bool isOffline = connectivityResult.contains(ConnectivityResult.none);
          int companyIdProvider = await BaseSecureStorage.getInt(BaseConstants.companyId);
          int userIdProvider = await BaseSecureStorage.getInt(BaseConstants.userID);
          if(isOffline && companyIdProvider != 0 && userIdProvider != 0){
            GoRouter.of(context).go(AppRoutes.home, extra: {'initialIndex': 3});
          }else{
            provider.authenticateAutoLogin(onSuccess: (mobileVersion) {
              if(mobileVersion == null){

                GoRouter.of(context).pushReplacement(AppRoutes.home);
                return;
              }
              UpdateDialog.show(
                context: context,
                androidVersion: Settings.getVersionAndroid(),
                iosVersion: Settings.getVersionIOS(),
                androidPackageName: Settings
                    .getPackageNameAndroid(),
                iosPackageName: Settings.getPackageNameIOS(),
                iosTestFlightUrl: Settings.getIOSTestFLightLink(),
                latestVersion: mobileVersion.version,
                isMandatory: mobileVersion.mandatoryyn == "Y",
              );
            },
            );
          }
        }, onFirstLaunch: () {
          // GoRouter.of(context).go(AppRoutes.login);
        });
        ref.read(settingsProvider).initFunctions();
      },
      builder: (context, provider, ref) {
        final ThemeMode currentTheme = ref.watch(
            settingsProvider.select((settings) => settings.currentTheme));
        bool isDarkTheme =
            (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark &&
                currentTheme == ThemeMode.system) ||
                currentTheme == ThemeMode.dark;
        return WillPopScope(
          onWillPop: ()async{
            SystemNavigator.pop();
            return false;
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _gradientColors(isDarkTheme),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Spacer(flex: 2),
                      // Logo Text
                      _logoWidget(context),
                      Spacer(
                        flex: provider.isFirstLaunch ? 1 : 2,
                      ),
                      // Welcome Text
                      _welcomeWidget(context,provider)
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _logoWidget(BuildContext context)=>
      Image.asset("assets/png/logo_splash.png",
        height: MediaQuery.of(context).size.height*0.2,


      );


  Widget _welcomeWidget(BuildContext context,LoginProvider provider) =>Visibility(
    visible: provider.isFirstLaunch,
    child: Column(
      children: [
        Text(
          'Sample Project',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 28,
              color:  Theme.of(context).primaryColor,
              fontFamily: "Righteous",
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _buildCarousel(provider),
        SizedBox(height: 32),
        // Get Started Button
        BaseElevatedButton(
          text: 'Let\'s Get Started',
          borderRadius: 8,
          fontWeight: FontWeight.w400,
          fontSize: 18,
          onPressed: () {
            if (provider.isFirstLaunch) {
              GoRouter.of(context).pushReplacement(AppRoutes.login);
            }
          },
        ),

        const SizedBox(height: 40),

      ],
    ),
  );

  List<Color> _gradientColors(bool isDarkTheme) => const [
    Color(0xFF0A1628),
    Color(0xFF112240),
    Color(0xFF1B4F72),
    Color(0xFF5B9EC9),
    Color(0xFFAED6F1),
    Color(0xFFEBF5FB),
  ];

  Widget _buildCarousel(LoginProvider provider) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: provider.carouselTexts.length,
          itemBuilder: (context, index, realIdx) {
            return Center(
              child: Text(
                provider.carouselTexts[index],
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
          options: CarouselOptions(
            height: 60,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            autoPlayInterval: Duration(milliseconds: 2500),
            onPageChanged: (index, reason) {
              provider.changePage(index);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: provider.carouselTexts.asMap().entries.map((entry) {
            int index = entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: provider.currentPage == index ? 44 : 21,
                height: 4,
                decoration: BoxDecoration(
                  color: provider.currentPage == index
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
