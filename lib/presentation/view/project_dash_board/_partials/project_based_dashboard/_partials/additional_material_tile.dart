// Material Project Tile Widget
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/side_bar_provider.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/schedule/_schedule_sub_dashboard.dart';

import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/utils/routes.dart';

// New Models for Additional Cards
class MaterialProject {
  final int projectId;
  final String projectName;
  final int approvalPending;
  final int poUpdate;
  final int received;
  final int exceededReceived;
  final int sendBackCount;
  final int total;

  MaterialProject({
    required this.projectId,
    required this.projectName,
    required this.approvalPending,
    required this.poUpdate,
    required this.received,
    required this.exceededReceived,
    required this.sendBackCount,
    required this.total,
    this.isExpandedOpen = false,
    this.isExpandedDelayed = false,
  });

  bool isExpandedOpen;
  bool isExpandedDelayed;

  MaterialProject copyWith({
    int? projectId,
    String? projectName,
    int? approvalPending,
    int? poUpdate,
    int? received,
    int? exceededReceived,
    int? sendBackCount,
    int? total,
    bool? isExpandedOpen,
    bool? isExpandedDelayed,
  }) {
    return MaterialProject(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      approvalPending: approvalPending ?? this.approvalPending,
      poUpdate: poUpdate ?? this.poUpdate,
      received: received ?? this.received,
      exceededReceived: exceededReceived ?? this.exceededReceived,
      sendBackCount: sendBackCount ?? this.sendBackCount,
      total: total ?? this.total,
      isExpandedOpen: isExpandedOpen ?? this.isExpandedOpen,
      isExpandedDelayed: isExpandedDelayed ?? this.isExpandedDelayed,
    );
  }

  int get subtotal =>
      approvalPending + poUpdate + received + exceededReceived + sendBackCount;
}

class MaterialProjectTile extends ConsumerStatefulWidget {
  final MaterialProject project;
  final void Function() onTapApprovalPending;
  final void Function() onTapSendBack;
  final void Function() onTapReceived;
  final void Function() onTapPoPending;
  final void Function() onTapExceededReceived;
  final void Function() onTapAll;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  final VoidCallback onPressedAdd;
  final String toolTipAdd;

  const MaterialProjectTile({
    super.key,
    required this.project,
    required this.onTapApprovalPending,
    required this.onTapSendBack,
    required this.onTapReceived,
    required this.onTapExceededReceived,
    required this.onTapAll,
    required this.scaffoldKeyHome,
    required this.onPressedAdd,
    required this.onTapPoPending,
    required this.toolTipAdd,
  });

  @override
  ConsumerState<MaterialProjectTile> createState() =>
      _MaterialProjectTileState();
}

class _MaterialProjectTileState extends ConsumerState<MaterialProjectTile> {
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
                          GoRouter.of(context).go(AppRoutes.projectDetails,
                              extra: {"projectId": widget.project.projectId});
                        },
                        child: Text(
                          widget.project.projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        'Additional material',
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
                      visible: (ref.watch(projectDashboardProvider).isSuperUser ||
                          ref.watch(projectDashboardProvider).isProjectDepartment),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: widget.toolTipAdd,
                        onPressed: widget.onPressedAdd,
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "All",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onTapAll,
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
          const SizedBox(height: 4),
          if (widget.project.approvalPending > 0)
            Column(
              children: [
                GestureDetector(
                  onTap: widget.onTapApprovalPending,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: new4.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          '${widget.project.approvalPending}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: new4, // new4 - Terracotta
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Approval Pending',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: new4,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (widget.project.poUpdate > 0 || widget.project.sendBackCount > 0)
            Column(
              children: [
                Row(
                  children: [
                    if (widget.project.poUpdate > 0)
                      Expanded(
                        child: _buildMaterialBox(
                          context,
                          'PO pending',
                          '${widget.project.poUpdate}',
                          new1, // Sky Blue
                          onTap: widget.onTapPoPending,
                        ),
                      ),
                    if (widget.project.poUpdate > 0 && widget.project.sendBackCount > 0)
                      const SizedBox(width: 12),
                    if (widget.project.sendBackCount > 0)
                      Expanded(
                        child: _buildMaterialBox(
                          context,
                          'Send Back',
                          '${widget.project.sendBackCount}',
                          bayaInfraRed, // bayaInfraRed
                          onTap: widget.onTapSendBack,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (widget.project.received > 0 || widget.project.exceededReceived > 0)
            Row(
              children: [
                if (widget.project.received > 0)
                  Expanded(
                    child: _buildMaterialBox(
                      context,
                      'Receipt Pending',
                      '${widget.project.received}',
                      new2, // Forest Green
                      onTap: widget.onTapReceived,
                    ),
                  ),
                if (widget.project.received > 0 && widget.project.exceededReceived > 0)
                  const SizedBox(width: 12),
                if (widget.project.exceededReceived > 0)
                  Expanded(
                    child: _buildMaterialBox(
                      context,
                      'Receipt Delayed',
                      '${widget.project.exceededReceived}',
                      new5, // Violet
                      onTap: widget.onTapExceededReceived,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialBox(
    BuildContext context,
    String label,
    String value,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    if (value == '0' || value.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isZero
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : valueColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.2,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
