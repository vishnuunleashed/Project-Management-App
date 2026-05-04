import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/all_task_widget.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/project_schedule_selection_tab.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/reporting_to_card.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/search_bar_widget.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/summary_card_button.dart';
import 'package:interior_design/utils/routes.dart';



class ProjectSchedulePage extends ConsumerStatefulWidget {
  const ProjectSchedulePage({super.key});

  @override
  ConsumerState<ProjectSchedulePage> createState() => _ProjectSchedulePageState();
}

class _ProjectSchedulePageState extends ConsumerState<ProjectSchedulePage> with RouteAware{

  @override
  void didPopNext()  {
    Future.microtask(() async {
       var provider = ref.watch(projectScheduleProvider);
       if(provider.selectedTab == 0){
         provider.fetchProjectScheduleDataMyTask();
       }
       else if(provider.selectedTab == 1) {
         provider.fetchReportingToScheduleData();
       }else{
         provider.fetchProjectScheduleData();
       }
      },
    );
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
    return BaseView(
      provider: projectScheduleProvider,
      initState: (context, provider, ref) {
        provider.projectScheduleInitValues();
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;


        final currentPath = state.path;
        bool isFromMyTask = true;
        bool isForAllTask = false;
        if(extra != null
            && extra["route_path"] != null
            && extra["route_path"].toString().contains('projectScheduleMyTaskDirect')){
          isFromMyTask = true;

        }
        else if(extra != null
            && extra["route_path"] != null &&
            extra["route_path"].toString().contains("projectScheduleReporteeTaskDirect")
        ){
            isFromMyTask = false;
        }
        else if(extra != null
            && extra["route_path"] != null &&
            extra["route_path"].toString().contains("projectScheduleAllTaskDirect")){
          isForAllTask = true;
        }
        else if(currentPath == "projectScheduleAllTaskDirect"){
          isForAllTask = true;
        }
        provider.setParameter(extra,isFromMyTask,isForAllTask,ref);
        provider.setBaseConstantValues();



      },
      appBar: CustomAppBar(
        title: BaseStatelessConsumer<ProjectScheduleProvider>(
          provider: projectScheduleProvider,
          builder: (context, provider, ref) {
            return provider.isSearching
                    ? SearchBarWidget(provider: provider)
                    : const Text('My Schedule');
              },
            ),
        action: [
          BaseStatelessConsumer<ProjectScheduleProvider>
            (provider: projectScheduleProvider ,
            builder: (context,provider, ref){
              return IconButton(
                icon: Icon(provider.isSearching ? Icons.close : Icons.search,color: Theme.of(context).iconTheme.color,),
                onPressed: () => provider.toggleSearch(),
              );
            },
          ),
          SizedBox(width: 4,),
          Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: BaseStatelessConsumer<ProjectScheduleProvider>(
                provider: projectScheduleProvider,
              builder: (context, provider, ref) {
                return Visibility(
                  visible: provider.selectedTab == 0,
                  child: IconButton(
                    onPressed: () {
                      BaseBottomSheet.show(
                        showSlideLine: false,
                        context: context,
                        barrierDismissible: false,
                        enableDrag: false,
                        child: filterFormWidget(),
                      );
                    },
                    icon: Icon(Icons.filter_alt_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                    ),
                  ),
                );
              }
            ),
          )

        ],
      ),

      builder: (context, provider, ref) {

        provider.pageController = PageController();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Visibility(
              visible: provider.summaryHealth != null,
              child: ScheduleHealthCard(
                onTap:(){
                  GoRouter.of(context).goNamed(AppRoutes.scheduleSummaryScreen,);
                },
                statusColor: Color(provider.summaryHealth?.color??0xFF000000),
                title: "Schedule Health",
                message: provider.summaryHealth?.statusText??"",
              ),
            ),




            provider.projectDetailList.isEmpty
                ? SizedBox(height: 0,)
                : ProjectHeaderCard(
                projectName: provider.projectDetailList.first.projectName??"",
                endDate: provider.projectDetailList.first.endDate??DateTime.now(),
                locationName: provider.projectDetailList.first.location??""
            ),

            // Card(
            //   elevation: 2,
            //   color: Theme.of(context).cardColor,
            //   clipBehavior: Clip.antiAlias,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
            //     child: Row(
            //       children: [
            //         Text(
            //           "Schedule - All By Euclid ",
            //           style: Theme.of(context).textTheme.labelLarge?.copyWith(
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const ProjectScheduleSelectionTab(),

            Expanded(
              child: PageView(
                controller: provider.pageController,
                onPageChanged: provider.onPageChanged,
                children: [
                  // My Task Page
                  provider.searchStarted ?
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: provider.searchResultsOfMyTask.length,
                    itemBuilder: (context, index) {
                      final task =  provider.searchResultsOfMyTask[index];
                      return AllTaskSearchScreen(
                        name: task.name ?? "",
                        color: task.color,
                        onTap: (){

                            GoRouter.of(context).pushNamed(
                              AppRoutes.taskDetail,
                              extra: {
                                "projectName": provider.projectDetailList.first.projectName??"",
                                "projectId": provider.projectDetailList.first.projectId,
                                "taskId": task.id,
                                "tabName": "my_task",
                                "isFromReporteeTask": false,
                                "predecessorData": null,
                                "isProjectLocked":provider.isProjectLocked
                              },
                            );

                        },
                        onLongPressStart: (details){
                          if (task.statusText?.isNotEmpty ?? false) {
                            provider.showTaskTooltip(
                              context: context,
                              statusText: task.statusText!,
                              position: details.globalPosition,
                              size: const Size(0, 0),
                            );
                          }
                        },
                      );
                    },
                  )
                      : RefreshIndicator(
                          color:Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).highlightColor,
                          onRefresh: ()async{
                            provider.fetchProjectScheduleDataMyTask();
                          },
                          child: ((provider.myScheduleTasks.isEmpty||provider.projectDetailList.isEmpty)
                              && provider.loadingStatus.loader == Loader.success)
                        ? EmptyListView(emptyText: "There are no tasks assigned to you in this project schedule.",)
                         : provider.isTreeToggling
                          ? BaseLoadingView(
                              message: provider.loadingStatus.message,
                              progress: provider.loadingProgress,
                            )
                          :Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                                  itemCount: provider.myScheduleTasks.length,
                                                  itemBuilder: (context, index) {
                              final task =  provider.myScheduleTasks[index];

                              return TaskItem(
                                  index: index,
                                  task: task,
                                  scheduleName:"my_task",
                                  isProjectLocked: provider.isProjectLocked,
                                  projectName: provider.projectDetailList.first.projectName??"",
                                  projectId: provider.projectDetailList.first.projectId??0,
                                  isExpanded: provider.myScheduleTasks[index].isExpanded,
                                  hasSubtasks: task.children.isNotEmpty,
                                  isLeafNode:  task.children.isEmpty,
                                  isSecondLastNode: task.children.isNotEmpty
                                      ? false : task.children.every((s) => s.children.isEmpty),
                                  onLongPressStart: (details){
                                    if (task.statusText?.isNotEmpty ?? false) {
                                      provider.showTaskTooltip(
                                        context: context,
                                        statusText: task.statusText!,
                                        position: details.globalPosition, // 👈 use gesture position
                                        size: const Size(0, 0), // not needed anymore
                                      );
                                    }
                                  },
                                  onTap: (index,task){
                                    if (task.children.isEmpty) {

                                        GoRouter.of(context).pushNamed(
                                          AppRoutes.taskDetail,
                                          extra: {
                                            "projectName": provider.projectDetailList.first.projectName??"",
                                            "projectId": provider.projectDetailList.first.projectId,
                                            "taskId": task.id,
                                            "tabName": "my_task",
                                            "isFromReporteeTask": false,
                                            "predecessorData": null,
                                            "isProjectLocked":provider.isProjectLocked

                                          },
                                        );


                                    } else {
                                      provider.expandAndCollapseMyTask(task: task);
                                    }
                                  },
                                  level: 0
                              );
                                                  },
                                                ),
                            ),

                          ],
                        ),
                      ),
                  // RefreshIndicator(
                  //   color:Theme.of(context).primaryColor,
                  //   backgroundColor: Theme.of(context).highlightColor,
                  //   onRefresh : ()async{
                  //     provider.fetchProjectScheduleDataMyTask();
                  //   },
                  //   child: !provider.isProjectLocked || (provider.myTaskList.isEmpty && provider.loadingStatus.loader == Loader.success)
                  //       ? EmptyListView(emptyText: "There are no assigned tasks in this project schedule")
                  //   : ListView.builder(
                  //     padding: const EdgeInsets.symmetric(horizontal: 2),
                  //     itemCount: provider.searchStarted ? provider.searchResultsOfMyTask.length : provider.myTaskList.length,
                  //     itemBuilder: (context, index) {
                  //       final task = (provider.searchStarted) ? provider.searchResultsOfMyTask[index] : provider.myTaskList[index];
                  //       return MyTaskScreen(
                  //         name: task.name??"",
                  //         color: task.color,
                  //         taskStatus: task.status,
                  //         taskId: task.taskId.toString()??"",
                  //         actualFinish: task.actualFinish??"",
                  //         actualStart: task.actualStart??"",
                  //         taskMasterName: task.taskMasterName,
                  //         duration: task.duration,
                  //         plannedStart: task.plannedStart??"" ,
                  //         plannedFinish: task.plannedFinish??"",
                  //         percentComplete: task.percentComplete,
                  //         status: task.statusText,
                  //         predecessorTaskIds: task.predecessorTaskIds,
                  //         hasAttachments: task.hasAttachments??false,
                  //         onTap: () {
                  //
                  //           GoRouter.of(context).pushNamed(
                  //             AppRoutes.taskDetail,
                  //             extra: {
                  //               "projectName": ProviderScope
                  //                   .containerOf(context)
                  //                   .read(selectedProjectProvider)
                  //                   ?.projectName,
                  //               "taskId": task.id,
                  //               "tabName": "my_task",
                  //               "isFromReporteeTask": false,
                  //               "predecessorData": null
                  //             },
                  //           );
                  //         },
                  //         onLongPressStart: (details){
                  //           if (task.statusText?.isNotEmpty ?? false) {
                  //             provider.showTaskTooltip(
                  //               context: context,
                  //               statusText: task.statusText!,
                  //               position: details.globalPosition,
                  //               size: const Size(0, 0),
                  //             );
                  //           }
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                  // Reporting to Task Page
                  RefreshIndicator(
                    color:Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).highlightColor,
                    onRefresh: ()async{
                      provider.fetchReportingToScheduleData();
                    },
                    child: (provider.reportingToTaskList.isEmpty && provider.loadingStatus.loader == Loader.success)
                        ? EmptyListView(emptyText: "There are no reporting tasks assigned in this project schedule.",)
                    :Column(
                        children: [
                        Expanded(
                        child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        itemCount: provider.reportingToTaskList.length,
                        itemBuilder: (context, index) {
                        final task =  provider.reportingToTaskList[index];
                        return  TaskItem(
                            index: index,
                            task: task,
                            scheduleName:"reportees_task",
                            isProjectLocked: provider.isProjectLocked,
                            projectName: provider.projectDetailList.first.projectName??"",
                            projectId: provider.projectDetailList.first.projectId??0,
                            isExpanded: provider.reportingToTaskList[index].isExpanded,
                            hasSubtasks: task.children.isNotEmpty,
                            isLeafNode:  task.children.isEmpty,
                            isSecondLastNode: task.children.isNotEmpty
                                ? false : task.children.every((s) => s.children.isEmpty),
                            onLongPressStart: (details){
                              if (task.statusText?.isNotEmpty ?? false) {
                                provider.showTaskTooltip(
                                  context: context,
                                  statusText: task.statusText!,
                                  position: details.globalPosition, // 👈 use gesture position
                                  size: const Size(0, 0), // not needed anymore
                                );
                              }
                            },
                            onTap: (index,task){
                              if (task.children.isEmpty) {

                                GoRouter.of(context).pushNamed(
                                  AppRoutes.taskDetail,
                                  extra: {
                                    "projectName": provider.projectDetailList.first.projectName??"",
                                    "projectId": provider.projectDetailList.first.projectId,
                                    "taskId": task.id,
                                    "tabName": "my_task",
                                    "isFromReporteeTask": false,
                                    "predecessorData": null,
                                    "isProjectLocked":provider.isProjectLocked

                                  },
                                );


                              } else {
                                provider.expandAndCollapseMyTask(task: task);
                              }
                            },
                            level: 0
                        );
                      },
                    ),),],
                    ),
                  ),
                  provider.searchStarted ?
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: provider.searchResultOfAllTask.length,
                    itemBuilder: (context, index) {
                      final task =  provider.searchResultOfAllTask[index];
                      return AllTaskSearchScreen(
                        name: task.name ?? "",
                        color: task.color,
                        onTap: (){

                            GoRouter.of(context).pushNamed(
                              AppRoutes.taskDetail,
                              extra: {
                                "projectName": provider.projectDetailList.first.projectName??"",
                                "projectId": provider.projectDetailList.first.projectId,
                                "taskId": task.id,
                                "tabName": "all_task",
                                "isFromReporteeTask": false,
                                "predecessorData": null,
                                "isProjectLocked":provider.isProjectLocked
                              },
                            );

                        },
                        onLongPressStart: (details){
                          if (task.statusText?.isNotEmpty ?? false) {
                            provider.showTaskTooltip(
                              context: context,
                              statusText: task.statusText!,
                              position: details.globalPosition,
                              size: const Size(0, 0),
                            );
                          }
                        },
                      );
                    },
                  )
                      : RefreshIndicator(
                        color:Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).highlightColor,
                        onRefresh: ()async{
                          provider.fetchProjectScheduleData();
                        },
                        child: (provider.tasks.isEmpty
                        && provider.loadingStatus.loader == Loader.success)
                        ? EmptyListView(emptyText: "There are no tasks assigned in this project schedule.", )
                        : ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            itemCount: provider.tasks.length,
                                            itemBuilder: (context, index) {
                        final task =  provider.tasks[index];

                        return TaskItem(
                            index: index,
                            task: task,
                            scheduleName: "all_task",
                            isProjectLocked: provider.isProjectLocked,
                            projectName: provider.projectDetailList.first.projectName??"",
                            projectId: provider.projectDetailList.first.projectId??0,
                            isExpanded: provider.tasks[index].isExpanded,
                            hasSubtasks: task.children.isNotEmpty,
                            isLeafNode:  task.children.isEmpty,
                            isSecondLastNode: task.children.isNotEmpty
                                ? false : task.children.every((s) => s.children.isEmpty),
                            onLongPressStart: (details){
                              if (task.statusText?.isNotEmpty ?? false) {
                                provider.showTaskTooltip(
                                  context: context,
                                  statusText: task.statusText!,
                                  position: details.globalPosition, // 👈 use gesture position
                                  size: const Size(0, 0), // not needed anymore
                                );
                              }
                            },
                            onTap: (index,task){
                              if (task.children.isEmpty) {


                                  GoRouter.of(context).pushNamed(
                                    AppRoutes.taskDetail,
                                    extra: {
                                      "projectName": provider.projectDetailList.first.projectName??"",
                                      "projectId": provider.projectDetailList.first.projectId,
                                      "taskId": task.id,
                                      "tabName": "all_task",
                                      "isFromReporteeTask": false,
                                      "predecessorData": null,
                                      "isProjectLocked":provider.isProjectLocked
                                    },
                                  );


                              } else {
                                provider.expandAndCollapseTask(task: task);
                              }
                            },
                            level: 0
                        );
                                            },
                                          ),
                      ),
                ],
              ),
            ),


          ],
        );
      }
    );
  }

  Widget filterFormWidget() {
    return BaseStatelessConsumer(
        provider: projectScheduleProvider,
        builder: (context, provider, ref){
          return Form(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0,right: 8),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Center(
                              child: Text(
                                "Filter",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          onPressed: () {
                            GoRouter.of(context).pop();

                          },
                        ),
                      ],
                    ),
                    Divider(),

                    BaseDropDownButtonFormField<String>(
                      iconEnabledColor: Theme.of(context).colorScheme.primary,
                      fillColorNeeded: false,
                      label: "Status",
                      labelColor: Theme.of(context).textTheme.titleLarge?.color,
                      hintText: "Select status",
                      initialValue: provider.selectedFilter,
                      items: ['All', 'Delayed', 'On Track', "Total Pending"],
                      onChanged: (value) {
                        provider.changeRadioButtonStatus(value ?? "All");
                      },
                      builder: (value) {
                        return Text(value);
                      },
                    ),

                    Visibility(
                      visible: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Reportees Tasks",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: provider.reporteesTasksFlag,
                            onChanged: (val) {
                              provider.updateReporteeTasksStatus(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: BaseElevatedButton(
                                onPressed: () {
                                  provider.clearFilter();
                                },
                                text: 'Clear',
                                height: 40,
                                backgroundColor: bayaInfraDisabledColor,
                              )),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                              child: BaseElevatedButton(
                                height: 40,
                                onPressed: () {
                                  GoRouter.of(context).pop();
                                  provider.applyFilter();
                                },
                                text: 'Apply',
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}



class AllTaskSearchScreen extends StatelessWidget {
  final String name;
  final String? color;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;

  const AllTaskSearchScreen({
    super.key,
    required this.name,
    this.color,
    this.onLongPressStart,
    this.onTap,
  });

  Color? parseColor(String? colorString,BuildContext context) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).textTheme.bodyLarge?.color;
    }
    colorString = colorString.replaceAll('#', '');
    if (colorString.length == 6) {
      colorString = 'FF$colorString';
    }
    return Color(int.parse(colorString, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = parseColor(color,context);

    return BaseConsumer(
        provider: projectScheduleProvider,
        builder: (context,provider,ref) {
          return GestureDetector(
            onLongPressStart: onLongPressStart,
            onLongPressEnd: (_) {
              provider.hideTaskTooltip();
            },
            child: Card(
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    // placeholder for expand icon space
                    const SizedBox(width: 8),
                    Icon(
                      Icons.task_alt,
                      size: 20,
                      color: textColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: onTap,
                        child: Text(
                          name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


}
