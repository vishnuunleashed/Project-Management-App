import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/task_based_graph_provider.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_page.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/all_task_widget.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/search_bar_widget.dart';
import 'package:interior_design/utils/routes.dart';

enum GraphList {
  ProgressGraph,
  SupportGraph,
  DaysDelayGraph,
  UserDelayGraph,
  UserCompleteGraph,
  Empty
}

class TaskBasedGraphPage extends ConsumerStatefulWidget {
  const TaskBasedGraphPage({super.key});

  @override
  ConsumerState createState() => _TaskBasedGraphPageState();
}

class _TaskBasedGraphPageState extends ConsumerState<TaskBasedGraphPage> with RouteAware {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = ref.read(taskBasedGraphProvider);
    provider.saveScrollOffset(_scrollController.offset);
  }

  @override
  void didPopNext() {
    Future.microtask(() async {
      final provider = ref.read(taskBasedGraphProvider);
      await provider.fetchProjectScheduleDataGraphBased();

      // Restore scroll after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final offset = provider.getSavedScrollOffset();
        if (_scrollController.hasClients &&
            offset <= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(offset);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BaseView<TaskBasedGraphProvider>(
      initState: (context,provider,ref){
        Map<String,dynamic> extra = GoRouterState.of(context).extra as Map<String,dynamic>;
        provider.initSubLevel(extra);

      },
      provider: taskBasedGraphProvider,
      appBar: CustomAppBar(
        shadowNeeded: true,
        title: BaseStatelessConsumer<TaskBasedGraphProvider>(
          provider: taskBasedGraphProvider,
          builder: (context, provider, ref) {
            return provider.isSearching
                ? SearchBarWidget(provider: provider)
                : (provider.status ==GraphList.DaysDelayGraph)
                  ? Text(provider.label)
                  : (provider.status ==GraphList.ProgressGraph)
                      ?Text('Tasks ${provider.label}')
                      :(provider.status ==GraphList.UserDelayGraph)
                  ?(provider.userId == null || provider.userId == 0)
                    ?Text("Unassigned")
                    :Text('Tasks by ${provider.label}')
                :Text('Tasks by ${provider.label}');
          },
        ),
        action: [
          BaseStatelessConsumer<TaskBasedGraphProvider>
            (provider: taskBasedGraphProvider ,
            builder: (context,provider, ref){
              return IconButton(
                icon: Icon(provider.isSearching ? Icons.close : Icons.search,color: Theme.of(context).iconTheme.color,),
                onPressed: () => provider.toggleSearch(),
              );
            },)

        ],
      ),
      builder: (context,provider,ref){
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
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
                controller: _scrollController,
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
                          "projectName": provider.projectDetailList.first.projectName,
                          "projectId": provider.projectId,
                          "taskId": task.id,
                          "isFromReporteeTask": false,
                          "predecessorData": null,
                          "isProjectLocked": provider.isProjectLocked
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
                controller: _scrollController,
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
