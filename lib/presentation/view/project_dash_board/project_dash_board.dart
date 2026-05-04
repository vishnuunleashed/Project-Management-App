import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/side_bar_provider.dart';
import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/home/swipable_side_bar.dart';
import 'package:interior_design/presentation/view/project_dash_board/user_hierarchy_widget.dart';
import 'package:interior_design/presentation/view/project_dash_board/widgets/glassmorphic_text_toggle.dart';
import 'package:interior_design/utils/routes.dart';

import '_partials/call_tracker_dashboard/_partials/call_tracker_tile.dart';
import '_partials/call_tracker_dashboard/call_tracker_dashboard.dart';
import '_partials/call_tracker_support_dashboard/call_tracker_support_dashboard.dart';
import '_partials/project_based_dashboard/_partials/_project_sub_dashboard.dart';
import '_partials/project_based_dashboard/_partials/additional_material_tile.dart';
import '_partials/project_based_dashboard/additional_material_dashboard.dart' show AdditionalMaterialCard;
import '_partials/project_based_dashboard/obs_dashboard.dart';
import '_partials/project_based_dashboard/support_dashboard.dart';
import '_partials/schedule/_schedule_sub_dashboard.dart';
import '_partials/schedule/schedule_dashboard.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const DashboardScreen({super.key, required this.scaffoldKeyHome});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  String emptyDashboardIcon(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/empty_dashboard_sky_bue.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/empty_dashboard_forest_green.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/empty_dashboard_slate_blue.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/empty_dashboard_terracotta.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/empty_dashboard_violet.svg';
    }
  }

  String _getSalutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    if (hour < 20) return "Good evening,";
    return "Good evening,";
  }
  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectDashboardProvider>(
      initState: (context, provider, ref) {},
      isLoaderRequired: true,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: const EdgeSwipeMenu(),
      provider: projectDashboardProvider,
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );


        final theme = Theme.of(context);
        return Column(
          children: [

            Expanded(
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).highlightColor,
                onRefresh: () async {
                  provider.initValue();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Home',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(' (${provider.categoryFlag == CategoryFlag.AGAINST?'Assigned':"Raised"})',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge

                          ),

                        ],
                      ),
                    ),


                    Visibility(
                      visible: provider.categoryFlag != CategoryFlag.RAISED,
                      child: Column(
                        children: [
                          Divider(height: 8, thickness: 0.1, color: bayaInfraGrey),
                          CompactUserFilter(

                            onUserSelectionChanged: (user, scopeFlag) {

                              if (user.userName == "You") {
                                if (!provider.userHierarchyModel.any((item) {
                                  return item.userId == provider.loggedInUserId;
                                })) {
                                  provider.userHierarchyModel.add(UserHierarchyModel(
                                      userName: provider.loggedInUserName,
                                      userId: provider.loggedInUserId,
                                      userProfileImageUrl:
                                          provider.loggedInUserProfileImageUrl));
                                }
                                provider.updateSelectedUser(
                                    user: provider.userHierarchyModel.firstWhere((item) {
                                      return item.userId == provider.loggedInUserId;
                                    }),
                                    scopeFlag: provider.scopeFlag);
                              } else {
                                provider.updateSelectedUser(
                                    user: user, scopeFlag: provider.scopeFlag);
                              }
                            },
                          ),
                          Divider(height: 1, thickness: 0.1, color: bayaInfraGrey),
                        ],
                      ),
                    ),
                    SizedBox(height: 6,),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (provider.loadingStatus.loader == Loader.loading) {
                            return SizedBox();
                          }
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child:
                                      provider.loadingStatus.loader != Loader.loading &&
                                              ((provider.dashBoardResult.isEmpty) ||
                                                  (provider.observationCount!
                                                          .projectWise.isEmpty &&
                                                      provider.supportReqCount!
                                                          .projectWise.isEmpty &&
                                                      (provider.scheduleTaskCount == null
                                                          || provider.scheduleTaskCount!
                                                          .projectWise.isEmpty) &&
                                                      (provider.additionalMaterialCount
                                                              ?.projectWise
                                                              .isEmpty ??
                                                          true) &&
                                                      ((provider.callTrackSupportCount
                                                              ?.ticketWise.isEmpty ?? true) || provider.userId != provider.loggedInUserId ) &&
                                                      ((provider.callTrackCount?.totalCount??0) == 0 || provider.userId != provider.loggedInUserId)))
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        4,
                                                    child:  SvgPicture.asset(
                                                      emptyDashboardIcon(variant),
                                                      height: 200,
                                                    ),
                                                ),
                                                const SizedBox(height: 100),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                SizedBox(height: 8,),
                                                // Observations Card
                                                Visibility(
                                                    visible:
                                                        (provider.observationCount !=
                                                                null &&
                                                            provider
                                                                .observationCount!
                                                                .projectWise
                                                                .isNotEmpty),
                                                    child: ObservationsCard(
                                                      projects: provider.observations,
                                                      scaffoldKeyHome:
                                                          widget.scaffoldKeyHome,
                                                    )),
                                                const SizedBox(height: 8),

                                                // Support Requests Card
                                                Visibility(
                                                    visible:
                                                        (provider.supportReqCount !=
                                                                null &&
                                                            provider
                                                                .supportReqCount!
                                                                .projectWise
                                                                .isNotEmpty),
                                                    child: Column(
                                                      children: [
                                                        SupportRequestsCard(
                                                          projects: provider.supportRequests,
                                                          scaffoldKeyHome:
                                                              widget.scaffoldKeyHome,
                                                        ),
                                                        const SizedBox(height: 8),
                                                      ],
                                                    )),

                                                // Schedule Card
                                                Visibility(
                                                    visible:(provider.scheduleTaskCount !=
                                                                null &&
                                                            provider
                                                                .scheduleTaskCount!
                                                                .projectWise
                                                                .isNotEmpty),
                                                    child: Column(
                                                      children: [
                                                        ScheduleCard(
                                                            scaffoldKeyHome: widget
                                                                .scaffoldKeyHome,
                                                            projects: provider.schedules),
                                                        const SizedBox(height: 8),
                                                      ],
                                                    )),

                                                // Additional Material Card
                                                Visibility(
                                                    visible: (provider
                                                                .additionalMaterialCount !=
                                                            null &&
                                                        provider
                                                            .additionalMaterialCount!
                                                            .projectWise
                                                            .isNotEmpty),
                                                    child: Column(
                                                      children: [
                                                        AdditionalMaterialCard(
                                                            scaffoldKeyHome: widget
                                                                .scaffoldKeyHome,
                                                            projects:
                                                            provider.additionalMaterials),
                                                        const SizedBox(height: 8),
                                                      ],
                                                    )),

                                                // Call Track Card
                                                Visibility(
                                                  visible:
                                                   (provider.callTrackCount !=
                                                          null &&
                                                      (provider.callTrackCount!
                                                              .totalCount??0) !=
                                                          0 && provider.userId == provider.loggedInUserId),
                                                  child: Column(
                                                    children: [
                                                      CallTrackCard(
                                                          scaffoldKeyHome:
                                                              widget.scaffoldKeyHome,
                                                          ),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                                // Call Track Support Card
                                                Visibility(
                                                  visible:  (provider
                                                              .callTrackSupportCount !=
                                                          null &&
                                                      provider.callTrackSupportCount!
                                                              .totalCount !=
                                                          0 && provider.userId == provider.loggedInUserId),
                                                  child: Column(
                                                    children: [
                                                      CallTrackSupportCard(
                                                          scaffoldKeyHome:
                                                              widget.scaffoldKeyHome,
                                                          tickets: provider.callTrackSupports),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 200),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: projectDashboardProvider,
          builder: (context,provider,ref) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 40,right: 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height *0.075,
                child: GlassmorphicSegmentedButton(
                  selectedLabel: provider.categoryFlag == CategoryFlag.AGAINST?'ASSIGNED':"RAISED",
                  labels:  ['ASSIGNED', 'RAISED'],
                  onSelected: (category){
                    provider.changeCategoryFlag(categoryFlag: category == "ASSIGNED"?CategoryFlag.AGAINST:CategoryFlag.RAISED);
                  },
                  accentColor: Theme.of(context).primaryColor,
                  glassColor:provider.categoryFlag != CategoryFlag.RAISED
                      ? Theme.of(context).primaryColor
                      : Colors.white,

                ),
              ),
            );
          }
      ),
    );
  }

  Widget _buildSegmentButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
