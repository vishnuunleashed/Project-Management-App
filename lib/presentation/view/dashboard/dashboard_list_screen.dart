import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';

import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/utils/routes.dart';

class DashboardListScreen extends ConsumerStatefulWidget {
  const DashboardListScreen({super.key});

  @override
  ConsumerState<DashboardListScreen> createState() => _DashboardListScreenState();
}

class _DashboardListScreenState extends ConsumerState<DashboardListScreen> with RouteAware{

  @override
  void didPopNext()  {
    Future.microtask(() async {
      var provider = ref.watch(dashBoardProvider);
      provider.fetchDashBoardData();
    });
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardProvider>(
      initState: (context,provider,ref){
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?["projectId"] ?? 0;
        provider.initValues(projectId,extra?["isFromObs"] != null &&extra?["isFromObs"] == true,extra);
      },

      provider: dashBoardProvider,
      appBar: CustomAppBar(
        title: const Text("Summary Analytics"),
      ),
      floatingActionButton:ExpandableFab(
          distance: 70, bottomPadding: 10),
      builder: (context, provider, ref) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(4),
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              border: Border.all(width: 0.5, color: bayaInfraGreyColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "${provider.dashBoardTabs[provider.currentTabIndex]} Summary Overview",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge?.copyWith(
                        fontSize: 16.5
                      ),
                    ),
                  ),

                  Divider(),
                  // Loop through detailJson
                  ...provider.detailJson.map((detail) {
                    return ((detail.counts?.delayed ?? 0) == 0 &&
                            (detail.counts?.pending ?? 0) == 0)
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section header (ex: DESIGN)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    detail.name ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                  ),
                                ),
                                GestureDetector(
                                    onTap: (){
                                      if(provider.dashBoardTabs[provider.currentTabIndex] == 'Support Requests') {
                                        GoRouter.of(context).pushNamed(AppRoutes.allSupportRequestScreen,
                                          extra: {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.delayed,
                                            'projectId' : provider.projectId,
                                            'userId' : detail.userId,
                                            'isCritical': provider.isCritical,
                                            'userprofileurl' : detail.userprofileurl,
                                            'raisedUser' : detail.name},
                                        );
                                      }else{
                                        GoRouter.of(context).pushNamed(AppRoutes.allObservationListScreen,
                                          extra: {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.delayed,
                                            'projectId' : provider.projectId,
                                            'userId' : detail.userId,
                                            'userprofileurl' : detail.userprofileurl,
                                            'raisedUser' : detail.name},
                                        );
                                      }

                                    },
                                    child: StatusRow(
                                      label: "Delayed",
                                      value: detail.counts!.delayed!,
                                      color: provider.chartColors[1],
                                    ),
                                  ),


                                // Show only Open if > 0

                                GestureDetector(
                                  onTap: (){
                                    if(provider.dashBoardTabs[provider.currentTabIndex] == 'Support Requests') {
                                      GoRouter.of(context).pushNamed(AppRoutes.allSupportRequestScreen,
                                        extra: {
                                          'bottomBarStatus' : AllObservationAndSupportStatus.opened,
                                          'projectId' : provider.projectId,
                                          'userId' : detail.userId,
                                          'isCritical': provider.isCritical,
                                          'userprofileurl' : detail.userprofileurl,
                                          'raisedUser' : detail.name},
                                      );
                                    }else{
                                      GoRouter.of(context).pushNamed(AppRoutes.allObservationListScreen,
                                        extra : {
                                          'bottomBarStatus' : AllObservationAndSupportStatus.opened,
                                          'projectId' : provider.projectId,
                                          'userId' : detail.userId,
                                          'userprofileurl' : detail.userprofileurl,
                                        'raisedUser' : detail.name},
                                      );
                                    }

                                  },
                                  child: StatusRow(
                                    label: "Opened",
                                    value: detail.counts!.pending!,
                                    color: provider.chartColors[0],
                                  ),
                                ),
                              ],
                            ),
                          );
                  }).toList(),
                  SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatusRow({super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: label == 'Delayed'
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withValues(alpha: .2),
              width: label == 'Delayed' ? 1 : 0.5),
          bottom: label != 'Delayed'
              ? BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: .2))
              : BorderSide.none,
          left: BorderSide(color: color, width: 10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(
              label == 'Delayed'
                  ? Icons.access_time_outlined
                  : Icons.menu_open_outlined,
              size: 18,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            Text(value.toString(),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall)
          ],
        ),
      ),
    );
  }
}
