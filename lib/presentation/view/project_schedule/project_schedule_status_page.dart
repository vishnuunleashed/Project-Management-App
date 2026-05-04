import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_status_based_provider.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_page.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/all_task_widget.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/search_bar_widget.dart';
import 'package:interior_design/utils/routes.dart';

enum ProjectStatus {
  Completed,
  InProgress,
  NotStarted,
  OnTime,
  Delayed,
  CriticalPath,
  ALL,
  Blocked,
  CompletedLate,
  CausingDelay,
  ShouldStart,
  BehindProgress,
  Empty
}

class TaskStatusPage extends StatelessWidget {
  const TaskStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectTasksStatusBased>(
        initState: (context,provider,ref){
          Map<String,dynamic> extra = GoRouterState.of(context).extra as Map<String,dynamic>;
          provider.initSubLevel(extra);

        },
        provider: projectTasksStatusBased,
        appBar: CustomAppBar(
          shadowNeeded: true,
          title: BaseStatelessConsumer<ProjectTasksStatusBased>(
            provider: projectTasksStatusBased,
            builder: (context, provider, ref) {
              return provider.isSearching
                  ? SearchBarWidget(provider: provider)
                  : const Text('Task Status');
            },
          ),
          action: [
            BaseStatelessConsumer<ProjectTasksStatusBased>
              (provider: projectTasksStatusBased ,
              builder: (context,provider, ref){
                return IconButton(
                  icon: Icon(provider.isSearching ? Icons.close : Icons.search,color: Theme.of(context).iconTheme.color,),
                  onPressed: () => provider.toggleSearch(),
                );
              },)

          ],
        ),
        builder: (context,provider,ref){
          return provider.loadingStatus.loader == Loader.loading
              ? SizedBox(height: 0)
              : Column(
            children: [
              Expanded(
                child: provider.searchStarted ? provider.searchResultTaskStatusBased.isEmpty
                    ? EmptyListView(
                  emptyText: "No tasks found",

                ):
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: provider.searchResultTaskStatusBased.length,
                  itemBuilder: (context, index) {
                    final task =  provider.searchResultTaskStatusBased[index];
                    return AllTaskSearchScreen(
                      name: task.name ?? "",
                      color: task.color,
                      onTap: (){
                        context.pushNamed(
                          AppRoutes.taskDetail,
                          extra: {
                            "projectName":provider.projectDetailList.first.projectName,
                            "projectId": provider.projectDetailList.first.projectId,
                            "taskId": task.id,
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
                    : provider.taskStatusBased.isEmpty
                    ? EmptyListView(
                  emptyText: "No tasks found with selected status",

                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: provider.taskStatusBased.length,
                  itemBuilder: (context, index) {
                    final task =  provider.taskStatusBased[index];
                    return TaskItem(
                        index: index,
                        task: task,
                        scheduleName: "all_task",
                        isProjectLocked: provider.isProjectLocked,
                        projectName: provider.projectDetailList.first.projectName??"",
                        projectId: provider.projectDetailList.first.projectId??0,
                        isExpanded: provider.taskStatusBased[index].isExpanded,
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
                            if(provider.isProjectLocked) {
                              GoRouter.of(context).pushNamed(
                                AppRoutes.taskDetail,
                                extra: {
                                  "projectName": provider.projectDetailList.first.projectName,
                                  "projectId": provider.projectDetailList.first.projectId,
                                  "taskId": task.id,
                                  "tabName": "all_task",
                                  "isFromReporteeTask": false,
                                  "predecessorData": null,
                                  "isProjectLocked":provider.isProjectLocked
                                },
                              );
                            }
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

          );
        }
    );
  }
}
