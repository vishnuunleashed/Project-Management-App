// import 'package:base/core/loader_value.dart';
// import 'package:base/presentation/base/base_view.dart';
// import 'package:base/presentation/provider/change_notifier_provider.dart';
// import 'package:base/presentation/theme_config.dart';
// import 'package:base/presentation/utility/orientation.dart';
// import 'package:base/presentation/views/base_elevated_button.dart';
// import 'package:base/presentation/views/customer_app.dart';
// import 'package:expandable_page_view/expandable_page_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
// import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
// import 'package:interior_design/presentation/state/app_state.dart';
// import 'package:interior_design/presentation/view/common/expandable_fab.dart';
// import 'package:interior_design/presentation/view/common/header_card.dart';
// import 'package:interior_design/presentation/view/dashboard/partials/dashboard_shared_widgets.dart';
// import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';
//
// class DashboardMainScreen extends StatefulWidget {
//   final bool hideAppBar;
//   final String? forcedTitle;
//   final bool? viewObservationRights;
//   final bool? viewSupportRights;
//   final int? projectId;
//   const DashboardMainScreen({
//     super.key,
//     this.hideAppBar = false,
//     this.forcedTitle,
//     this.viewObservationRights,
//     this.viewSupportRights,
//     this.projectId,
//   });
//
//   @override
//   State<DashboardMainScreen> createState() => _DashboardMainScreenState();
// }
//
// class _DashboardMainScreenState extends State<DashboardMainScreen>
//     with SingleTickerProviderStateMixin {
//   TabController? _tabController;
//
//   String emptyStateIcon(AppThemeVariant variant) {
//     switch (variant) {
//       case AppThemeVariant.skyBlue:     return 'assets/svgs/empty_state_sky_blue.svg';
//       case AppThemeVariant.forestGreen: return 'assets/svgs/empty_state_forest_green.svg';
//       case AppThemeVariant.slate:       return 'assets/svgs/empty_state_slate_blue.svg';
//       case AppThemeVariant.terracotta:  return 'assets/svgs/empty_state_terracotta_.svg';
//       case AppThemeVariant.violet:      return 'assets/svgs/empty_state_violet.svg';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<DashBoardProvider>(
//       appBar: widget.hideAppBar ? null : CustomAppBar(
//         title: Text(
//           widget.forcedTitle ?? "Project Analytics & Reports",
//         ),
//       ),
//       initState: (context, provider, ref) {
//
//         final state = GoRouterState.of(context);
//         final extra = state.extra as Map<String, dynamic>?;
//         final effectiveProjectId = widget.projectId ?? extra?["projectId"] ?? 0;
//
//         provider.initValues(
//             effectiveProjectId);
//
//         provider.setInitialPage();
//       },
//       virtualFloatingActionButton:ExpandableFab(
//           distance: 70, bottomPadding: 10),
//       builder: (context, provider, ref) {
//
//         final variant = ref.watch(
//           settingsProvider.select((s) => s.currentVariant),
//         );
//         final screenHeight = MediaQuery.of(context).size.height;
//         final ThemeMode currentTheme = ref.watch(settingsProvider.select((settings) => settings.currentTheme));
//         bool isDarkTheme = (SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
//             && currentTheme == ThemeMode.system) || currentTheme == ThemeMode.dark;
//         return SingleChildScrollView(
//           physics: ClampingScrollPhysics(),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: screenHeight - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom),
//               ),
//               child: Column(
//                 children: [
//                   // provider.projectDetailList.isEmpty
//                   //     ? SizedBox(height: 0,)
//                   //     : ProjectHeaderCard(
//                   //     projectName: provider.projectDetailList.first.projectName??"",
//                   //     endDate: provider.projectDetailList.first.endDate??DateTime.now(),
//                   //     locationName: provider.projectDetailList.first.location??""
//                   // ),
//                   if (!provider.isInitialLoad) ...[
//                     if (provider.dashBoardTabs.isEmpty)
//                       buildEmptyView(context, isDarkTheme, variant)
//                     else ...[
//                       DefaultTabController(
//
//                         length: provider.dashBoardTabs.length,
//                         initialIndex: provider.currentTabIndex,
//                         child: Builder(  // ← Add Builder here to get correct context
//                           builder: (tabContext) => Column(
//                             children: [
//                                 if (provider.dashBoardTabs.length > 1)
//                                 Container(
//                                   margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
//                                   child: TabBar(
//                                   isScrollable: false,
//                                   tabAlignment: TabAlignment.fill,
//                                    splashBorderRadius: BorderRadius.circular(10),
//                                    indicator: const BoxDecoration(),
//                                    dividerHeight: 0,
//                                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
//                                   // indicator: BoxDecoration(
//                                   //   color: Colors.transparent,
//                                   //   borderRadius: BorderRadius.circular(10),
//                                   //   border: Border.all(color: Colors.transparent, width: 0),
//                                   // ),
//
//
//                                   onTap: (index) {
//                                     provider.changeTab(index);
//                                     provider.pageController.jumpToPage(index);  // ← sync PageView when tab tapped
//                                   },
//                                   tabs: List.generate(provider.dashBoardTabs.length, (index) {
//                                     final isSelected = provider.currentTabIndex == index;
//                                     return Tab(
//                                       height: MediaQuery.of(context).size.height * 0.05,
//                                       child: Container(
//                                         alignment: Alignment.center,
//                                         width: double.infinity,
//                                         decoration: BoxDecoration(
//                                            color: isSelected ? Theme.of(context).hintColor : Colors.transparent,
//                                             borderRadius: BorderRadius.circular(10),
//                                           border: Border.all(
//                                             color: isSelected
//                                                 ? Theme.of(context).primaryColor
//                                                 : Theme.of(context).dividerColor.withOpacity(0.3),
//                                             width: isSelected ? 1 : 0.5,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           provider.dashBoardTabs[index],
//                                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                                             color: isSelected ? Theme.of(context).primaryColor : null,
//                                             fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                               ),
//                               ExpandablePageView(
//                                 controller: provider.pageController,
//                                 onPageChanged: (index) {
//                                   provider.changeTab(index);
//                                   DefaultTabController.of(tabContext).animateTo(index);  // ← use tabContext
//                                 },
//                                 children: provider.dashBoardTabs
//                                     .map((_) => DashboardCharts(provider: provider))
//                                     .toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ],
//               ),
//             ),
//
//         );
//       },
//
//       provider: dashBoardProvider,
//     );
//   }
//
//   Widget buildEmptyView(BuildContext context, bool isDarkTheme, AppThemeVariant variant) {
//     return LayoutBuilder(
//       builder: (context, constraint) {
//         return ConstrainedBox(
//           constraints: BoxConstraints(
//             minHeight: MediaQuery.of(context).size.height * 0.3,
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height:  MediaQuery.of(context).size.height * 0.19),
//                 SvgPicture.asset(
//                   emptyStateIcon(variant),
//                   width: 135,
//                   height: 135,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No items to be displayed",
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ],
//             ),
//           ),
//         );}
//         );
//   }
//
//
// }