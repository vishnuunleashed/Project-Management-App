import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';

class PredecessorCard extends StatelessWidget {
  final String taskTypeHeader;
  final String taskName;
  final String remainingDays;
  final String profilePicture;
  final String userName;
  final String? dependencytype;
  final String? taskStatus;
  final String? statusName;
  final int taskId;
  final int? statusId;
  final int index;
  final int totalItems;
  final void Function()? onTap;
  final void Function()? onTapPredecessorForward;
  final void Function()? onTapPredecessorBackward;

  const PredecessorCard({
    super.key,
    required this.taskTypeHeader,
    required this.taskName,
    required this.remainingDays,
    required this.profilePicture,
    required this.userName,
    this.dependencytype,
    this.taskStatus,
    this.statusName,
    required this.taskId,
    this.statusId,
    required this.index,
    required this.totalItems,
    this.onTap,
    this.onTapPredecessorForward,
    this.onTapPredecessorBackward
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
        return Colors.white;
    }
  }


  IconData getStatusIcon(int? statusId) {
    switch (statusId) {
      case 46: // Completed
        return Icons.check_circle;
      case 45: // Hold
        return Icons.pause_circle_filled;
      case 44: // In Progress
        return Icons.play_circle_fill;
      case 43: // Pending
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
      builder: (context, provider, ref) => GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0.5,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              width: 0.5,
              color: Theme.of(context).cardColor,
            ),
          ),

          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(

              children: [
                if (index > 0)
                  Center(
                    child: GestureDetector(
                      onTap: onTapPredecessorBackward,
                      child: Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(0),
                            right: Radius.circular(100), // <-- semi-circle
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_left,
                            size: 18,
                            color: Colors.blue.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with task type
                          Row(
                            spacing: 5,
                            children: [
                              Icon(
                                CupertinoIcons.link,
                                size: 16,
                                color: textTheme.bodyMedium?.color,
                              ),
                              Text(
                                taskTypeHeader,
                                maxLines: 2,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 4,),
                          // Task name
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.7,
                              child: Text(
                                taskName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),

                          SizedBox(height: 4),
                          // Bottom row with all info
                          Row(
                            children: [
                              Row(
                                spacing: 5,
                                children: [
                                  Text(
                                    "Task id :",
                                    maxLines: 1,
                                    style: textTheme.labelLarge,
                                  ),
                                  Text(
                                    taskId.toString(),
                                    maxLines: 1,
                                    style: textTheme.labelLarge,
                                  ),
                                ],
                              ),

                              const SizedBox(width: 4),
                              // Dependency type
                              if (dependencytype != null) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dependencytype!,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),

                              ],


                              Builder(
                                builder: (context) {
                                  final config = _taskConfig(taskStatus??"");
                                  return Visibility(
                                    visible: taskStatus != "",
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 4),
                                          Icon(
                                            config['icon'],
                                            color: config['color'],
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            taskStatus??"",
                                            style: Theme.of(context).textTheme.labelLarge,
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
                        top: 0,
                        right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                ProfileImageDialog.show(context: context,
                                  imageUrl: profilePicture,
                                  userName:  userName,);

                              },
                              child:CachedNetworkImageWidget(
                                imageUrl: profilePicture,
                                userName: userName,
                                size: 50,
                              ),
                            ),

                            Text(
                              userName,
                              style: textTheme.labelLarge?.copyWith(
                                fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Next item indicator (right side)
                !(index < totalItems - 1)
                    ?SizedBox(
                        width: 20,
                        height: 40,)
                    :
                  Center(
                    child: GestureDetector(
                       onTap: onTapPredecessorForward,
                      child: Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(100),  // <-- Makes semi-circle
                            right: Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:  Center(
                          child: Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.blue.withValues(alpha: 0.8),
                          ),
                        ),
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

