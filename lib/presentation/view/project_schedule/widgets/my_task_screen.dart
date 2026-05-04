import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:intl/intl.dart';

class MyTaskScreen extends StatelessWidget {
  final String name;
  final String? taskStatus;
  final String taskId;
  final String? color;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final bool hasAttachments;
  final int? duration;
  final int? percentComplete;
  final String? plannedStart;
  final String? plannedFinish;
  final String? actualStart;
  final String? actualFinish;
  final String? status;
  final String? predecessorTaskIds;
  final String? taskMasterName;

  const MyTaskScreen({
    super.key,
    required this.name,
    required this.taskId,
    this.color,
    this.onLongPressStart,
    this.onTap,
    this.status,
    this.duration,
    this.actualFinish,
    this.actualStart,
    this.hasAttachments = false,
    this.percentComplete,
    this.plannedFinish,
    this.plannedStart,
    this.predecessorTaskIds,
    this.taskMasterName,
    this.taskStatus,
  });

  Color parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.transparent;
    }
    colorString = colorString.replaceAll('#', '');
    if (colorString.length == 6) {
      colorString = 'FF$colorString';
    }
    return Color(int.parse(colorString, radix: 16));
  }

  Widget infoRowIcon(IconData icon, String? value, BuildContext context) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "Attachments",
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Return appropriate icon & color
  Map<String, dynamic> _taskConfig(String type) {
    if(type.toLowerCase().contains("completed")){
      return {
        "icon": Icons.task_alt,
        "color": Colors.green,
      };
    }else if(type.toLowerCase().contains("hold")){
      return {
        "icon": Icons.pause_circle_filled,
        "color": Colors.orange,
      };
    }else if(type.toLowerCase().contains("progress")){
      return {
        "icon": Icons.autorenew,
        "color": Colors.blue,
      };
    }else{
      return {
        "icon": Icons.access_time,
        "color": Colors.grey,
      };
    }
    // switch (type) {
    //   case "Completed":
    //     return {
    //       "icon": Icons.check_circle,
    //       "color": Colors.green,
    //     };
    //   case "Hold":
    //     return {
    //       "icon": Icons.pause_circle_filled,
    //       "color": Colors.orange,
    //     };
    //   case "In progress":
    //     return {
    //       "icon": Icons.autorenew,
    //       "color": Colors.blue,
    //     };
    //   case "Pending":
    //   default:
    //     return {
    //       "icon": Icons.access_time,
    //       "color": Colors.grey,
    //     };
    // }
  }


  String formatShortDate(String? input) {
    if (input == null || input.isEmpty) return "";

    try {
      final date = DateTime.parse(input);
      final now = DateTime.now();

      // Only month + day → "Dec 26"
      final monthDay = DateFormat("MMM d").format(date);

      // Full → "2026 Dec 25"
      final full = DateFormat("yyyy MMM d").format(date);

      return date.year == now.year ? monthDay : full;
    } catch (e) {
      return input; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = (color != "" && color != null) ? parseColor(color) : Theme.of(context).iconTheme.color;


    return BaseStatelessConsumer<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        return GestureDetector(
          onLongPressStart: onLongPressStart,
          onTap: onTap,
          onLongPressEnd: (_) {
            provider.hideTaskTooltip();
          },
          child: Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Visibility(
                        visible: predecessorTaskIds != null && predecessorTaskIds!.isNotEmpty,
                        child: Expanded(
                          child: Row(
                            children: [
                              Text(
                                "Pred Task Ids : ",
                                style: theme.textTheme.labelMedium,
                              ),
                              Expanded(
                                child: Text(
                                  "$predecessorTaskIds",
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Task id : ",
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            taskId,
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [

                        Builder(
                          builder: (context) {
                            final config = _taskConfig(taskStatus??"");
                            return Icon(
                              config['icon'],
                              size: 20,
                              color: textColor,
                            );
                          }
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        children: [
                          Text("Time span : ",style: theme.textTheme.labelMedium,),
                          Text(
                            "${formatShortDate(plannedStart??"")} to ${formatShortDate(plannedFinish??"")}",
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
                            "${duration}D",
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
        );
      }
    );
  }
}