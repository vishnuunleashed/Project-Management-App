import 'dart:math';

import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule_dashboard/project_schedule_dashboard_provider.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';
import 'package:interior_design/presentation/view/project_details/widgets/empty_place_holder_for_graph.dart';
import 'package:interior_design/utils/routes.dart';

import 'generalized_graph/general_pie_chart_widget.dart';
import 'generalized_graph/generalized_horizontal_graph.dart';



class ProjectScheduleDashBoardScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;
  final int? projectId;
  const ProjectScheduleDashBoardScreen({Key? key, this.hideAppBar = false, this.projectId}) : super(key: key);

  @override
  ConsumerState createState() => _ProjectScheduleDashBoardScreenState();
}

class _ProjectScheduleDashBoardScreenState extends ConsumerState<ProjectScheduleDashBoardScreen> with RouteAware {

  @override
  void didPopNext()  {
    Future.microtask(() async {
      var provider = ref.watch(projectScheduleDashBoardProvider);
      provider.fetchDashBoardWithGraph();
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
    final theme = Theme.of(context);

    return BaseView<ProjectScheduleDashBoardProvider>(
      provider: projectScheduleDashBoardProvider,
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.childInitState(extra: extra, projectId: widget.projectId);
      },
      backgroundColor: theme.scaffoldBackgroundColor,
        appBar: widget.hideAppBar ? null : CustomAppBar(
          title: Text("Project Schedule"),
        ),
      // appBar: AppBar(AppBar
      //   backgroundColor: theme.colorScheme.secondary,
      //   leading: Padding(
      //     padding: const EdgeInsets.only(left: 8.0),
      //     child: CircularBackButton(
      //       onTap: () async {
      //         GoRouter.of(context).pop();
      //       },
      //     ),
      //   ),
      //   title: const Text('Project Schedule'),
      //   titleTextStyle: theme.textTheme.bodyLarge!.copyWith(
      //     fontSize: 20,
      //   ),
      //
      // ),
      builder: (context, provider, ref) => provider.loadingStatus.loader == Loader.success
          && provider.allGraphsEmpty
          ? EmptyHorizontalBarPlaceholder()
          :  ListView(
      controller: provider.scrollController,
      physics: const ClampingScrollPhysics(),
      children: [
          _buildProgressGraph(provider),          // 1
          _buildSupportGraph(provider),           // 2
          _buildDaysDelayGraph(provider),         // 3
          _buildUserDelayGraph(provider),         // 4
          _buildUserCompleteGraph(provider),      // 5
          _buildManpowerGraph(provider),          // 6
        ],
      )
    );
  }

  Widget _buildProgressGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.projectProgressJson.isEmpty) return SizedBox.shrink();

    return GeneralPieChart(
      data: buildProjectProgressData(provider),
      onSectionTap: (data, index) {
        // Handle section tap
        print('Tapped section at index $index');
        print('Label: ${data['label']}');
        print('Value: ${data['value']}');
        print("data__ "+data.toString());
        print("index__ "+index.toString());
        GoRouter.of(context).pushNamed(AppRoutes.taskBasedGraphPage,
            extra: {
              "projectId":provider.projectId,
              "label": data["label"],
              "GraphList": GraphList.ProgressGraph
            });

      },

    );
  }

  Widget _buildSupportGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.supprtReqOverDelay.isEmpty) return SizedBox.shrink();

    return HorizontalBarChart(
      data: buildSupportRequiredData(provider),
      onBarTap: (data,index){
        print("data__ "+data.toString());
        print("index__ "+index.toString());

        GoRouter.of(context).pushNamed(AppRoutes.graphBasedSupportRequestScreen,
          extra: {
            'projectId' : provider.projectId,
            'label' : data["label"],
            'type' : data["supporttypecode"],
          },
        );
      },
    );
  }

  Widget _buildDaysDelayGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.delayTaskInDaysJson.isEmpty) return SizedBox.shrink();

    return HorizontalBarChart(
      data: buildDelayedTasksByDaysData(provider),
      onBarTap: (data,index){
        print("data__ "+data.toString());
        print("index__ "+index.toString());
        GoRouter.of(context).pushNamed(AppRoutes.taskBasedGraphPage,
            extra: {
              "projectId":provider.projectId,
              "label": data["label"],
              "delayCategory": data["delayCategory"],
              "GraphList": GraphList.DaysDelayGraph
            });
      },
    );
  }


  Widget _buildUserDelayGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.delayTaskUserJson.isEmpty) return SizedBox.shrink();

    return HorizontalBarChart(
      data: buildDelayTasksUserData(provider),
      onBarTap: (data,index){
        print("data__ "+data.toString());
        print("index__ "+index.toString());
        GoRouter.of(context).pushNamed(AppRoutes.taskBasedGraphPage,
            extra: {
              "projectId":provider.projectId,
              "userId": data["assigneduserid"],
              "label": data["label"],
              "GraphList": GraphList.UserDelayGraph
        });
      },
    );
  }

  Widget _buildUserCompleteGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.completeTaskUserJson.isEmpty) return SizedBox.shrink();

    return HorizontalBarChart(
      data: buildCompletedTasksUserData(provider),
      onBarTap: (data,index){
        print("data__ "+data.toString());
        print("index__ "+index.toString());
        GoRouter.of(context).pushNamed(AppRoutes.taskBasedGraphPage,
            extra: {
              "projectId":provider.projectId,
              "userId": data["assigneduserid"],
              "label": data["label"],
              "GraphList": GraphList.UserCompleteGraph

            });
      },

    );
  }
  Widget _buildManpowerGraph(ProjectScheduleDashBoardProvider provider) {
    if (provider.activityGroup.isEmpty) return SizedBox.shrink();

    return HorizontalBarChart(
      separationHeight: buildManpowerData(provider).length * 80,
      data: buildManpowerData(provider),
      valueKey: 'estimatedValue',
      secondValueKey: 'actualValue',
      colorKey: 'estimatedColor',
      secondColorKey: 'actualColor',
      firstLegendLabel: 'Estimated',
      secondLegendLabel: 'Actual',
      onBarTap: (data, index) {
        // Handle tap if needed
      },
    );
  }


  final List<Color> barColors = [
    Color(0xffFFE162),
    Color(0xffFF6464),
    Color(0xff91C483),

  ];

  final Map<String, Color> categoryColorMap = {
    'Pending':   const Color(0xFFFFE162),
    'Delayed':   const Color(0xFFFF6464),
    'Closed':    const Color(0xFF91C483),
    'Completed': const Color(0xFF91C483),
    'Task':      const Color(0xFFFFE162),
    'Support':   const Color(0xFFFF6464),
    'Future':    const Color(0xFF848484),
    'On track':  const Color(0xFF43A1C6),
  };

  Color getCategoryColor(String name) {
    return categoryColorMap[name] ?? Colors.grey; // fallback
  }





  List<Map<String, Object>> buildSupportRequiredData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];

    for (int i = 0; i < provider.supprtReqOverDelay.length; i++) {
      final e = provider.supprtReqOverDelay[i];
      final type = e.supporttypename ?? '';
      final supporttypecode = e.supporttypecode ?? '';
      if(e.supportcount != 0){
        data.add({
          'title': "Support Request Overcome Delay",
          'label': type,
          'supporttypecode': supporttypecode,
          'value': (e.supportcount ?? 0).toDouble(),
          'color': barColors[1],
        });
      }

    }

    return data;
  }
  List<Map<String, Object>> buildDelayedTasksByDaysData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];


    for (int i = 0; i < provider.delayTaskInDaysJson.length; i++) {
      final e = provider.delayTaskInDaysJson[i];
      final category = e.delaycategorycode ?? '';
      final categoryName = e.delayCategory ?? '';
      if(e.taskCount != 0){
        data.add({
          'title': "Delayed Tasks by Days",
          'label': categoryName,
          'delayCategory': category,
          'value': (e.taskCount ?? 0).toDouble(),
          'color': barColors[1],
        });
      }
    }

    return data;
  }

  List<Map<String, Object>> buildDelayTasksUserData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];

    for (int i = 0; i < provider.delayTaskUserJson.length; i++) {
      final e = provider.delayTaskUserJson[i];
      final assignedTo = e.assignedTo ?? '';
      final assigneduserid = e.assigneduserid ?? '';
      if(e.delayedTaskCount != 0){
        data.add({
          'title': "Delayed Tasks by Users",
          'label': assignedTo,
          'assigneduserid': assigneduserid,
          'value': (e.delayedTaskCount ?? 0).toDouble(),
          'color': barColors[1],
        });
      }
    }

    return data;
  }

  List<Map<String, Object>> buildCompletedTasksUserData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];

    for (int i = 0; i < provider.completeTaskUserJson.length; i++) {
      final e = provider.completeTaskUserJson[i];
      final assignedTo = e.assignedTo ?? '';
      String assigneduserid = e.assigneduserid ?? '';
      if(e.completeTaskCount != 0){
        data.add({
          'title': "Completed Tasks by Users",
          'label': assignedTo,
          'assigneduserid': assigneduserid,
          'value': (e.completeTaskCount ?? 0).toDouble(),
          'color': barColors[2],
        });
      }
    }

    return data;
  }
  List<Map<String, Object>> buildManpowerData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];

    for (int i = 0; i < provider.activityGroup.length; i++) {
      final e = provider.activityGroup[i];
      final label = e.code.isNotEmpty ? e.code : e.description ?? '';
      
      data.add({
        'title': "Manpower: Estimated vs Actual",
        'label': label,
        'estimatedValue': (e.estimatedlabourcount ?? 0).toDouble(),
        'actualValue': (e.actuallabourcount ?? 0).toDouble(),
        'estimatedColor': barColors[0], // Yellow
        'actualColor': const Color(0xFF43A1C6), // Blue
      });
    }

    return data;
  }

  List<Map<String, Object>> buildProjectProgressData(ProjectScheduleDashBoardProvider provider) {
    final data = <Map<String, Object>>[];

    for (int i = 0; i < provider.projectProgressJson.length; i++) {
      final e = provider.projectProgressJson[i];
      final progressCategory = e.progressCategory ?? '';
      if(e.taskCount != 0){
        data.add({
          'title': "Project Progress",
          'label': progressCategory,
          'value': (e.taskCount ?? 0).toDouble(),
          'color':  getCategoryColor(progressCategory),
        });
      }
    }

    return data;
  }




}

