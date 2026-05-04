import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interior_design/presentation/view/dashboard/partials/status_colors.dart';
import 'package:interior_design/presentation/view/dashboard/partials/summary_pie_chart.dart';
import 'package:go_router/go_router.dart';
import 'detail_bar_chart.dart';
import 'package:interior_design/utils/routes.dart';

class DashboardDetailChart extends StatelessWidget {
  const DashboardDetailChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<DashBoardProvider>(
        provider: dashBoardProvider,
        builder: (context, provider, ref) {
          return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                elevation: 0.5,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          provider.currentTabIndex == 0
                              ? Expanded(
                            child: Text(
                              "Observation",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                            ),
                          ):
                          Expanded(
                            child: Text(
                              provider.isCritical
                                  ? "Support Requests Critical"
                                  : "${provider.dashBoardTabs[provider.currentTabIndex]}",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color:
                                    Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: BoxBorder.all(
                                        color: bayaInfraDisabledColor,
                                        width: 0.5)),
                                child: IconButton(
                                    onPressed: () {
                                      GoRouter.of(context).go(
                                        AppRoutes.dashBoardList,
                                        extra: {
                                          "projectId": provider.projectId,
                                          "isFromObs": provider.currentTabIndex == 0,
                                          "isFromSupport": provider.currentTabIndex == 1,
                                          "currentTabIndex": provider.currentTabIndex,
                                          "isCritical": provider.isCritical,
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.article_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))),
                          )
                        ],
                      ),
                     SizedBox(height: 8,),
                     DetailBarChart(),
                      StatusLegend(isSummary: false,),
                    ],
                  ),
                ),
              ));
        });
  }
}
