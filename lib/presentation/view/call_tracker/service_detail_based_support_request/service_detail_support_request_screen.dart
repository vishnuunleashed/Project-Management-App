import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/presentation/provider/all_support_request_provider/all_support_request_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_details_support_request/service_details_support_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/service_detail_based_support_request/service_detail_support_main_widget.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/utils/routes.dart';



class ServiceDetailsSupportRequestScreen extends ConsumerStatefulWidget {
  const ServiceDetailsSupportRequestScreen({super.key});

  @override
  ConsumerState<ServiceDetailsSupportRequestScreen> createState() => _AllSupportRequestScreenState();
}

class _AllSupportRequestScreenState extends ConsumerState<ServiceDetailsSupportRequestScreen> with RouteAware {

  @override
  void didPopNext()  {
    Future.microtask(() async {
      final provider = ref.watch(allSupportRequestProvider);
      provider.fetchSupportRequestList(changeStart: true);
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
    return BaseView<ServiceDetailsSupportRequestProvider>(
        initState: (context, provider, ref) {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.initState();

          provider.setNavigationParameters(extra:extra??{});

          provider.getUserDetails();
          provider.initSupScrollListener();
          provider.fetchOwners();
        },
        provider: serviceDetailsSupportRequestProvider,
        appBar: CustomAppBar(
          title: BaseStatelessConsumer<AllSupportRequestProvider>(
            provider: allSupportRequestProvider,
            builder: (context, provider, ref) {
              return Text("Service Support Requests");
            },
          ),
          action: [
            // BaseStatelessConsumer<AllSupportRequestProvider>(
            //     provider: allSupportRequestProvider,
            //     builder: (context,provider,ref){
            //       return Row(
            //         children: [
            //           Card(
            //             color: Theme.of(context).cardColor,
            //             shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.all(Radius.circular(16))
            //             ),
            //             child: IconButton(
            //               onPressed: () {
            //                 BaseBottomSheet.show(
            //                     context: context,
            //                     child: _bottomSupportFilterForm(context: context, provider: provider)
            //                 );
            //               },
            //               icon: Icon(Icons.sort_outlined,
            //                   color: Theme.of(context).colorScheme.primary),
            //             ),
            //           ),
            //           Card(
            //               color: Theme.of(context).cardColor,
            //               shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.all(Radius.circular(16))
            //               ),
            //               child: IconButton(
            //                   onPressed: () {
            //                     BaseBottomSheet.show(
            //                       showSlideLine: false,
            //                       context: context,
            //                       barrierDismissible: false,
            //                       enableDrag: false,
            //                       child: filterSupportFormWidget(),
            //                     );
            //                   },
            //                   icon: Icon(Icons.filter_alt_outlined,
            //                       color: Theme.of(context)
            //                           .colorScheme
            //                           .primary)))
            //         ],
            //       );
            //     })



          ],
        ),
        bottomNavigationBar: (context, provider, ref){
          return  EnumBottomBar<AllObservationAndSupportStatus>(
            items: provider.isFromDashboard
                ? [AllObservationAndSupportStatus.opened,AllObservationAndSupportStatus.delayed]
                : AllObservationAndSupportStatus.values,
            titles: provider.isFromDashboard
                ? ["Opened", "Delayed"]
                : ["Opened", "Delayed", "Closed"],
            icons: provider.isFromDashboard
                ? [Icons.folder_open,Icons.check_circle]
                : [Icons.folder_open, Icons.access_time, Icons.check_circle],
            initialIndex: provider.bottomBarStatus == AllObservationAndSupportStatus.opened ? 0 : provider.bottomBarStatus == AllObservationAndSupportStatus.delayed ?  1 : 2,
            onTabSelected: (status) {
              provider.onTapBottomSelected(status);
            },
          );
        },

        virtualFloatingActionButton: BaseStatelessConsumer(
          provider: allSupportRequestProvider,
          builder: (context, provider, ref) {
            return ExpandableFab(
              bottomPadding: 0,
              distance: 70,
            );
          },
        ),
        builder: (context, provider, ref) {

          return _mainWidget(context, provider, ref) ;


        });
  }

  Widget _mainWidget(BuildContext context,ServiceDetailsSupportRequestProvider provider,WidgetRef ref){
    return Column(
      children: [
        Visibility(
          visible: !provider.isFromDashboard && provider.supportRequestList.isNotEmpty,
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
                  provider.supportRequestList.isEmpty?"":provider.supportRequestList.first.refTransaction?? "",
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: provider.isFromDashboard,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                onTap: () {
                  ProfileImageDialog.show(context: context,
                  imageUrl: provider.userprofileurl ,
                  userName:  provider.raisedUser );

                  },
                    child: CachedNetworkImageWidget(
                      imageUrl:  provider.userprofileurl ,
                      size: 50,
                      userName: provider.raisedUser,

                    ),
                  ),
                SizedBox(width: 4,),
                Text(
                  provider.raisedUser,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),),
        Expanded(
          child: ServiceDetailsSupportRequestMainWidget(),
        )
      ],
    );
  }

  Widget filterSupportFormWidget() {
    final DateTime now = DateTime.now();
    final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
    return BaseStatelessConsumer<AllSupportRequestProvider>(
        provider: allSupportRequestProvider,
        builder: (context, provider, ref) {
          return Form(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0,right: 8.0,left: 8.0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                                        ?.copyWith(color: Theme.of(context).primaryColor),
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
                                return (provider.selectedEscalatedUser == null) ? "Please select user" : null;
                              },
                              controller: provider.supportOwnerController,

                              decoration:  InputDecoration(
                                suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                                hintText: "User",
                                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                                labelStyle: Theme.of(context).textTheme.labelLarge,
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
                          controller: provider.filterSupportPointsController,
                          displayTitle: "Points",
                        ),

                       BaseDropDownButtonFormField<DepartmentDropDownModel>(
                            iconEnabledColor: Theme.of(context).colorScheme.primary,
                            fillColorNeeded: false,
                            label: "Department",
                            labelColor: Theme.of(context).textTheme.titleLarge?.color,
                            hintText: "Select department",
                            initialValue: provider.tempSelectedDept ?? provider.selectedDept,
                            items: provider.filterDepartment,
                            onChanged: (value) {
                              provider.changeDepartment(value!);
                            },
                            builder: (value) {
                              return Text(value.deptName ?? "");
                            },
                          ),


                        SizedBox(
                          height: 8,
                        ),
                        Visibility(
                          visible: (provider.superUserYN) ? true : false,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0,right: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Your support requests only",style: Theme.of(context).textTheme.titleMedium,),
                                Switch(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: provider.isSuperUserSupportOnly,
                                  onChanged: (val) {
                                    provider.changeIsSuperuserSupportOnly(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0,right: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Show all support requests",style: Theme.of(context).textTheme.titleMedium,),
                              Switch(
                                activeColor: Theme.of(context).primaryColor,
                                value: provider.tempIsShowAllSupport ?? provider.isShowAllSupport,
                                onChanged: (val) {
                                  provider.changeIsShowAllSupport(val);
                                },
                              ),
                            ],
                          ),
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
                              (provider.bottomBarStatus == AllObservationAndSupportStatus.closed) ? "Closed date" :"Expected closure date",
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
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


}
