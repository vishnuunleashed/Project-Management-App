import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/core/loader_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:interior_design/presentation/view/dashboard/partials/dashboard_dtl_chart.dart';
import 'package:interior_design/presentation/view/dashboard/partials/dashboard_summary_chart.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';

class DashboardCharts extends ConsumerWidget {
  final DashBoardProvider provider;

  const DashboardCharts({super.key, required this.provider,});

  @override
  Widget build(BuildContext context,ref) {
    final variant = ref.watch(
      settingsProvider.select((s) => s.currentVariant),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(child: supportToggle(context,provider)),
        ),
        (provider.dashBoardList.isEmpty
            && provider.detailJson.isEmpty)
            ?SizedBox(
          height: MediaQuery.of(context).size.height/2,
              child: Center(
                child: EmptyListView(
                          emptyText: "No data found",
                        ),
              ),
            ):Column(
          children: [

            if (provider.dashBoardList.isNotEmpty &&
                (provider.dashBoardList.first.summaryJson?.isNotEmpty ?? false) &&
                (provider.dashBoardList.first.summaryJson?.first.totalCount ??
                        0) >
                    0)
              const Center(child: DashboardSummaryChart())
            else
              SizedBox(
                  height: 200,
                  child: Center(
                      child:
                      Text(provider.loadingStatus.loader == Loader.loading
                          ? ""
                          : "No Summary Data")
                  )
              ),
            if (provider.hasDetailData)
              const Center(child: DashboardDetailChart())
            else
              SizedBox(
                  height: 200,
                  child: Center(
                      child:
                      provider.loadingStatus.loader == Loader.loading ?
                          const Text("") : dashboardEmptyView(context,"No Detail Data", variant)
                  ),
              ),
          ],
        ),
      ],
    );
  }
}

Widget dashboardEmptyView(
    BuildContext context,String message, AppThemeVariant variant) {
  String emptyStateIconPath(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/empty_state_sky_blue.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/empty_state_forest_green.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/empty_state_slate_blue.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/empty_state_terracotta_.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/empty_state_violet.svg';
    }
  }
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          emptyStateIconPath(variant),
          width: 135,
          height: 135,
        ),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

Widget supportToggle(BuildContext context, DashBoardProvider provider) {
  if (provider.dashBoardTabs.length <= 1 && !provider.dashBoardTabs.contains("Support Requests")) {
    return const SizedBox.shrink();
  }
  // If it's the support dashboard or support tab is active
  if (provider.dashBoardTabs.isNotEmpty && provider.dashBoardTabs[provider.currentTabIndex] != 'Support Requests') {
    return const SizedBox.shrink();
  }

  final theme = Theme.of(context);
  final isCritical = provider.isCritical;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segmentBtn(
              context: context,
              label: 'Normal support',
              isSelected: !isCritical,
              onTap: () => provider.toggleSupportType(0),
            ),
          ),
          Expanded(
            child: _segmentBtn(
              context: context,
              label: 'Critical support',
              isSelected: isCritical,
              onTap: () => provider.toggleSupportType(1),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _segmentBtn({
  required BuildContext context,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: theme.dividerColor.withOpacity(0.4), width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : null
            ),
          ),
        ],
      ),
    ),
  );
}
