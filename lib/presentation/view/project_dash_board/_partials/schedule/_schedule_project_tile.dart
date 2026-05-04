
// Schedule Project Tile Widget
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/side_bar_provider.dart';
import 'package:interior_design/utils/routes.dart';

import '_schedule_sub_dashboard.dart';

class ScheduleProjectTile extends ConsumerStatefulWidget {
  final ScheduleProject project;
  final void Function() onTapTrackTasks;
  final void Function() onTapTotalPending;
  final void Function() onTapDelayedTasks;
  final void Function() onTapAllTasks;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const ScheduleProjectTile({
    super.key,
    required this.project,
    required this.onTapTrackTasks,
    required this.onTapDelayedTasks,
    required this.onTapAllTasks,
    required this.scaffoldKeyHome,
    required this.onTapTotalPending,
  });

  @override
  ConsumerState<ScheduleProjectTile> createState() =>
      _ScheduleProjectTileState();
}

class _ScheduleProjectTileState extends ConsumerState<ScheduleProjectTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go(AppRoutes.projectSchedule,
                              extra: {"projectId": widget.project.projectId});
                        },
                        child: Text(
                          widget.project.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        'Project schedule',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "All Tasks",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onTapAllTasks,
                  icon: Icon(
                    Icons.all_inclusive,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Row 1: Total Pending & On Track
          if (widget.project.totalPending > 0 || widget.project.totalTasksOpen > 0)
            Column(
              children: [
                Row(
                  children: [
                    if (widget.project.totalPending > 0)
                      Expanded(
                        child: _buildScheduleBox(
                          context,
                          'Total Pending',
                          '${widget.project.totalPending}',
                          new5, // Violet
                          onTap: widget.onTapTotalPending,
                          isLarge: true,
                        ),
                      ),
                    if (widget.project.totalPending > 0 && widget.project.totalTasksOpen > 0)
                      const SizedBox(width: 12),
                    if (widget.project.totalTasksOpen > 0)
                      Expanded(
                        child: _buildScheduleBox(
                          context,
                          'On Track',
                          '${widget.project.totalTasksOpen}',
                          new2, // Forest Green
                          onTap: widget.onTapTrackTasks,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),
                if (widget.project.delayedTasks > 0)
                  _buildScheduleBox(
                    context,
                    'Delayed',
                    '${widget.project.delayedTasks}',
                    bayaInfraRed, // bayaInfraRed
                    onTap: widget.onTapDelayedTasks,
                  ),
              ],
            ),



        ],
      ),
    );
  }

  Widget _buildScheduleBox(
    BuildContext context,
    String label,
    String value,
    Color textColor, {
    VoidCallback? onTap,
    bool isLarge = true,
  }) {
    if (value == '0' || value.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: isLarge ? 12 : 8),
        child: Column(
          children: [
            Text(
              value,
              style: (isLarge
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.headlineSmall)
                  ?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final String label;
  final TextStyle? labelStyle;
  final String value;
  final Color? valueColor;
  final void Function()? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isZero = value == '0' || value.isEmpty;

    return GestureDetector(
      onTap: isZero ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isZero
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : valueColor,
              ),

            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
