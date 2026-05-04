                                                                                                                                                                                                                                                            // Project Tile Widget
// Project Tile Widget
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/expand_collapse_button.dart';
import 'package:interior_design/utils/routes.dart';

import '_project_sub_dashboard.dart';

class ProjectTile extends ConsumerStatefulWidget {
  final Project project;
  final VoidCallback onOpenTap;
  final VoidCallback onDelayedTap;
  final VoidCallback onAllTap;
  final VoidCallback onPressedAdd;
  final VoidCallback onLongPress;
  final String toolTipAdd;
  final String toolTipAll;
  final int index;
  final bool isObservation;
  final Function(String statusName, bool isDelayed)? onSubCountTap;

  const ProjectTile({
    super.key,
    required this.project,
    required this.onOpenTap,
    required this.onDelayedTap,
    required this.onAllTap,
    required this.onPressedAdd,
    required this.onLongPress,
    required this.toolTipAdd,
    required this.toolTipAll,
    required this.index,
    this.isObservation = true,
    this.onSubCountTap,
  });

  @override
  ConsumerState<ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends ConsumerState<ProjectTile> {


  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer(
      provider: projectDashboardProvider,
      builder: (context,provider,ref) {
        return GestureDetector(
          onLongPress: () {
            widget.onLongPress();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                            GoRouter.of(context).go(AppRoutes.projectDetails,
                                extra: {"projectId": widget.project.id});
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
                          widget.isObservation ? 'Observations' : 'Support requests',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: widget.isObservation
                            ?  ref.watch(homeProvider).addObservationRight
                            :  ref.watch(homeProvider).addSupportRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: widget.onPressedAdd,
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).iconTheme.color,
                            size: 20,
                          ),
                        ),
                      ),

                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onAllTap,
                        icon: Icon(
                          Icons.all_inclusive,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            Row(
              children: [
                if (widget.project.open > 0)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.isObservation) {
                          provider.toggleObsExpandedOpen(widget.index);
                        } else {
                          provider.toggleSupportExpandedOpen(widget.index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: new6.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.project.isExpandedOpen
                                ? new6
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text(
                              '${widget.project.open}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: new9,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Open',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: new9,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.project.open > 0 && widget.project.delayed > 0)
                  const SizedBox(width: 12),
                if (widget.project.delayed > 0)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.isObservation) {
                          provider.toggleObsExpandedDelayed(widget.index);
                        } else {
                          provider.toggleSupportExpandedDelayed(widget.index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: new7.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.project.isExpandedDelayed
                                ? new7
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text(
                              '${widget.project.delayed}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: new7,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Delayed',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: new7,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.project.isExpandedOpen || widget.project.isExpandedDelayed)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.project.isExpandedOpen
                              ? 'OPEN BREAKDOWN'
                              : 'DELAYED BREAKDOWN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.project.isExpandedOpen) {
                              if (widget.isObservation) {
                                provider.toggleObsExpandedOpen(widget.index);
                              } else {
                                provider.toggleSupportExpandedOpen(widget.index);
                              }
                            } else {
                              if (widget.isObservation) {
                                provider.toggleObsExpandedDelayed(widget.index);
                              } else {
                                provider.toggleSupportExpandedDelayed(widget.index);
                              }
                            }
                          },
                          child: const Icon(Icons.close, size: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.project.isExpandedOpen
                          ? (widget.isObservation
                              ? [
                                  _buildStatusChip("All", widget.project.open, context, onTap: () => widget.onOpenTap.call()),
                                  _buildStatusChip("Unassigned", widget.project.openUnassigned, context, onTap: () => widget.onSubCountTap?.call("UNASSIGNED", false)),
                                  _buildStatusChip("Assigned", widget.project.openAssigned, context, onTap: () => widget.onSubCountTap?.call("ASSIGNED", false)),
                                  _buildStatusChip("Submitted", widget.project.openSubmitted, context, onTap: () => widget.onSubCountTap?.call("SUBMIT", false)),
                                  _buildStatusChip("Rejected", widget.project.openRejected, context, onTap: () => widget.onSubCountTap?.call("REJECTED", false)),
                                ]
                              : [
                                  _buildStatusChip("All", widget.project.open, context, onTap: () => widget.onOpenTap.call()),
                                  _buildStatusChip("Assigned", widget.project.openAssigned, context, onTap: () => widget.onSubCountTap?.call("ASSIGNED", false)),
                                  _buildStatusChip("Forwarded", widget.project.openForwarded, context, onTap: () => widget.onSubCountTap?.call("FORWARD", false)),
                                  _buildStatusChip("Submit", widget.project.openSubmitted, context, onTap: () => widget.onSubCountTap?.call("SUBMIT", false)),
                                  _buildStatusChip("Reassigned", widget.project.openReassigned, context, onTap: () => widget.onSubCountTap?.call("REASSIGNED", false)),
                                ])
                          : (widget.isObservation
                              ? [
                                  _buildStatusChip("All", widget.project.delayed, context, onTap: () => widget.onDelayedTap.call(), isDelayed: true),
                                  _buildStatusChip("Unassigned", widget.project.delayedUnassigned, context, onTap: () => widget.onSubCountTap?.call("UNASSIGNED", true), isDelayed: true),
                                  _buildStatusChip("Assigned", widget.project.delayedAssigned, context, onTap: () => widget.onSubCountTap?.call("ASSIGNED", true), isDelayed: true),
                                  _buildStatusChip("Submitted", widget.project.delayedSubmitted, context, onTap: () => widget.onSubCountTap?.call("SUBMIT", true), isDelayed: true),
                                  _buildStatusChip("Rejected", widget.project.delayedRejected, context, onTap: () => widget.onSubCountTap?.call("REJECTED", true), isDelayed: true),
                                ]
                              : [
                                  _buildStatusChip("All", widget.project.delayed, context, onTap: () => widget.onDelayedTap.call(), isDelayed: true),
                                  _buildStatusChip("Assigned", widget.project.delayedAssigned, context, onTap: () => widget.onSubCountTap?.call("ASSIGNED", true), isDelayed: true),
                                  _buildStatusChip("Forwarded", widget.project.delayedForwarded, context, onTap: () => widget.onSubCountTap?.call("FORWARD", true), isDelayed: true),
                                  _buildStatusChip("Submitted", widget.project.delayedSubmitted, context, onTap: () => widget.onSubCountTap?.call("SUBMIT", true), isDelayed: true),
                                  _buildStatusChip("Reassigned", widget.project.delayedReassigned, context, onTap: () => widget.onSubCountTap?.call("REASSIGNED", true), isDelayed: true),
                                ]),
                    ),
                  ],
                ),
              ),
          ],
        )
          )
        );
      },
    );
  }

  Widget _buildStatusChip(String label, int count, BuildContext context,
      {bool isDelayed = false, VoidCallback? onTap}) {
    if (count == 0) return const SizedBox.shrink();
    final Color baseColor = isDelayed ? new7 : new6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: baseColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


