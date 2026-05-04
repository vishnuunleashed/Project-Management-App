import 'package:base/core/loader_value.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation_export.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/dashboard/dashboard_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/domain/usecase/dashboard/dashboard_usecase.dart';

class DashBoardProvider extends BaseProvider {
  List<String> dashBoardTabs = [];
  int currentTabIndex = 0;
  List<DashBoardDetail> dashBoardList = [];
  int projectId = 0;
  String userprofileurl = "";
  List<ProjectDetail> detailJson = [];
  PageController pageController = PageController();
 bool isInitialLoad = true;
  // Chart colors & labels
  final List<Color> chartColors = [
    Color(0xffFFE162),// Pending (Open)
    Color(0xffFF6464),// Delayed
    Color(0xff91C483), // Closed
  ];


  final List<String> chartLabels = [
    "Opened",
    "Delayed",
    "Closed",
  ];

  // Chart values
  List<double> chartValues = [];

  bool isFromSupport = false;

  initValues(int projectIdFromInit,bool isFromObs,Map<String, dynamic>? extra) {
    isInitialLoad = true;
    isCritical = extra!["isCritical"]??false;
    projectId = projectIdFromInit;
    dashBoardTabs = [];
    dashBoardTabs.add('Observation');
    dashBoardTabs.add('Support Requests');
    dashBoardList = [];
    currentTabIndex = isFromObs?0:1;
    fetchProjectDetails(projectId: projectId);
    fetchDashBoardData();
  }

  void setInitialPage() {
    pageController = PageController(initialPage: currentTabIndex);

  }

  void changeTab(int index) {
    if (currentTabIndex != index) {
      currentTabIndex = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      fetchDashBoardData();
      notifyListeners();
    }
  }

  double calculateChartHeight(int barCount) {
    return double.parse((30 * barCount).toString());
  }

  void setDashboardDetail(DashBoardDetail detail) {
    detailJson = detail.detailJson ?? [];
    notifyListeners();
  }

  bool get hasDetailData {
    if (dashBoardList.isEmpty) return false;

    final details = dashBoardList.first.detailJson ?? [];
    return details.any((d) {
      final delayed = d.counts?.delayed ?? 0;
      final pending = d.counts?.pending ?? 0;
      return delayed > 0 || pending > 0;
    });
  }

  bool  hasDetailOpenOrDelayData(String label) {
    if (dashBoardList.isEmpty) return false;

    final details = dashBoardList.first.detailJson ?? [];
    return details.any((d) {
      if(label == 'Pending'){
      final pending = d.counts?.pending ?? 0;
      return pending > 0;}
      else{
        final delayed = d.counts?.delayed ?? 0;
        return delayed > 0 ;
      }
    });
  }

  List<String> get labels => detailJson.map((e) => e.name ?? "").toList();
  List<String> get code => detailJson.map((e) => e.code ?? "").toList();

  List<double> get pending =>
      detailJson.map((e) => (e.counts?.pending ?? 0).toDouble()).toList();

  List<double> get delayed =>
      detailJson.map((e) => (e.counts?.delayed ?? 0).toDouble()).toList();

  bool isCritical = false;

  void toggleSupportType(int index) {
    isCritical = index == 1;
    notifyListeners();
    fetchDashBoardData();


  }


  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    DashboardUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result) {
          projectDetailList = result;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
    notifyListeners();
  }

  void fetchDashBoardData() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    DashboardUseCase().fetchDashBoardData(
      projectId: projectId,
      isCritical:isCritical,
      isSelectedSupportRequest:  currentTabIndex == 1,
      onRequestSuccess: (result) {
        dashBoardList = [];
        if (result.isNotEmpty) {
          final summaryList = result.first.summaryJson ?? [];
          final detailList = (result.first.detailJson ?? [])
              .where((detail) =>
          (detail.counts?.delayed ?? 0) != 0 ||
              (detail.counts?.pending ?? 0) != 0)
              .toList();

          final summaryTotal =
          summaryList.isNotEmpty ? (summaryList.first.totalCount ?? 0) : 0;

          if (summaryTotal == 0 && detailList.isEmpty) {
            chartValues = [0, 0, 0];
            detailJson = [];
          } else {
            dashBoardList = result;

            final summary = dashBoardList.first.summaryJson?.first;
            chartValues = [
              (summary?.pendingCount ?? 0).toDouble(),
              (summary?.delayedCount ?? 0).toDouble(),
              (summary?.closedCount ?? 0).toDouble(),
            ];
            detailJson = detailList;
          }
          isInitialLoad = false;
        } else {
          // no result at all
          chartValues = [0, 0, 0];
          detailJson = [];
          isInitialLoad = false;
        }

        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus:
            LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }


  /// Grouped bar chart data
  List<BarChartGroupData> getBarChartGroups() {
    return List.generate(detailJson.length, (i) {
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [

          if (pending[i] > 0)
            BarChartRodData(
              toY: pending[i],
              color: chartColors[0],
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
          if (delayed[i] > 0)
            BarChartRodData(
              toY: delayed[i],
              color: chartColors[1],
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
        ],
      );
    });
  }

  /// For chart scaling
  double getMaxY() {
    final groups = getBarChartGroups();
    double maxValue = 0.0;
    final rawMax = groups
        .expand((g) => g.barRods.map((r) => r.toY))
        .fold<double>(0, (p, e) => e > p ? e : p);
    maxValue = (rawMax.isFinite && rawMax > 0 ? rawMax : 1);
    return maxValue + maxValue / 5;
  }

// In DashBoardProvider

  List<String> getBarChartLabels() {
    if (dashBoardList.isEmpty || dashBoardList.first.detailJson == null)
      return [];
    return dashBoardList.first.detailJson!.map((e) => e.name ?? '').toList();
  }




}
