/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    : Support request List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/utility/base_top_sheet.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/follow_button.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_details/partials/support_request_card.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:go_router/go_router.dart';

class SupportRequestListScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const SupportRequestListScreen({super.key, this.extra});

  @override
  ConsumerState<SupportRequestListScreen> createState() => _SupportRequestListScreenState();
}

class _SupportRequestListScreenState extends ConsumerState<SupportRequestListScreen> with RouteAware {

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
      await ref.read(projectDetailsProvider.notifier).fetchSupportRequestList();
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
        provider.initState(extra:extra);
      },
      appBar: CustomAppBar(
        title: Text(
          "Support Requests",
        ),
        onBack: (value) async {
          ref.read(calledFromOption.notifier).state = "MOB_CLOSE_SUPPORT_REQ";
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
                              height: MediaQuery.of(context).size.height * 0.45,
                              context: context,
                              child: _bottomFilterForm(context: context,provider: provider)
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
                            height: MediaQuery.of(context).size.height * 0.75,
                            showSlideLine: false,
                            barrierDismissible: false,
                            enableDrag: false,
                            context: context,
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
              //   padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //               child: Text(
              //                 "Support requests ${provider.supportRequestTotalRecords != 0 ?"(${provider.supportRequestTotalRecords})" : ""}",
              //                 style: Theme.of(context).textTheme.titleMedium
              //                     ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //
              //
              //     ],
              //   ),
              // ),
              Expanded(
                child: RefreshIndicator(
                  color:Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).highlightColor,
                  onRefresh: (){
                    return provider.onRefreshSptAction();
                  },
                  child:(provider.supportRequestFetched) ? (provider.supportRequestList.isEmpty)
                      ? EmptyListView(
                    emptyText: "There are no pending support requests in this project yet",

                  )
                      : ListView.builder(
                    controller: provider.supScrollController,
                    itemCount: provider.supportRequestList.length,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              // TO pass Support request id
                              int supportRequestId = provider.supportRequestList[index].id ?? 0;
                              GoRouter.of(context).push(AppRoutes.closeSupportRequest, extra: {'supportRequestId': supportRequestId});

                            },
                            child: Column(
                              children: [
                                SupportRequestCard(index: index,),
                                Visibility(
                                    visible: (provider.supportRequestList.length - 1) == index ,
                                    child: SizedBox(height: 50, ))
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: FollowButton(
                              axis: Axis.vertical,
                              isCritical: provider
                                  .supportRequestList[index].iscriticalyn == "Y",
                              isFollowed:  (provider
                                  .supportRequestList[index].notifyuseryn == "Y"
                                  &&  provider.supportRequestList[index].addedbycreatoryn == "N")
                                  && provider.supportRequestList[index].requestStatusCode == "PENDING",
                              isBlocked: ((provider
                                  .supportRequestList[index].escalatedBy == provider.userName)
                                  && provider.supportRequestList[index].requestStatusCode == "PENDING")
                                  || provider.supportRequestList[index].requestStatusCode != "PENDING",
                              isCC:  (provider
                                  .supportRequestList[index].notifyuseryn == "Y"
                                  &&  provider.supportRequestList[index].addedbycreatoryn == "Y"),
                              onFollow: () {
                                int supportRequestId = provider
                                    .supportRequestList[index].id ??
                                    0;
                                provider.followSupportRequest(supportId: supportRequestId,onRequestSuccess: (){
                                  provider.updateSupportListForFollow(index);
                                });

                              },
                              onUnfollow: (){
                                int supportRequestId = provider
                                    .supportRequestList[index].id ??
                                    0;
                                provider.unFollowSupportRequest(
                                    supportId: supportRequestId,onRequestSuccess: (){
                                  provider.updateSupportListForUnFollow(index);
                                });

                              },

                            ),
                          ),
                        ],
                      );
                    },
                  ) : Container(),
                ),
              ),
              SizedBox(height: 8,)
            ],
          );
        }
    );
  }


  Widget filterFormWidget() {
    final DateTime now = DateTime.now();
    final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
    return BaseStatelessConsumer<ProjectDetailsProvider>(
        provider: projectDetailsProvider,
        builder: (context, provider, ref) {
          return Form(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0,right: 8.0,left: 8.0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                        .titleLarge,
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
                                  provider.clearSupportReqFilter(isFromClearButton: false);
                              },
                            ),
                          ],
                        ),
                        Divider(),
                        GestureDetector(
                          onTap: (){
                            showUserListDialog(
                                title: "Escalated user",
                                context,
                                userList: provider.owners,
                                // names: provider.namesFromOwnerModel,
                                onForward: (value){
                                  provider.setSelectedEscalated(value);
                                  GoRouter.of(context).pop();
                                });
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              validator: (val){
                                return (provider.selectedEscalatedUser == null) ? "Please select an Escalated User" : null;
                              },
                              controller: provider.supportOwnerController,
                              style: Theme.of(context).textTheme.titleSmall,
                              decoration:  InputDecoration(
                                suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                                hintText: "Escalated User",
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
                        // Text("Request Type",style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        //     fontWeight: FontWeight.w500
                        // ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 8),
                        //   child: GestureDetector(
                        //     onTap: (){
                        //       showSelectionDialog(
                        //           title: "Request Type",
                        //           context,
                        //           getDisplayName: (value) => value.description??"",
                        //           items: provider.supportTypeList,
                        //           onSelect: (value){
                        //             provider.setSelectSupportType(value);
                        //             GoRouter.of(context).pop();
                        //           });
                        //     },
                        //     child: AbsorbPointer(
                        //       child: TextFormField(
                        //         validator: (val){
                        //           return (provider.supportType == null) ? "Please select a type" : null;
                        //         },
                        //         controller: provider.supportTypeStatusController,
                        //
                        //         decoration:  InputDecoration(
                        //           suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                        //           // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                        //           hintText: "Request Type",
                        //           hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        //             color: Theme.of(context).disabledColor,
                        //             fontWeight: FontWeight.w400,
                        //           ),
                        //           labelStyle: Theme.of(context).textTheme.labelLarge,
                        //           disabledBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                 width: 0.54,),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           focusedBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                   width: 0.54,
                        //                   color: Theme.of(context).colorScheme.primary),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           errorBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0.54, color: bayaInfraRedColor),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           focusedErrorBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0.54, color: bayaInfraRedColor),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           enabledBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                   width: 0.54,
                        //                   color: provider.observationTypeList.isEmpty
                        //                       ? Theme.of(context)
                        //                       .disabledColor
                        //                       .withValues(alpha: 0.5)
                        //                       : Theme.of(context).colorScheme.primary),
                        //               borderRadius: BorderRadius.circular(10)),
                        //         ),
                        //
                        //         onTap: (){
                        //         },
                        //
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        //
                        // Text("Status",style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        //     fontWeight: FontWeight.w500
                        // ),
                        // ),
                        // const SizedBox(height: 8,),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 8),
                        //   child: GestureDetector(
                        //     onTap: (){
                        //         showSelectionDialog(
                        //           title: "Status",
                        //           context,
                        //           getDisplayName: (value) => value.description??"",
                        //           items: provider.listOfStatusSupport,
                        //           onSelect: (value){
                        //           provider.setSelectStatusSupport(value);
                        //           GoRouter.of(context).pop();
                        //         });
                        //     },
                        //     child: AbsorbPointer(
                        //       child: TextFormField(
                        //         validator: (val){
                        //           return (provider.selectedStatusSupport == null) ? "Please select status" : null;
                        //         },
                        //         controller: provider.supportStatusController,
                        //
                        //         decoration:  InputDecoration(
                        //           suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                        //           // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                        //           hintText: "Status",
                        //           hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        //             color: Theme.of(context).disabledColor,
                        //             fontWeight: FontWeight.w400,
                        //           ),
                        //           labelStyle: Theme.of(context).textTheme.labelLarge,
                        //           disabledBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                 width: 0.54,),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           focusedBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                   width: 0.54,
                        //                   color: Theme.of(context).colorScheme.primary),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           errorBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0.54, color: bayaInfraRedColor),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           focusedErrorBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0.54, color: bayaInfraRedColor),
                        //               borderRadius: BorderRadius.circular(10)),
                        //           enabledBorder: OutlineInputBorder(
                        //               borderSide: BorderSide(
                        //                   width: 0.54,
                        //                   color: provider.listOfStatusSupport.isEmpty
                        //                       ? Theme.of(context)
                        //                       .disabledColor
                        //                       .withValues(alpha: 0.5)
                        //                       : Theme.of(context).colorScheme.primary),
                        //               borderRadius: BorderRadius.circular(10)),
                        //         ),
                        //
                        //         onTap: (){
                        //         },
                        //
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        BaseDropDownButtonFormField<DepartmentDropDownModel>(
                          iconEnabledColor: Theme.of(context).colorScheme.primary,
                          fillColorNeeded: false,
                          label: "Department",
                          labelColor: Theme.of(context).textTheme.titleLarge?.color,
                          hintText: "Select department",
                          initialValue: provider.tempSelectedDept ?? provider.selectedDept,
                          items: provider.departmentList,
                          onChanged: (value) {
                            provider.changeDepartment(value!);
                          },
                          builder: (value) {
                            return Text(value.deptName ?? "");
                          },
                        ),
                        SizedBox(height: 8,),
                        BaseDropDownButtonFormField<DepartmentDropDownModel>(
                          iconEnabledColor: Theme.of(context).colorScheme.primary,
                          fillColorNeeded: false,
                          label: "Dependency Department",
                          labelColor: Theme.of(context).textTheme.titleLarge?.color,
                          hintText: "Select dependency department",
                          initialValue: provider.tempSelectedDependencyDept ?? provider.selectedDependencyDept,
                          items: provider.departmentList,
                          onChanged: (value) {
                            provider.changeDependencyDepartment(value!);
                          },
                          builder: (value) {
                            return Text(value.deptName ?? "");
                          },
                        ),
                        BaseTextField(
                          controller: provider.filterSupportPointsController,
                          displayTitle: "Points",
                        ),


                        SizedBox(
                          height: 8,
                        ),
                        Visibility(
                          visible: (provider.projectDetailList.first.reportingToYN == "Y" || provider.isSuperUser) ? true : false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Show only my support requests",style: Theme.of(context).textTheme.titleMedium,),
                              Switch(
                                activeColor: Theme.of(context).primaryColor,
                                value: provider.supViewOtherTransactionYN,
                                onChanged: (val) {
                                  provider.changeSupViewOtherTransactionYN(val);
                                },
                              ),
                            ],
                          ),
                        ),

                        Visibility(
                          visible: provider.delayedYNSupport != "None",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Text("Delayed",style: Theme.of(context).textTheme.titleMedium,),
                              ),
                              Switch(
                                activeColor: Theme.of(context).primaryColor,
                                value: (provider.tempIsDelayedSupport) ??  provider.isDelayedSupport,
                                onChanged: (val) {
                                  provider.changeIsDelayedSupport(val);
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date Range",style: Theme.of(context).textTheme.titleMedium,),
                            Switch(
                              activeColor: Theme.of(context).primaryColor,
                              value: provider.tempIsShowAllSupport ?? provider.isShowAllSupport,
                              onChanged: (val) {
                                provider.changeIsShowAllSupport(val);
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0,right: 4),
                          child: Visibility(
                            visible:(provider.tempIsShowAllSupport != null) ? !provider.tempIsShowAllSupport! : !provider.isShowAllSupport,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Expected closure date",
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
                                          provider.changeClosureDateFrom(date);
                                        },
                                        initialDate: provider.tempClosureDateFrom ?? provider.closureDateFrom,
                                        lastDate: provider.tempClosureDateTo ?? provider.closureDateTo,
                                        subtitle: "Date from",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: BaseDatesPicker(
                                        onChange: (date) {
                                          provider.changeClosureDateTo(date);
                                        },
                                        initialDate: provider.tempClosureDateTo ?? provider.closureDateTo,
                                        firstDate: provider.tempClosureDateFrom ?? provider.closureDateFrom ,
                                        lastDate: twoYearsLater,
                                        subtitle: "Date to",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: BaseElevatedButton(
                                    onPressed: () {
                                      provider.setSptRangeFilterApplied(false);
                                      provider.clearSupportReqFilter(isFromClearButton: true);
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
                                      GoRouter.of(context).pop();
                                      provider.setSptRangeFilterApplied(false);
                                      provider.setIsShowAllSupport();
                                      provider.setSelectedDepartment();
                                      provider.setSelectedDependencyDepartment();
                                      provider.setSptFilterDateField();
                                      provider.fetchSupportRequestList(changeStart: true);
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
        });
  }

  Widget _bottomFilterForm({required BuildContext context, required ProjectDetailsProvider provider}){
    return SingleChildScrollView(
      child: Column(
        children: [
          DateRangeTile(
            label: "Last Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Last Week"){
                print("If case worked");
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                print("Selected Range label = ${provider.selectedObsRangeLabel}");
                print("Else case worked");
                provider.setLastWeek(isSupport: true);
                print("Selected Range label = ${provider.selectedObsRangeLabel}");
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "This Week"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
              provider.setThisWeek(isSupport:true);
              GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Next Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Next Week"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setNextWeek(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Last Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Last Month"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setLastMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "This Month"){
                print("If case worked");
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                print("Else case worked");
                provider.setThisMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Next Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Next Month"){
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setNextMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),

        ],
      ),
    );
  }
}
