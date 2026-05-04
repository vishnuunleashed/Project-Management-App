import 'dart:convert';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/status_progress_bar.dart';
import 'package:interior_design/utils/routes.dart';



class ScheduleSummaryScreen extends StatefulWidget {
  const ScheduleSummaryScreen({super.key});

  @override
  State<ScheduleSummaryScreen> createState() => _ScheduleSummaryScreenState();
}

class _ScheduleSummaryScreenState extends State<ScheduleSummaryScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _datesKey = GlobalKey();
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _healthKey = GlobalKey();
  final GlobalKey _tasksKey = GlobalKey();
  
  String formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showNavigationMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              icon: Icons.calendar_today,
              title: 'Schedule Dates',
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_datesKey);
              },
            ),
            _buildMenuItem(
              icon: Icons.trending_up,
              title: 'Progress',
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_progressKey);
              },
            ),
            _buildMenuItem(
              icon: Icons.health_and_safety,
              title: 'Schedule Health',
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_healthKey);
              },
            ),
            _buildMenuItem(
              icon: Icons.task_alt,
              title: 'Tasks Summary',
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_tasksKey);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<ProjectScheduleProvider>(
      initState: (context,provider,ref){
        provider.fetchProjectScheduleSummaryData();
      },
      provider: projectScheduleProvider,
      appBar: CustomAppBar(
        title: Text(
          'Schedule Summary',
        ),
        shadowNeeded: true,

      ),
      builder: (context,provider,ref) {
        return provider.summaryData.isEmpty
            ? SizedBox(height: 0)
            : SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
        child: Column(
          children: [
            _buildScheduleDatesCard(provider),
            const SizedBox(height: 16),
            _buildProgressCard(provider),
            const SizedBox(height: 16),
            _buildScheduleHealthCard(provider),
            const SizedBox(height: 16),
            _buildTasksSummaryCard(provider,onTap: (){

            }),
            const SizedBox(height: 80),
          ],
        ),
      );
      },
      floatingActionButton: FloatingActionButton(
        onPressed: _showNavigationMenu,
        backgroundColor: theme.primaryColor,
        child: Icon(Icons.menu, color: theme.colorScheme.secondary),
      ),
    );
  }

  Widget _buildScheduleDatesCard(ProjectScheduleProvider provider) {
    final theme = Theme.of(context);

    return Card(
      key: _datesKey,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule Dates',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateRow(
              'Start :',
              formatDate(provider.summaryData.first.projectStart??DateTime.now()),
              bayaInfraBlue50!,
              bayaInfraBlue600!,
            ),
            const SizedBox(height: 8),
            _buildDateRow(
              'Planned Finish :',
              formatDate(provider.summaryData.first.projectFinish??DateTime.now()),
              bayaInfraLightGreenColor.withOpacity(0.3),
              bayaInfraGreen,
            ),
            const SizedBox(height: 8),
            _buildDateRow(
              'Forecast :',
              formatDate(provider.summaryData.first.forecastFinishDate??DateTime.now()),
              bayaInfraPaleYellow.withOpacity(0.3),
              bayaInfraYellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String date, Color bgColor, Color textColor) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
            ),
          ),
          Text(
            date,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ProjectScheduleProvider provider) {
    final theme = Theme.of(context);

    return Card(
      key: _progressKey,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Use the enhanced ProgressBarWidget with dual progress mode
            const ProgressBarWidgetStatus(
              enabled: true,
              showDualProgress: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleHealthCard(ProjectScheduleProvider provider) {
    final theme = Theme.of(context);
    final statusColor = hexToColor(provider.summaryData.first.statusColor??"");

    return Card(
      key: _healthKey,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule Health',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Variance : ',
                            style: const TextStyle(),
                          ),
                          TextSpan(
                            text: provider.summaryData.first.statusText,
                            style: const TextStyle(),
                          ),
                        ],
                      ),
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

  Widget _buildTasksSummaryCard(ProjectScheduleProvider provider,{required void Function() onTap}) {
    final theme = Theme.of(context);

    return Card(
      key: _tasksKey,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tasks Summary',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTaskRow(
              '${provider.summaryData.first.totalTasks} Total',
              bayaInfraBlue50!,
              Icons.list,
              bayaInfraBlue600!,
              onTap: (){}
            ),
            const SizedBox(height: 8),
            _buildTaskRow(
              '${provider.summaryData.first.completedTasks} Done',
              bayaInfraLightGreenColor.withOpacity(0.3),
              Icons.check_circle,
              bayaInfraGreen,
                onTap: (){
                  GoRouter.of(context).goNamed(AppRoutes.taskStatusPage,
                      extra: {
                        "ProjectStatus":ProjectStatus.Completed,
                        "projectId":provider.projectId,
                      });
                }
            ),
            const SizedBox(height: 8),
            _buildTaskRow(
              '${provider.summaryData.first.inProgressTasks} In Progress or On Hold',
              bayaInfraPaleYellow.withOpacity(0.3),
              Icons.warning,
              bayaInfraYellow,
                onTap: (){
                  GoRouter.of(context).goNamed(AppRoutes.taskStatusPage,
                      extra: {
                        "ProjectStatus":ProjectStatus.InProgress,
                        "projectId":provider.projectId,
                      });
                }
            ),
            const SizedBox(height: 8),
            _buildTaskRow(
              '${provider.summaryData.first.notStartedTasks} Not Started',
              bayaInfraBlue100!,
              Icons.play_circle_outline,
              bayaInfraGraphBluePrimary,
                onTap: (){
                  GoRouter.of(context).goNamed(AppRoutes.taskStatusPage,
                      extra: {
                        "ProjectStatus":ProjectStatus.NotStarted,
                        "projectId":provider.projectId,
                      });
                }
            ),
            const SizedBox(height: 8),
            _buildTaskRow(
              '${provider.summaryData.first.delayedTasks} Delayed (Open)',
              bayaInfraLightRedColor.withOpacity(0.3),
              Icons.error,
              bayaInfraRed,
                onTap: (){
                  GoRouter.of(context).goNamed(AppRoutes.taskStatusPage,
                      extra: {
                        "ProjectStatus":ProjectStatus.Delayed,
                        "projectId":provider.projectId,
                      });
                }
            ),
            const SizedBox(height: 8),
            _buildTaskRow(
              '${provider.summaryData.first.criticalTasks} On Critical Path (Active)',
              bayaInfraPaleOrangeRed.withOpacity(0.45),
              Icons.flash_on,
              bayaInfraPaleOrangeRed,
                onTap: (){
                  GoRouter.of(context).goNamed(AppRoutes.taskStatusPage,
                      extra: {
                        "ProjectStatus":ProjectStatus.CriticalPath,
                        "projectId":provider.projectId,
                        "criticalTaskIds":provider.summaryData.first.criticalTaskIds,
                      });
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(String text, Color bgColor, IconData icon, Color iconColor,{required Function() onTap}) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}