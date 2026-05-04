import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/all_observation_support_request/all_observation_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/all_observation_request/all_observation_screen.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';
import 'package:interior_design/utils/routes.dart';

class AllObservationRequestScreen extends ConsumerStatefulWidget {
  const AllObservationRequestScreen({super.key});

  @override
  ConsumerState<AllObservationRequestScreen> createState() =>
      _AllObservationRequestScreenState();
}

class _AllObservationRequestScreenState
    extends ConsumerState<AllObservationRequestScreen> with RouteAware {

  // ── RouteAware lifecycle ───────────────────────────────────────────────

  @override
  void didPopNext() {
    Future.microtask(() async {
      var provider = ref.watch(allObservationRequestProvider);
      provider.fetchObservationList(changeStart: true);
    });
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AllObservationRequestProvider>(
        initState: (context, provider, ref) {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.initState();
          provider.setNavigationParameters(extra:extra??{});

          provider.getUserDetails();
          provider.initObsScrollListener();
          provider.fetchOwners();
        },
        provider: allObservationRequestProvider,
        appBar: CustomAppBar(
          title: BaseStatelessConsumer<AllObservationRequestProvider>(
            provider: allObservationRequestProvider,
            builder: (context, provider, ref) {
              return Text("All Observations");

            },
          ),
        ),
        bottomNavigationBar:(context,provider,ref){
          return EnumBottomBar<AllObservationAndSupportStatus>(
            items: provider.isFromDashboard
                ? [AllObservationAndSupportStatus.opened,AllObservationAndSupportStatus.delayed]
                : AllObservationAndSupportStatus.values,
            titles: provider.isFromDashboard
                ? ["Opened", "Delayed"]
                : ["Opened", "Delayed", "Closed"],
            icons: provider.isFromDashboard
                ? [Icons.folder_open,Icons.check_circle]
                : [Icons.folder_open, Icons.access_time, Icons.check_circle],
            initialIndex: provider.bottomBarStatus == AllObservationAndSupportStatus.opened
                ? 0 : provider.bottomBarStatus == AllObservationAndSupportStatus.delayed ?  1 : 2,
            onTabSelected: (status){
              provider.onTapBottomSelected(status);
            },
          );
        },

        virtualFloatingActionButton: BaseStatelessConsumer(
          provider: allObservationRequestProvider,
          builder: (context, provider, ref) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomRight,
              children: [
                // ExpandableFab FIRST (bottom layer) — fills stack via Align internally
                ExpandableFab(
                  bottomPadding: 10,
                  distance: 70,
                ),

                // Filter + Sort buttons pinned to bottom-left
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10,right: 70),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          heroTag: "Filter",
                          child: Icon(Icons.filter_alt_outlined, color: bayaInfraWhiteColor),
                          onPressed: () {
                            BaseBottomSheet.show(
                              showSlideLine: false,
                              context: context,
                              barrierDismissible: false,
                              enableDrag: false,
                              child: filterObsFormWidget(),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          heroTag: "Date Range",
                          child: Icon(Icons.sort_outlined, color: bayaInfraWhiteColor),
                          onPressed: () {
                            BaseBottomSheet.show(
                              context: context,
                              child: bottomObsFilterForm(
                                context: context,
                                provider: provider,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        builder: (context, provider, ref) {
          return Column(
            children: [
              Visibility(
                visible: !provider.isFromDashboard,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: bayaInfraDisabledColorDark, width: 0.5),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/svgs/project_icon.svg',
                          ),
                        ),
                      ),
                      SizedBox(width: 4,),
                      Text(
                        provider.projectDetailList.isEmpty?"":provider.projectDetailList.first.projectName?? "",
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: provider.isFromDashboard,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                         Builder(
                           builder: (context) {
                             return GestureDetector(
                               onTap: () {
                                 ProfileImageDialog.show(context: context,
                                   imageUrl: provider.userprofileurl ,
                                   userName:  provider.raisedUser ,);

                               },
                               child: CachedNetworkImageWidget(
                                 imageUrl:  provider.userprofileurl,
                                 size: 50,
                                 userName: provider.raisedUser,
                               ),
                             );
                           }
                         ),
                        SizedBox(width: 4,),
                        Text(
                          provider.raisedUser,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),),

              Expanded(child: AllObservationListWidget())

            ],
          ) ;


        });
  }

  filterObsFormWidget() {
    final DateTime now = DateTime.now();
    final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
    return BaseStatelessConsumer(
        provider: allObservationRequestProvider,
        builder: (context, provider, ref){
          return Form(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0,right: 8),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Center(
                                child: Text(
                                  "Filter",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                            onPressed: () {
                              GoRouter.of(context).pop();
                              provider.clearObservationFilter(isFromClearButton: false);
                            },
                          ),
                        ],
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          showUserListDialog(
                              title: "Observer",
                              context,
                              userList: provider.owners,
                              // names: provider.namesFromOwnerModel,
                              onForward: (value){
                                provider.setSelectedOwner(value);
                                GoRouter.of(context).pop();
                              });
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            validator: (val){
                              return (provider.selectedOwner == null) ? "Please select observer" : null;
                            },
                            controller: provider.obsOwnerController,
                            style: Theme.of(context).textTheme.titleSmall,
                            decoration:  InputDecoration(
                              suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                              // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                              hintText: "Observer",
                              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                              labelStyle: Theme.of(context).textTheme.titleMedium,
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0.54,),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0.54,
                                      color: Theme.of(context).colorScheme.primary),
                                  borderRadius: BorderRadius.circular(10)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 0.54, color: bayaInfraRedColor),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 0.54, color: bayaInfraRedColor),
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0.54,
                                      color: provider.owners.isEmpty
                                          ? Theme.of(context)
                                          .disabledColor
                                          .withValues(alpha: 0.5)
                                          : Theme.of(context).colorScheme.primary),
                                  borderRadius: BorderRadius.circular(10)),
                            ),

                            onTap: (){
                            },

                          ),
                        ),
                      ),
                      BaseTextField(
                        controller: provider.filterPointsController,
                        displayTitle: "Points",
                      ),
                      BaseTextField(
                        controller: provider.filterTransNoController,
                        displayTitle: "Trans no.",
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text("Show all observations",style: Theme.of(context).textTheme.titleMedium,),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: (provider.tempIsShowAllObs) ??  provider.isShowAllObs,
                            onChanged: (val) {
                              provider.changeIsShowAllObs(val);
                            },
                          ),
                        ],
                      ),
                      Visibility(
                          visible: (provider.tempIsShowAllObs != null) ? !provider.tempIsShowAllObs! : !provider.isShowAllObs,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Created date",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: BaseDatesPicker(
                                      onChange: (date) {
                                        provider.changeObsDateFrom(date);
                                      },
                                      lastDate: provider.tempObsDateTo ?? provider.obsDateTo,
                                      initialDate: provider.tempObsDateFrom ?? provider.obsDateFrom,
                                      subtitle: 'Date from',
                                    ),
                                  ),
                                  Expanded(
                                    child: BaseDatesPicker(
                                      onChange: (date) {
                                        provider.changeObsDateTo(date);
                                      },
                                      firstDate: provider.tempObsDateFrom ?? provider.obsDateFrom,
                                      initialDate: provider.tempObsDateTo ?? provider.obsDateTo,
                                      subtitle: 'Date to',
                                      lastDate: twoYearsLater,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: BaseElevatedButton(
                                  onPressed: () {
                                    provider.clearObservationFilter(isFromClearButton: true);
                                  },
                                  text: 'Clear',
                                  height: 40,
                                  backgroundColor: bayaInfraDisabledColor,
                                )),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                                child: BaseElevatedButton(
                                  height: 40,
                                  onPressed: () {
                                    provider.setIsShowAllObs();
                                    provider.setObsRangeFilterApplied(false);
                                    provider.setObsFilterDateField();
                                    GoRouter.of(context).pop();
                                    provider.fetchObservationList(changeStart: true);

                                  },
                                  text: 'Apply',
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
              ),
            ),
          );
        }
    );
  }
  bottomObsFilterForm({required BuildContext context, required AllObservationRequestProvider provider}){
    return SingleChildScrollView(
      child: Column(
        children: [
          DateRangeTile(
            label: "Last Week",
            selectedRange: provider.selectedObsRangeLabel,
            onTap: () {
              provider.clearObservationFilter(isFromClearButton: true);
              if(provider.selectedObsRangeLabel == "Last Week"){
                provider.setObsRangeFilterApplied(false);
                provider.fetchObservationList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setLastWeek(isSupport: false);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Week",
            selectedRange: provider.selectedObsRangeLabel,
            onTap: () {
              provider.clearObservationFilter(isFromClearButton: true);
              if(provider.selectedObsRangeLabel == "This Week") {
                provider.setObsRangeFilterApplied(false);
                provider.fetchObservationList();
                GoRouter.of(context).pop();
              }
              else{
                provider.setThisWeek(isSupport: false);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Last Month",
            selectedRange: provider.selectedObsRangeLabel,
            onTap: () {
              provider.clearObservationFilter(isFromClearButton: true);
              if(provider.selectedObsRangeLabel == "Last Month"){
                provider.setObsRangeFilterApplied(false);
                provider.fetchObservationList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setLastMonth(isSupport: false);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Month",
            selectedRange: provider.selectedObsRangeLabel,
            onTap: () {
              provider.clearObservationFilter(isFromClearButton: true);
              if(provider.selectedObsRangeLabel == "This Month"){
                provider.setObsRangeFilterApplied(false);
                provider.fetchObservationList();
                GoRouter.of(context).pop();
              }
              else{
                provider.setThisMonth(isSupport: false);
                GoRouter.of(context).pop(context);
              }

            },
          ),
        ],
      ),
    );
  }
}
