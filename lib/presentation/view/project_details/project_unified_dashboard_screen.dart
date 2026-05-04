import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/export.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/view/dashboard/dashboard_main_screen.dart';
import 'package:interior_design/presentation/view/dashboard/observation_dashboard_screen.dart';
import 'package:interior_design/presentation/view/dashboard/support_dashboard_screen.dart';
import 'package:interior_design/presentation/view/project_dash_board/widgets/glassmorphic_text_toggle.dart';
import 'package:interior_design/presentation/view/project_details/project_dashboard_landing_page.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/project_schedule_dashboard_screen.dart';

class ProjectUnifiedDashboardScreen extends ConsumerStatefulWidget {
  final int projectId;
  final int rootFolderId;
  const ProjectUnifiedDashboardScreen({super.key,required this.rootFolderId,required this.projectId});

  @override
  ConsumerState<ProjectUnifiedDashboardScreen> createState() =>
      _ProjectUnifiedDashboardScreenState();
}

class _ProjectUnifiedDashboardScreenState
    extends ConsumerState<ProjectUnifiedDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Reset state when entering the unified screen
    Future.microtask(() {
      ref.read(projectDetailsProvider.notifier).setBottomIndex(0);
      ref.read(projectDetailsProvider.notifier).setTopTabIndex(0);
    });
    
    // Listen to provider changes to sync TabController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(projectDetailsProvider, (previous, next) {
        if (next.topTabIndex != _tabController.index) {
          _tabController.animateTo(next.topTabIndex);
        }
      });
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(projectDetailsProvider);
    final bottomSelectedIndex = dashboardState.bottomSelectedIndex;
    
    String appBarTitle = bottomSelectedIndex == 1 ? "Project Menu" : "Project Dashboard";
    
    return BaseView<ProjectDetailsProvider>(
      isLoaderRequired: false,
      initState: (context,provider,ref){
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
        provider.initState(extra: extra);
      },
      provider: projectDetailsProvider,
      appBar: CustomAppBar(
        title: Text(appBarTitle),
      ),

      builder: (context,provider,ref) {
        return Column(
          children: [
            Expanded(child: bottomSelectedIndex == 0 ? _buildDashboardsView(dashboardState.topTabIndex) : _buildMenuView()),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, -3), // negative y = top shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: ['Dashboards', 'Menu'].asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    final isActive = bottomSelectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(projectDetailsProvider.notifier)
                              .setBottomIndex(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == 1 ? 0 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isActive
                                ? null
                                : Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              color: isActive
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ///claude i want you to write a button her  'Dashboards' : 'Menu'...use primary color for active button and card color for the other one
            // SizedBox(
            //   width: MediaQuery.of(context).size.width,
            //   height: 60,
            //   child: GlassmorphicSegmentedButton(
            //     selectedLabel: bottomSelectedIndex == 0 ? 'Dashboards' : 'Menu',
            //     labels: const ['Dashboards', 'Menu'],
            //     onSelected: (label) {
            //       ref.read(projectUnifiedDashboardProvider.notifier)
            //           .setBottomIndex(label == 'Dashboards' ? 0 : 1);
            //     },
            //   ),
            // ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardsView(int selectedTabIndex) {
    final extra = {
      "projectId": widget.projectId,
    };
    
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: (index) {
            ref.read(projectDetailsProvider.notifier).setTopTabIndex(index);
          },
          labelStyle: Theme.of(context).textTheme.titleSmall,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          padding: EdgeInsets.zero,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          tabs: [
            Tab(text: "Observations"),
            Tab(text: "Support Requests"),
            Tab(text: "Schedule"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            // Disable swiping if it interferes with internal scrolling
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Observation Dashboard
              ProviderScope(
                overrides: [
                  dashBoardProvider.overrideWith((ref) => DashBoardProvider()),
                ],
                child: ObservationDashboardScreen(
                  hideAppBar: true,
                  projectId: widget.projectId,

                ),
              ),
              // Support Dashboard
              ProviderScope(
                overrides: [
                  dashBoardProvider.overrideWith((ref) => DashBoardProvider()),
                ],
                child: SupportDashboardScreen(
                  hideAppBar: true,
                  projectId: widget.projectId,
                ),
              ),
              // Schedule Dashboard
              ProjectScheduleDashBoardScreen(
                hideAppBar: true,
                projectId: widget.projectId,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuView() {
    return ProjectDashboardLandingPage(hideAppBar: true,projectId:  widget.projectId ,rootFolderId: widget.rootFolderId,);
  }
}
