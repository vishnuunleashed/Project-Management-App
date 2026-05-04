import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_model.dart';
import 'package:interior_design/data/model/response/project_schedule/color_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_group_activity_provider.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';
import 'package:interior_design/utils/routes.dart';

class ActivityGroupDashboardScreen extends StatelessWidget {


  const ActivityGroupDashboardScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectScheduleGroupActivityProvider>(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValues(extra);
      },
      provider: projectScheduleGroupActivityProvider,
      appBar: CustomAppBar(
        title: const Text('Activity Group Health'),
        shadowNeeded: true,
      ),
      builder: (context, provider, ref) {
        if (provider.loadingStatus.loader == Loader.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.loadingStatus.loader == Loader.error) {
          return Center(child: Text('Error: ${provider.loadingStatus.exception?.message}'));
        }

        final groups = provider.activityGroupList;

        if (groups.isEmpty) {
          return const Center(child: EmptyListView(emptyText: 'No activity groups found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _ActivityGroupCard(group: groups[index]);
          },
        );
      },
    );
  }
}

class _ActivityGroupCard extends StatefulWidget {
  final ActivityGroup group;

  const _ActivityGroupCard({required this.group});

  @override
  State<_ActivityGroupCard> createState() => _ActivityGroupCardState();
}

class _ActivityGroupCardState extends State<_ActivityGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final group = widget.group;
    final statusColor = _parseColor(group.statusColor) ?? theme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${group.activityGroupCode ?? ""} - ${group.activityGroupName ?? ""}',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [


                        _buildSmallScorePie(group.score ?? 0, statusColor),
                        _buildStatusBadge(group.status ?? "", statusColor),

                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          // Expanded Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.dashboard_customize_outlined, 'Tasks Summary', Colors.blue),
                  const SizedBox(height: 12),
                  _buildTasksSummaryGrid(group,context),
                  if (group.reasons.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader(Icons.info_outline, 'Reasons', Colors.blue),
                    const SizedBox(height: 8),
                    ...group.reasons.map((reason) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(reason, style: textTheme.bodySmall)),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }







  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
        ),
      ],
    );
  }

  Widget _buildSmallScorePie(double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score: ${score.toStringAsFixed(score % 1 == 0 ? 0 : 2)}',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 2,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _parseColorSummary(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;

    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';

    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildTasksSummaryGrid(ActivityGroup group,BuildContext context) {
    final provider = ProviderScope.containerOf(context).read(projectScheduleGroupActivityProvider);
    Map<String, StatusItem> colorMap  = {
      for (var item in provider.activitySummaryColor)
        item.name ?? '': item,
    };
    final Map<String, _MetricData> metrics = {
      'Total': _MetricData(
        group.totalTasks,
        _parseColorSummary(colorMap['Total']?.color, Colors.blue),
        Icons.list_alt,
        ProjectStatus.ALL,
      ),

      'Delayed': _MetricData(
        group.delayedTasks,
        _parseColorSummary(colorMap['Delayed']?.color, Colors.red),
        Icons.error_outline,
        ProjectStatus.Delayed,
      ),

      'Blocked': _MetricData(
        group.blockedTasks,
        _parseColorSummary(colorMap['Blocked']?.color, Colors.orange),
        Icons.block,
        ProjectStatus.Blocked,
      ),

      'Completed Late': _MetricData(
        group.completedLateTasks,
        _parseColorSummary(colorMap['CompletedLate']?.color, Colors.lightBlue),
        Icons.access_time,
        ProjectStatus.CompletedLate,
      ),

      'Causing Delay': _MetricData(
        group.causingDelayTasks,
        _parseColorSummary(colorMap['CausingDelay']?.color, Colors.redAccent),
        Icons.priority_high,
        ProjectStatus.CausingDelay,
      ),

      'Should Start': _MetricData(
        group.shouldHaveStartedTasks,
        _parseColorSummary(colorMap['ShouldStart']?.color, Colors.deepOrange),
        Icons.play_arrow_outlined,
        ProjectStatus.ShouldStart,
      ),

      'Behind Progress': _MetricData(
        group.behindScheduleTasks,
        _parseColorSummary(colorMap['BehindProgress']?.color, Colors.purple),
        Icons.trending_down,
        ProjectStatus.BehindProgress,
      ),
    };
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final entry = metrics.entries.elementAt(index);
        return _buildMetricBox(entry.key, entry.value, group.activityGroupId);
      },
    );
  }

  Widget _buildMetricBox(String label, _MetricData data, int? activityGroupId) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (data.value > 0) {
          GoRouter.of(context).pushNamed(
            AppRoutes.taskStatusPage,
            extra: {
              "ProjectStatus": data.status,
              "projectId": ProviderScope.containerOf(context).read(projectScheduleGroupActivityProvider).projectId,
              "activityGroupId": activityGroupId,
              "type": "Project",
            },
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: data.color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(data.icon, size: 18, color: data.color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${data.value} $label',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: data.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}

class _MetricData {
  final int value;
  final Color color;
  final IconData icon;
  final ProjectStatus status;

  _MetricData(this.value, this.color, this.icon, this.status);
}
