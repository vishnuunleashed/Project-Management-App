/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    : Observation List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/utility/base_top_sheet.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_details/partials/observation_card.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:go_router/go_router.dart';

class ObservationListScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const ObservationListScreen({super.key, this.extra});

  @override
  ConsumerState<ObservationListScreen> createState() => _ObservationListScreenState();
}

class _ObservationListScreenState extends ConsumerState<ObservationListScreen> with RouteAware {

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
  void didPopNext() {
    Future.microtask(() async {
      await ref.read(projectDetailsProvider.notifier).fetchObservationList();
    });
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectDetailsProvider>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      provider: projectDetailsProvider,
      initState: (context, provider, ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initState(extra: extra);
      },
      appBar: CustomAppBar(
        title: BaseStatelessConsumer<ProjectDetailsProvider>(
          provider: projectDetailsProvider,
          builder: (context, provider, ref) {
            return Text(
              "Observations ${provider.observationTotalRecords != 0 ? "(${provider.observationTotalRecords})" : ""}",
            );
          },
        ),

        onBack: (value) async {
          ref.read(calledFromOption.notifier).state = "MOB_CLOSE_OBSERVATION";
          return true;
        },
      ),
      virtualFloatingActionButton: BaseStatelessConsumer(
          provider: projectDetailsProvider,
          builder: (context, provider, ref){
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    heroTag: "Filter",
                    child: Icon(Icons.filter_list,color: bayaInfraWhiteColor,),
                    onPressed: () {
                      BaseBottomSheet.show(
                        context: context,
                        child: bottomFilterForm(context: context, provider: provider),
                      );
                    }
                ),
                SizedBox(width: 8,),
                FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    heroTag: "Dashboard",
                    child: Icon(Icons.filter_alt_outlined,color: bayaInfraWhiteColor,),
                    onPressed: (){
                      BaseBottomSheet.show(
                        showSlideLine: false,
                        barrierDismissible: false,
                        enableDrag: false,
                        context: context,
                        isScrollControlled: true,
                        child: filterFormWidget(),
                      );
                    }
                ),



              ],
            ),
          );
        }
      ),
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //           child: Text(
            //             "Observations ${provider.observationTotalRecords != 0 ? "(${provider.observationTotalRecords})" : ""}",
            //             style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //                 fontSize: 18),
            //           ),
            //         ),
            //       ),
            //       Card(
            //         color: Theme.of(context).cardColor,
            //         shape: const RoundedRectangleBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(16))),
            //         child: IconButton(
            //           onPressed: () => BaseBottomSheet.show(
            //             context: context,
            //             child: bottomFilterForm(context: context, provider: provider),
            //           ),
            //           icon: Icon(Icons.sort_outlined,
            //               color: Theme.of(context).colorScheme.primary),
            //         ),
            //       ),
            //       const SizedBox(width: 4),
            //       Card(
            //         color: Theme.of(context).cardColor,
            //         shape: const RoundedRectangleBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(16))),
            //         child: IconButton(
            //           onPressed: () => BaseBottomSheet.show(
            //             showSlideLine: false,
            //             barrierDismissible: false,
            //             enableDrag: false,
            //             context: context,
            //             child: filterFormWidget(),
            //           ),
            //           icon: Icon(Icons.filter_alt_outlined,
            //               color: Theme.of(context).colorScheme.primary),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).highlightColor,
                onRefresh: () async => provider.onRefreshObsAction(),
                child: !provider.observationFetched
                    ? const SizedBox()
                    : provider.observationList.isEmpty
                    ? EmptyListView(
                    emptyText: "There are no pending observations in this project yet",
                )
                    : ListView.builder(
                  controller: provider.obsScrollController,
                  itemCount: provider.observationList.length,
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics()),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        GoRouter.of(context).push(
                          AppRoutes.closeObservation,
                          extra: {
                            'observationId': provider.observationList[index].id ?? 0,
                            'projectId': provider.projectId,
                          },
                        );
                      },
                      child: Column(
                        children: [
                          ObservationCard(index: index),
                          Visibility(
                            visible: (provider.observationList.length - 1) == index,
                            child: const SizedBox(height: 50),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }


  filterFormWidget() {
    final DateTime now = DateTime.now();
    final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
    return BaseStatelessConsumer(
      provider: projectDetailsProvider,
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


                    Visibility(
                      visible: (provider.projectDetailList.last.reportingToYN  == "Y" || provider.isSuperUser)
                          ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [


                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text("Show only my observation",style: Theme.of(context).textTheme.titleMedium,),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: provider.obsViewOtherTransactionYN,
                            onChanged: (val) {
                              provider.changeObsViewOtherTransactionYN(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: provider.delayedYNObs != "None",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text("Delayed",style: Theme.of(context).textTheme.titleMedium,),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: (provider.tempIsDelayedObs) ??  provider.isDelayedObs,
                            onChanged: (val) {
                              provider.changeIsDelayedObs(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text("Date Range",style: Theme.of(context).textTheme.titleMedium,),
                        ),
                        Switch(
                          activeColor: Theme.of(context).primaryColor,
                          value: (provider.tempDateRangeObs) ??  provider.isDateRangeObs,
                          onChanged: (val) {
                            provider.changeIsShowAllObs(val);
                          },
                        ),
                      ],
                    ),
                    Visibility(
                      visible: (provider.tempDateRangeObs != null) ? !provider.tempDateRangeObs! : !provider.isDateRangeObs,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Created date",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                    color: Theme.of(context).textTheme.titleLarge?.color),
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
  bottomFilterForm({required BuildContext context, required ProjectDetailsProvider provider}){
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
