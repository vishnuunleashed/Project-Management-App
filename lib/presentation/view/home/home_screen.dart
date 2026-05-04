
import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/base/base_need_resume.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_firebase.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation_export.dart';
import 'package:dcc_module/dcc_module.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/view/home/partials/customer_bottom_bar.dart';
import 'package:interior_design/presentation/view/home/partials/main_home_widget.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';
import 'package:interior_design/presentation/view/settings/settings_screen.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/routes.dart';

class HomeMainScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeMainScreen({super.key, this.initialIndex = 0});

  @override
  ResumableState<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends ResumableState<HomeMainScreen> with RouteAware, SingleTickerProviderStateMixin{

  bool _isPageRoute = false;

  @override
  void didPushNext() {
    _isPageRoute = ObserverUtils.routeObserver.lastPushedRoute is PageRoute;
    super.didPushNext();
  }

  @override
  void didPopNext()  {
    if (_isPageRoute) {
      Future.microtask(() async {
        HomeProvider provider = ref.read(homeProvider);
        provider.loadAllStatusesParallel();
        provider.fetchNotificationCountList(updateBadgeCount: false);
        ref.read(callTrackerProvider).refreshWithFilters();
      });
    }
    _isPageRoute = false;
    super.didPopNext();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }


  @override
  void onResume() {

    HomeProvider provider = ref.watch(homeProvider);
    provider.fetchNotificationCountList(updateBadgeCount: false);
    ref.watch(projectDashboardProvider).initValue();
    ref.read(callTrackerProvider).refreshWithFilters();
    ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context).read(callTrackerProvider).loadTickets();
    super.onResume();
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }
  int tabBarIndex = 0;
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(homeProvider);
    return DefaultTabController(
      length:4,
      initialIndex: widget.initialIndex,
      child: BaseView<HomeProvider>(

        isLoaderRequired: false,
        bottomSafeAreaColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        // backgroundColor: Theme.of(context).colorScheme.secondary,
        onWillPop: (context)async{
          if(provider.selectedOptionIndex != 3){
            DefaultTabController.of(context).animateTo(0,duration: Duration(milliseconds: 500));
          }else if(provider.selectedOptionIndex == 3 && ref.watch(dccProvider).isAtRoot){
            DefaultTabController.of(context).animateTo(0,duration: Duration(milliseconds: 500));
          }
          return false;
        },
        builder: (context, provider, ref) {
          final tabBarController = DefaultTabController.of(context);
          tabBarController.addListener((){
            provider.onPageChanged(tabBarController.index);
          });
          return HomeScreen();
        },
        dispose: (context){
          if(homeScreenListener != null){
            homeScreenListener!.cancel();

          }
        },
        resizeToAvoidBottomInset: false,

          floatingActionButton: BaseStatelessConsumer(
              provider: homeProvider,
              builder: (context, provider, ref) {
                return SafeArea(
                  child: Container(

                    decoration: BoxDecoration(
                      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                          Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: TabBar(
                      padding: EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Theme.of(context).hintColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.color
                          ?.withOpacity(0.5),
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
                      tabs: [
                        Tab(
                          height: MediaQuery.of(context).size.height*0.08,
                          icon: Icon(Icons.home),
                          child: Center(
                            child: Text(
                              "Home",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Tab(
                          height: MediaQuery.of(context).size.height*0.08,
                          icon: Icon(Icons.list_alt),
                          child: Center(
                            child: Text(
                              "Project List",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Tab(
                          height: MediaQuery.of(context).size.height*0.08,
                          icon: Icon(Icons.track_changes),
                          child: Center(
                            child: Text(
                              "Service Tracker",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Tab(
                          height: MediaQuery.of(context).size.height*0.08,
                          icon: Icon(Icons.folder),
                          child: Center(
                            child: Text(
                              "DCC",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),



        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        initState: (context, provider, ref) async {
          provider.initValues(initialIndex: widget.initialIndex);
          provider.initModuleList(ticker: this,loginProvider:ref.watch(loginProvider));
          setupNotificationHandlers();
          onMessageReceivedListener(
            onListenerInvoke: (){
              ref.watch(projectDashboardProvider).initValue();
              ref.read(callTrackerProvider).refreshWithFilters();
            }
          );
          if(Platform.isIOS){
              FirebaseMessaging.instance.requestPermission(
                alert: true,
                badge: true,
                sound: true,
              );

              FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
                alert: true,
                badge: true,
                sound: true,
              );

          }else{
            await FirebaseNotificationHelper.requestNotificationPermission();
          }

        },
        provider: homeProvider,
      ),
    );

  }



}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*1.1,
      child: Column(
        children: [
          Expanded(
              flex: 10,
              child: MainHomeWidget()),
          // Add bottom padding to prevent content from being hidden behind FAB

        ],
      ),
    );
  }
}