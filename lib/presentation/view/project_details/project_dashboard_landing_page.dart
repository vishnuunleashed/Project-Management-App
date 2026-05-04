import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';

import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/data/local/hive/project_local_storage_service.dart';

class ProjectDashboardLandingPage extends ConsumerStatefulWidget {
  final bool hideAppBar;
  final int projectId;
  final int rootFolderId;
  const ProjectDashboardLandingPage({super.key, this.hideAppBar = false,required this.rootFolderId,required this.projectId});

  @override
  ConsumerState<ProjectDashboardLandingPage> createState() =>
      _ProjectDashboardLandingPageState();
}

class _ProjectDashboardLandingPageState
    extends ConsumerState<ProjectDashboardLandingPage> {

  int projectId = 0;
  int rootFolderId = 0;

  @override
  void initState() {
    projectId = widget.projectId;
    rootFolderId = widget.rootFolderId;
    // TODO: implement initState
    super.initState();
  }




  static const _sectionColors = [
    // Observations — Steel Blue
    _SectionColors(
      iconBg: Color(0xFFEEF3F8),
      iconColor: Color(0xFF4A6580),
      cardAccents: [
        Color(0xFFEEF3F8),
        Color(0xFFF7ECE8),
        Color(0xFFEDF6EF),
        Color(0xFFF2EEF6),
        Color(0xFFEEF3F8),
      ],
      cardIconColors: [
        Color(0xFF4A6580),
        Color(0xFFB8745A),
        Color(0xFF4A8C55),
        Color(0xFF7B6C8D),
        Color(0xFF4A6580),
      ],
    ),

    // Support Requests — Terracotta
    _SectionColors(
      iconBg: Color(0xFFF7ECE8),
      iconColor: Color(0xFFB8745A),
      cardAccents: [
        Color(0xFFF7ECE8),
        Color(0xFFEDF6EF),
        Color(0xFFEEF3F8),
        Color(0xFFF2EEF6),
        Color(0xFFF7ECE8),
      ],
      cardIconColors: [
        Color(0xFFB8745A),
        Color(0xFF4A8C55),
        Color(0xFF4A6580),
        Color(0xFF7B6C8D),
        Color(0xFFB8745A),
      ],
    ),

    // Schedule — Moss Green
    _SectionColors(
      iconBg: Color(0xFFEDF6EF),
      iconColor: Color(0xFF4A8C55),
      cardAccents: [
        Color(0xFFEDF6EF),
        Color(0xFFEEF3F8),
        Color(0xFFF7ECE8),
        Color(0xFFF2EEF6),
      ],
      cardIconColors: [
        Color(0xFF4A8C55),
        Color(0xFF4A6580),
        Color(0xFFB8745A),
        Color(0xFF7B6C8D),
      ],
    ),

    // Material — Dusty Purple
    _SectionColors(
      iconBg: Color(0xFFF2EEF6),
      iconColor: Color(0xFF7B6C8D),
      cardAccents: [
        Color(0xFFF2EEF6),
        Color(0xFFEDF6EF),
      ],
      cardIconColors: [
        Color(0xFF7B6C8D),
        Color(0xFF4A8C55),
      ],
    ),
  ];

  String logoAssetForProjectIcon(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/project_icon_sky_blue.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/project_icon_forest_green.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/project_icon_slate_blue.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/project_icon_terracotta.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/project_icon_violet.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectDetailsProvider>(
      initState: (context, provider, ref) {
        provider.getUserDetails();
        provider.fetchOwners();
      },
      provider: projectDetailsProvider,
      appBar: widget.hideAppBar ? null : CustomAppBar(
        title:  Text("Project Landing Page"),
        shadowNeeded: true,

      ),
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
        final isOffline = ref.watch(homeProvider).isOffline;
        return SingleChildScrollView(
          child: provider.loadingStatus.loader == Loader.loading ? SizedBox.shrink() : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Visibility(
                       visible: !isOffline,
                       child: _buildProjectHeader(context,variant,provider)),
                  const SizedBox(height: 4),

                  // ── DCC Section (Always visible) ──
                  _buildSection(
                    context,
                    title: "Document Control Center",
                    subtitle: "Project documents & files",
                    icon: Icons.folder_copy_rounded,
                    sectionIndex: 0,
                    actions: [
                      _ActionItem("Open DCC", Icons.folder_open_rounded,
                              () => _navigate(context, "PROJECT_DCC")),
                    ],
                  ),

                  // ── Other Sections (Hidden when offline) ──
                  if (!isOffline) ...[
                    _buildSection(
                      context,
                      title: "Observations",
                      subtitle: "Track & manage site observations",
                      icon: Icons.visibility_rounded,
                      sectionIndex: 0,
                      actions: [
                        _ActionItem("Add", Icons.add_circle_rounded,showMenu: ref.watch(homeProvider).addObservationRight,
                                () => _navigate(context, "ADD_OBSERVATION")),
                        _ActionItem("Assigned", Icons.assignment_ind_rounded,
                                () => _navigate(context, "OBS_ASSIGNED")),
                        _ActionItem("Raised", Icons.flag_rounded,
                                () => _navigate(context, "OBS_RAISED")),
                        _ActionItem("All", Icons.list_alt_rounded,
                                () => _navigate(context, "OBS_ALL")),
                         _ActionItem("Dashboard", Icons.dashboard_rounded,
                                 () => _navigate(context, "OBS_DASHBOARD")),
                      ],
                    ),
                    _buildSection(
                      context,
                      title: "Support Requests",
                      subtitle: "Manage support & issues",
                      icon: Icons.support_agent_rounded,
                      sectionIndex: 1,
                      actions: [

                        _ActionItem("Add", Icons.add_circle_rounded,showMenu: ref.watch(homeProvider).addSupportRight,
                                () => _navigate(context, "ADD_SUPPORT")),
                        _ActionItem("Assigned", Icons.assignment_ind_rounded,
                                () => _navigate(context, "SUP_ASSIGNED")),
                        _ActionItem("Raised", Icons.flag_rounded,
                                () => _navigate(context, "SUP_RAISED")),
                        _ActionItem("All", Icons.list_alt_rounded,
                                () => _navigate(context, "SUP_ALL")),
                        _ActionItem("Dashboard", Icons.dashboard_rounded,
                                () => _navigate(context, "SUP_DASHBOARD")),
                      ],
                    ),
                    _buildSection(
                      context,
                      title: "Schedule",
                      subtitle: "Tasks, deadlines & timelines",
                      icon: Icons.schedule_rounded,
                      sectionIndex: 2,
                      actions: [
                        _ActionItem("My Tasks", Icons.person_pin_rounded,
                                () => _navigate(context, "SCH_MY_TASKS")),
                        _ActionItem("Reportees Tasks", Icons.group_rounded,
                                () => _navigate(context, "SCH_REPORTEES")),
                        _ActionItem("All", Icons.list_alt_rounded,
                                () => _navigate(context, "SCH_ALL")),
                        _ActionItem("Activity Health", Icons.analytics_rounded,
                                () => _navigate(context, "SCH_ACTIVITY_GROUP")),
                        _ActionItem("Labour Count", Icons.person,
                                () => _navigate(context, "SCH_LABOUR_COUNT"), showMenu: (((provider.projectDetailList.isNotEmpty) ? provider.projectDetailList.first.siteInChargeYN : false) || provider.isSuperUser) ),
                        _ActionItem("Dashboard", Icons.dashboard_rounded,
                                () => _navigate(context, "SCH_DASHBOARD")),
                      ],
                    ),
                    _buildSection(
                      context,
                      title: "Material",
                      subtitle: "Inventory & material tracking",
                      icon: Icons.inventory_2_rounded,
                      sectionIndex: 3,
                      actions: [
                        _ActionItem("Add Material Indent", Icons.add_chart,showMenu: (provider.isSuperUser ||  ref.watch(homeProvider).isProjectDepartment),
                                () => _navigate(context, "MAT_INTEND")),
                        _ActionItem("Material Chart", Icons.category_rounded,
                                () => _navigate(context, "MAT_CHART")),
                      ],
                    ),
                    _buildSection(
                      context,
                      title: "Minutes Of Meeting",
                      subtitle: "Track & manage meeting",
                      icon: Icons.business_center,
                      sectionIndex: 0,
                      actions: [
                        _ActionItem("Add MOM", Icons.add_circle_rounded,showMenu: true,
                                () => _navigate(context, "ADD_MOM")),
                        _ActionItem("List MOM", Icons.list_alt_outlined,showMenu: true,
                                () => _navigate(context, "LIST_MOM")),
                      ],
                    ),
                  ],

                  // ── Offline Banner ──
                  if (isOffline)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFFFF9800)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are offline. Only Document Control Center is available.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFFF9800),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
        );
      },
    );
  }

  Widget _buildProjectHeader(BuildContext context, AppThemeVariant variant, ProjectDetailsProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
          width: 0.2,
        ),
      ),
      child: Column(
        children: [
          // ── ExpansionTile: icon + title + client + location + chevron ──
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: provider.isExpandedClient,
              onExpansionChanged: (value) {
                provider.expansionTileCollapseClient(value);
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              childrenPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      logoAssetForProjectIcon(variant),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.projectDetailList.isNotEmpty ? provider.projectDetailList.first.projectName ?? "" : "",
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                (provider.projectDetailList.isNotEmpty) ? provider.projectDetailList.first.clientName ?? "" : "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                provider.projectDetailList.isNotEmpty ? provider.projectDetailList.first.location ?? "" : "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              trailing: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  provider.isExpandedClient
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),

              children: [
                projectDetailCard(context, provider),
              ],
            ),
          ),

          // ── Geo Location tile: always visible, outside expansion ──
          if( (provider.isSuperUser || (provider.projectDetailList.isNotEmpty ? provider.projectDetailList.first.siteInChargeYN : false)))...[
          Divider(
            height: 1,
            thickness: 0.6,
            color: Theme.of(context).dividerColor.withOpacity(0.4),
            indent: 12,
            endIndent: 12,
          ),
         InkWell(
              onTap: () {
                GoRouter.of(context).pushNamed(
                  AppRoutes.projectLocationPage,
                  extra: {"projectId": projectId},
                );
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.language_outlined,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Project Geo Location",
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tap to view on map",
                            style: textTheme.labelMedium?.copyWith(

                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: 22,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    ]
        ],
      ),
    );
  }

  Widget projectDetailCard(BuildContext context, ProjectDetailsProvider provider) {
    final textTheme = Theme.of(context).textTheme;
    const bayaInfraGrey = Color(0xFFB0B0B0);


    return BaseConsumer(
      provider: projectDetailsProvider ,
      builder: (context, provider,ref) {
        return Card(
          elevation: 0.5,
          color: Theme.of(context).cardColor,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // removes the bottom border line
            ),
            child: Column(
              children: [
                Divider(thickness: 0.2,),
                Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Dates section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start Date",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${provider.projectTotalDays} days",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "End Date",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                            color: bayaInfraGrey,
                            indent: 18,
                            endIndent: 18,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  provider.projectDetailList.first.startDate ??
                                      DateTime.now(),
                                ),
                                style: textTheme.labelMedium,
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  provider.projectDetailList.first.endDate ??
                                      DateTime.now(),
                                ),
                                style: textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Circular Graph
                      (provider.projectRemainingDays != 0 && provider.projectDetailList.first.startDate!.isBefore(DateTime.now()))?
                      Padding(
                        padding: const EdgeInsets.only(top: 8,bottom: 12),
                        child: Center(
                          child: SizedBox(
                            height: 200,
                            width: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(250, 250),
                                ),
                                PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 0,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(
                                        value: provider.projectTotalDays.toDouble(),
                                        color: bayaInfraGraphBlueSecondary,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        value: provider.projectRemainingDays.toDouble(),
                                        color: bayaInfraGraphBluePrimary,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${provider.projectRemainingDays} days left",
                                  style: textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) :
                      (provider.projectDetailList.first.startDate!.isBefore(DateTime.now())) ?
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                                color: bayaInfraRed,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 4, left: 8, right: 8),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme.of(context).iconTheme.color,
                                  ),

                                  Text(
                                    'Project delayed',
                                    style:
                                    Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) :
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            decoration: BoxDecoration(
                                color: bayaInfraGreen,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 4, left: 8, right: 8),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme.of(context).iconTheme.color,
                                  ),

                                  Text(
                                    'Scheduled to start',
                                    style:
                                    Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required int sectionIndex,
        required List<_ActionItem> actions,
      }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = _sectionColors[sectionIndex];

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: colors.iconBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.iconColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: colors.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Action Tiles (UMANG-style) ──────────────────────────────────
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];

                  final tileIconBg =
                  colors.cardAccents[index % colors.cardAccents.length];
                  final tileIconColor =
                  colors.cardIconColors[index % colors.cardIconColors.length];

                  return Visibility(
                    visible: action.showMenu,
                    child: GestureDetector(
                      onTap: action.onTap,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.22,
                        margin: const EdgeInsets.only(right: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: tileIconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                action.icon,
                                color: tileIconColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Flexible(
                              child: Text(
                                action.title,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String type) {
    switch (type) {
      case "ADD_OBSERVATION":
        GoRouter.of(context).pushNamed(AppRoutes.addObservation,
            extra: {"projectId": projectId});
        break;
      case "OBS_RAISED":
        GoRouter.of(context).pushNamed(AppRoutes.myObservationPage,
            extra: {"isFromProjectDetails": false, "tag": "CREATED", "projectId": projectId});
        break;
      case "OBS_ASSIGNED":
        GoRouter.of(context)
            .pushNamed(AppRoutes.assignedObsScreen, extra: {
          "projectId": projectId,
          "isFromObservation": true,
          "flagObs": "AGAINST",
          "DelayedYN": "None"
        });
        break;
      case "OBS_ALL":
        GoRouter.of(context).pushNamed(AppRoutes.allObsLandingPage, extra: {"projectId": projectId});
        break;
      case "OBS_DASHBOARD":
        ref.read(projectDetailsProvider.notifier).setTopTabIndex(0);
        break;
      case "ADD_SUPPORT":
        GoRouter.of(context).pushNamed(AppRoutes.addSupportRequest,
            extra: {"projectId": projectId});
        break;
      case "SUP_RAISED":
        GoRouter.of(context).pushNamed(AppRoutes.mySupportRequestScreen,
            extra: {"isFromProjectDetails": false, "tag": "CREATED", "projectId": projectId});
        break;
      case "SUP_ASSIGNED":
        GoRouter.of(context)
            .pushNamed(AppRoutes.assignedSupScreen, extra: {
          "projectId": projectId,
          "isFromSupport": true,
          "flagObs": "AGAINST",
          "DelayedYN": "None"
        });
        break;
      case "SUP_ALL":
        GoRouter.of(context).pushNamed(AppRoutes.allSupLandingPage, extra: {"projectId": projectId});
        break;
      case "SUP_DASHBOARD":
        ref.read(projectDetailsProvider.notifier).setTopTabIndex(1);
        break;
      case "SCH_MY_TASKS":
        GoRouter.of(context).pushNamed(AppRoutes.projectScheduleMyTaskDirect, extra: {
          "projectId": projectId,
          "route_path": "projectScheduleMyTaskDirect",
        });
        break;
      case "SCH_REPORTEES":
        GoRouter.of(context).pushNamed(AppRoutes.projectScheduleReporteeTaskDirect, extra: {
          "projectId": projectId,
          "route_path": "projectScheduleReporteeTaskDirect",
        });
        break;
      case "SCH_ALL":
        GoRouter.of(context).pushNamed(AppRoutes.projectScheduleAllTaskDirect, extra: {
          "projectId": projectId,
          "route_path": "projectScheduleAllTaskDirect",
        });
        break;
      case "SCH_ACTIVITY_GROUP":
        GoRouter.of(context).pushNamed(AppRoutes.activityGroupDashboard, extra: {
          "projectId": projectId,
        });
        break;
      case "SCH_LABOUR_COUNT":
        GoRouter.of(context).pushNamed(AppRoutes.scheduleLabourCountScreen, extra: {
          "projectId": projectId,
        });
        break;
      case "SCH_DASHBOARD":
        ref.read(projectDetailsProvider.notifier).setTopTabIndex(2);
        break;
      case "MAT_INTEND":
        GoRouter.of(context)
            .pushNamed(AppRoutes.addAdditionalMaterialScreen, extra: {"projectId": projectId});
        break;
      case "MAT_CHART":
        GoRouter.of(context)
            .pushNamed(AppRoutes.additionMaterialMainScreen, extra: {
          "projectId": projectId,
          "viewAll": true,
          "selectedOptionIndex": 0
        });
      case "ADD_MOM":
        GoRouter.of(context).pushNamed(AppRoutes.addMOMScreen, extra:  {
          "projectId": projectId,
        });
      case "LIST_MOM":
        GoRouter.of(context).pushNamed(AppRoutes.listMOMScreen, extra:  {
          "projectId": projectId,
        });
        break;
      case "PROJECT_DCC":

        print("projectId___$projectId");
        print("rootFolderId___$rootFolderId");

        GoRouter.of(context).pushNamed(AppRoutes.dccProjectScreen, extra: {
          "projectId": projectId,
          "rootFolderId": rootFolderId,
        });
        break;
    }
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _ActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showMenu;

  _ActionItem(this.title, this.icon, this.onTap, {this.showMenu = true});
}

/// Per-section retro color config
class _SectionColors {
  final Color iconBg;
  final Color iconColor;
  final List<Color> cardAccents;
  final List<Color> cardIconColors;

  const _SectionColors({
    required this.iconBg,
    required this.iconColor,
    required this.cardAccents,
    required this.cardIconColors,
  });
}

/// Draws a dashed horizontal line — retro UMANG-style divider
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}