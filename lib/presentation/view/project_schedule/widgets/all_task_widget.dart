import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

import 'expand_collapse_button.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final int level;
  final void Function(int index, TaskModel task)? onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final bool isExpanded;
  final bool hasSubtasks;
  final int index;
  final bool isLeafNode;
  final bool isSecondLastNode;
  final String scheduleName;
  final bool isProjectLocked;
  final String projectName;
  final int projectId;


  const TaskItem({
    super.key,
    required this.task,
    required this.level,
    this.onTap,
    this.onLongPressStart,
    required this.isExpanded,
    required this.hasSubtasks,
    required this.isSecondLastNode,
    required this.isLeafNode,
    required this.scheduleName,
    required this.index,
    required this.projectName,
    required this.projectId,
    required this.isProjectLocked,

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

  Map<String, dynamic> _taskConfig(String? type) {
    if (type == null || type.isEmpty) {
      return {
        "icon": Icons.access_time,
        "color": Colors.grey,
      };
    }

    if (type.toLowerCase().contains("completed")) {
      return {
        "icon": Icons.task_alt,
        "color": Colors.green,
      };
    } else if (type.toLowerCase().contains("hold")) {
      return {
        "icon": Icons.pause_circle_filled,
        "color": Colors.orange,
      };
    } else if (type.toLowerCase().contains("progress")) {
      return {
        "icon": Icons.autorenew,
        "color": Colors.blue,
      };
    } else {
      return {
        "icon": Icons.access_time,
        "color": Colors.grey,
      };
    }
  }

  String formatShortDate(DateTime? date) {
    if (date == null) return "";

    final now = DateTime.now();

    final monthDay = DateFormat("MMM d").format(date);
    final full = DateFormat("yyyy MMM d").format(date);

    return date.year == now.year ? monthDay : full;
  }


  @override
  Widget build(BuildContext context) {
    final Color? textColor = parseColor(task.color,context);
    final theme = Theme.of(context);

    return BaseConsumer(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        return Column(
          children: [

            GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap!(index, task);
                }
              },
              onLongPressStart: (details) {
                // Add this check to show tooltip for current task
                if (task.statusText?.isNotEmpty ?? false) {
                  provider.showTaskTooltip(
                    context: context,
                    statusText: task.statusText!,
                    position: details.globalPosition,
                    size: const Size(0, 0),
                  );
                }
                // Also call the passed callback if it exists
                if (onLongPressStart != null) {
                  onLongPressStart!(details);
                }
              },
              onLongPressEnd: (_) {
                provider.hideTaskTooltip();
              },
              child: Card(
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    children: [
                      // Top row: Predecessor Task IDs and Task ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (task.predecessorTaskIds.isNotEmpty)
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "Pred Task Ids : ",
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${task.predecessorTaskIds}",
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Task id : ",
                                          style: theme.textTheme.labelMedium,
                                        ),
                                        Text(
                                          "${task.taskId   ?? ''}",
                                          style: theme.textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                             Spacer(),
                               Visibility(
                                        visible: index == 0 && level == 0 && scheduleName == "my_task",
                                        child: ExpandCollapseButton(
                                          onPressed: (){
                                            provider.toggleTreeExpansion(provider.myScheduleTasks);
                                    
                                          },
                                          isExpanded:provider.isTreeExpanded,
                                    
                                        ),
                                      )
                                  
                                
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Original row structure: indentation, expand icon, task icon, name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // SizedBox(width: level * 20.0),
                            if (hasSubtasks)
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                size: 20,
                                color: theme.iconTheme.color,
                              )
                            else
                              const SizedBox(width: 0),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                final config = _taskConfig(task.statusText);
                                return Icon(
                                  isLeafNode
                                      ? config['icon']
                                      : (isSecondLastNode
                                      ? Icons.list_alt_outlined
                                      : Icons.folder_outlined),
                                  size: 20,
                                  color: isLeafNode
                                      ? textColor
                                      : theme.textTheme.bodyLarge?.color,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.name ?? '',
                                style: theme.textTheme.labelLarge?.copyWith(
                                   color: isLeafNode
                                       ? textColor
                                       : theme.textTheme.labelLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom row: Time span and Duration (only for leaf nodes)
                      if (isLeafNode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Time span : ",
                                  style: theme.textTheme.labelMedium,
                                ),
                                Text(
                                  "${formatShortDate(task.plannedStart)} to ${formatShortDate(task.plannedFinish)}",
                                  maxLines: 2,
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Duration: ",
                                  style: theme.textTheme.labelMedium,
                                ),
                                Text(
                                  "${task.duration ?? 0}D",
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasSubtasks && isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Column(
                  children: [
                    for (int childIndex = 0; childIndex < task.children.length; childIndex++)
                      TaskItem(
                        task: task.children[childIndex],
                        index: childIndex,
                        scheduleName: scheduleName,
                        projectId: projectId,
                        projectName: projectName,
                        isProjectLocked: isProjectLocked,
                        onLongPressStart: (details) {
                          if (task.statusText?.isNotEmpty ?? false) {
                            provider.showTaskTooltip(
                              context: context,
                              statusText: task.children[childIndex].statusText!,
                              position: details.globalPosition,
                              size: const Size(0, 0),
                            );
                          }
                        },
                        onTap: (index, subtask) {
                          if (onTap != null) {
                            if (subtask.children.isEmpty) {

                                GoRouter.of(context).pushNamed(
                                  AppRoutes.taskDetail,
                                  extra: {
                                    "projectName": projectName,
                                    "projectId": projectId,
                                    "taskId": subtask.id,
                                    "tabName": "all_task",
                                    "isFromReporteeTask": false,
                                    "predecessorData": null,
                                    "isProjectLocked":isProjectLocked
                                  },
                                );

                            } else {
                              onTap!(index, subtask);
                            }
                          }
                        },
                        level: level + 1,
                        isExpanded: task.children[childIndex].isExpanded,
                        hasSubtasks: task.children[childIndex].children.isNotEmpty,
                        isLeafNode: task.children[childIndex].children.isEmpty,
                        isSecondLastNode: task.children[childIndex].children.isNotEmpty
                            ? false
                            : task.children[childIndex]
                            .children
                            .every((s) => s.children.isEmpty),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}