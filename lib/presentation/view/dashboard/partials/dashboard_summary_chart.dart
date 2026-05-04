import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interior_design/presentation/view/dashboard/partials/status_colors.dart';
import 'package:interior_design/presentation/view/dashboard/partials/summary_pie_chart.dart';
import 'package:interior_design/presentation/view/dashboard/partials/dashboard_shared_widgets.dart';

class DashboardSummaryChart extends StatelessWidget {
  const DashboardSummaryChart({super.key});

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
                      provider.currentTabIndex == 0
                          ? Text(
                             "Observation Status",
                          style: Theme.of(context).textTheme.titleLarge,
                          )
                          : Text(
                        '${provider.isCritical
                            ? "Support Requests Critical"
                            : provider.dashBoardTabs[provider.currentTabIndex]} Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8,),
                      SizedBox(height: 12,),
                      SummaryPieChartWidget(),
                      SizedBox(height: 30,),
                      StatusLegend(),
                    ],
                  ),
                ),
      ));
        });
  }
}
