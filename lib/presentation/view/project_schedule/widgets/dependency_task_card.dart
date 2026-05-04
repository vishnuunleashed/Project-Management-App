import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';

class DependencyTaskCard extends StatelessWidget {
  final String taskTypeHeader;
  final String taskName;
  final String remainingDays;
  final String profilePicture;
  final String userName;
  final String? dependencytype;
  final String? statusName;
  final String? taskStatus;
  final int taskId;
  final int? statusId;
  final void Function()? onTap;
  const DependencyTaskCard({super.key,
    required this.taskTypeHeader,
    required this.taskName,
    required this.remainingDays,
    required this.profilePicture,
    required this.userName,
    this.dependencytype,
    this.statusName,
    this.taskStatus,
    required this.taskId,
    this.statusId,
    this.onTap
  });


  Color getStatusColor(int? statusId) {
    switch (statusId) {
      case 46: // Completed
        return Colors.green;
      case 45: // Hold
        return Colors.orange;
      case 44: // In Progress
        return const Color(0xFF00B8D4);
      case 43: // Pending
        return Colors.grey;
      default:
        return Colors.white; // fallback color
    }
  }


  IconData getStatusIcon(int? statusId) {
    switch (statusId) {
      case 1: // Completed
        return Icons.check_circle;
      case 2: // Hold
        return Icons.pause_circle_filled;
      case 3: // In Progress
        return Icons.play_circle_fill;
      case 4: // Pending
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return BaseConsumer(
      provider: projectScheduleProvider,
      builder:(context,provider,ref)=> GestureDetector(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          color: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Icon(CupertinoIcons.link,size: 16, color: Theme.of(context).textTheme.bodyMedium?.color,),

                        Text(
                          taskTypeHeader,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      ],
                    ),
                    const SizedBox(height: 15 ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Text(
                        taskName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            Text(
                              "Task id :",
                              maxLines: 1,
                              style: textTheme.titleSmall,
                            ),
                            Text(
                              taskId.toString(),
                              maxLines: 1,
                              style: textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Visibility(
                          visible: dependencytype != null,
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(dependencytype??"", style: textTheme.labelLarge?.copyWith(color: Colors.green)),
                            ],
                          ),
                        ),

                        Builder(
                            builder: (context) {
                              final config = _taskConfig(taskStatus??"");
                              return Visibility(
                                visible: taskStatus != "",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        config['icon'],
                                        color: config['color'],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        taskStatus??"",
                                          style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )


                      ],
                    ),


                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Visibility(
                    visible: userName != "",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImageWidget(
                          imageUrl: profilePicture,
                          userName: userName,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          size: 50,
                        ),
                        Text(
                          userName,
                          style: textTheme.labelLarge?.copyWith(
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Return appropriate icon & color
  Map<String, dynamic> _taskConfig(String type) {
    switch (type) {
      case "Completed":
        return {
          "icon": Icons.check_circle,
          "color": Colors.green,
        };
      case "Hold":
        return {
          "icon": Icons.pause_circle_filled,
          "color": Colors.orange,
        };
      case "In progress":
        return {
          "icon": Icons.autorenew,
          "color": Colors.blue,
        };
      case "Pending":
      default:
        return {
          "icon": Icons.access_time,
          "color": Colors.grey,
        };
    }
  }
}
