import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/utility/orientation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';

class DetailBarChart extends StatefulWidget {
  const DetailBarChart({super.key});

  @override
  State<DetailBarChart> createState() => _DetailBarChartState();
}

class _DetailBarChartState extends State<DetailBarChart> {
  int? touchedGroupIndex;
  int? touchedRodIndex;

  AllObservationAndSupportStatus? _statusForRodIndex(
      int groupIndex,
      int rodIndex,
      DashBoardProvider provider,
      ) {
    final List<AllObservationAndSupportStatus> presentRods = [];

    if ((provider.pending[groupIndex]) > 0) {
      presentRods.add(AllObservationAndSupportStatus.opened);
    }
    if ((provider.delayed[groupIndex]) > 0) {
      presentRods.add(AllObservationAndSupportStatus.delayed);
    }

    if (rodIndex < presentRods.length) return presentRods[rodIndex];
    return null;
  }

  void _navigateFromBar(
      BuildContext context,
      DashBoardProvider provider,
      int groupIndex,
      AllObservationAndSupportStatus status,
      ) {
    final detail = provider.detailJson[groupIndex];

    if (provider.dashBoardTabs[provider.currentTabIndex] == 'Support Requests') {
      GoRouter.of(context).pushNamed(
        AppRoutes.allSupportRequestScreen,
        extra: {
          'bottomBarStatus': status,
          'projectId': provider.projectId,
          'isCritical': provider.isCritical,
          'userId': detail.userId,
          'userprofileurl': detail.userprofileurl,
          'raisedUser': detail.name,
        },
      );
    } else {
      GoRouter.of(context).pushNamed(
        AppRoutes.allObservationListScreen,
        extra: {
          'bottomBarStatus': status,
          'projectId': provider.projectId,
          'userId': detail.userId,
          'userprofileurl': detail.userprofileurl,
          'raisedUser': detail.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<DashBoardProvider>(
      provider: dashBoardProvider,
      builder: (context, provider, child) {
        final groups = provider.getBarChartGroups();
        final code = provider.code;

        if (groups.isEmpty) {
          return EmptyListView(
            emptyText: "No tasks found",

          );
        }

        final maxY = provider.getMaxY();
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;
        const double barHeight = 55;
        final double chartHeight = groups.length * barHeight;
        return SizedBox(
          height: chartHeight,
          child: RotatedBox(
            quarterTurns: 1, // rotated chart
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) {
                      // Get the color of the touched rod
                      if (touchedRodIndex != null &&
                          touchedRodIndex! < group.barRods.length) {
                        return group.barRods[touchedRodIndex!].color ?? Colors.black87;
                      }
                      return Colors.black87;
                    },
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final value = rod.toY.toStringAsFixed(0);
                      return BarTooltipItem(
                        value,
                        Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                    setState(() {
                      if (response != null &&
                          response.spot != null &&
                          event is! FlPanEndEvent &&
                          event is! FlPointerExitEvent) {
                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                        touchedRodIndex = response.spot!.touchedRodDataIndex;
                      } else {
                        touchedGroupIndex = null;
                        touchedRodIndex = null;
                      }
                    });

                    // Navigate on tap-up only
                    if (event is FlTapUpEvent && response?.spot != null) {
                      final groupIndex = response!.spot!.touchedBarGroupIndex;
                      final rodIndex = response.spot!.touchedRodDataIndex;

                      // Pass groupIndex so we resolve rod → status correctly
                      final status = _statusForRodIndex(groupIndex, rodIndex, provider);
                      if (status == null) return;

                      _navigateFromBar(context, provider, groupIndex, status);
                    }
                  },
                ),

                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                barGroups: groups,
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                          reservedSize: 10,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox();
                        return Transform.rotate(
                          angle: -1.5708, // rotate 90 degrees CCW
                          child: Text(
                            textAlign: TextAlign.center,
                            value == meta.max ?'': value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),

                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= code.length) return const SizedBox();

                        return Center(
                          child: SizedBox(
                            height: 20,
                            width: 55,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -299,
                                  right: 0,
                                  bottom: 20,
                                  left: 0,
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Text(code[index],
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        );
      },
    );
  }
}
