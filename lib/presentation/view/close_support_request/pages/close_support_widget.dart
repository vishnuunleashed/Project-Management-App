
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_elevated_icon_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';

import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/close_support_request/_partials/material_detail_card.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/drop_down_menu_support.dart';

import 'package:interior_design/presentation/view/common/expansion_tile/expansion_tile_for_close_page.dart';
import 'package:interior_design/presentation/view/common/mom_deatil_card.dart';
import 'package:interior_design/presentation/view/common/profile_picture_card.dart';
import 'package:interior_design/presentation/view/common/support/support_detail_common_header.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/dependency_task_card.dart';
import 'package:interior_design/utils/routes.dart';

class CloseSupportMainWidget extends StatefulWidget {
  const CloseSupportMainWidget({super.key});

  @override
  State<CloseSupportMainWidget> createState() => _CloseSupportMainWidgetState();
}

class _CloseSupportMainWidgetState extends State<CloseSupportMainWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await BaseDialog.show<bool>(
      context: context,
      title: "Confirm",
      message: "Unsaved changes will be lost. Continue?",
      actions: [

        Row(
          spacing: 8,
          children: [

            Expanded(
              child: BaseElevatedButton(
                borderRadius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () => GoRouter.of(context).pop(true), // exit
                text:"Yes",
              ),
            ),
            Expanded(
              child: BaseElevatedButton(
                borderRadius: 24,
                backgroundColor: bayaInfraDisabledColor,
                onPressed: () => GoRouter.of(context).pop(false), // stay
                text:"No",
              ),
            ),
          ],
        ),
      ],
    );

    return shouldExit ?? false; // false = don't pop
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    CloseSupportRequestProvider _closeSupportRequestProvider = container.read(closeSupportRequestProvider);
    return WillPopScope(
      onWillPop: () async{
        final hasRemarks = _closeSupportRequestProvider.remarksController.text.isNotEmpty
        && _closeSupportRequestProvider.supportListData?.requeststatus != "Closed";

      if (hasRemarks) {
        return await _onWillPop(context);
      }
      return true; },
      child: RefreshIndicator(
        onRefresh: ()async{
          _closeSupportRequestProvider.fillSupportRequestDetails();
        },
        child: Scaffold(

          appBar: CustomAppBar(
              shadowNeeded: true,
              useLeading: true,
              onBack: (context) async {
                print("Support request status code = ${_closeSupportRequestProvider.supportListData?.requeststatus}");
                final hasRemarks = _closeSupportRequestProvider.remarksController.text.isNotEmpty
                && _closeSupportRequestProvider.supportListData?.requeststatus != "Closed";
                if (hasRemarks) {
                  return await _onWillPop(context); // show confirm
                }
                return true; // exit directly
              },
              title: BaseConsumer(
                  provider: closeSupportRequestProvider,
                  builder:  (context,provider,ref)=> Text(
                    (provider.supportListData?.requeststatus != "Closed")
                        ? (provider.supportListData?.assignedTo == provider.userName || provider.isSuperUser)
                        ? "Close Support Request" : "View Support Request" : "View Support Request",
                  ),
              ),
              action: [

                BaseConsumer(
                  provider: closeSupportRequestProvider,
                  builder: (context,provider,ref) {
                    return ThreeDotMenu(
                      items: [
                        MenuItemModel(
                          title: 'Track Support',
                          icon: Icons.travel_explore,

                          onTap: () {
                            _closeSupportRequestProvider.changePage(1);
                          },
                        ),
                       (provider.supportListData != null
                           && provider.supportListData?.assignedstatuscode != "CLOSED"
                           && provider.supportListData?.requeststatus != "Cancelled"
                           && provider.supportListData?.escalatedByName == provider.userName
                            || provider.isSuperUser)
                           ? MenuItemModel(
                               title: 'Cancel Support',
                               icon: Icons.cancel,
                               onTap: () {
                                 closeConfirmDialog(
                                     context: context,
                                     actionType: "CANCELLED",
                                     provider: provider,ref: ref,
                                     title: "Do you want to cancel this support request",
                                     subtitle: "${provider.supportListData?.transNo}",
                                     icon: Icon(Icons.close,
                                       size: 36,
                                       color: bayaInfraRedColor,),
                                     onTapYes: (){
                                       _submitForm(context,provider, ref,"CANCELLED");
                                     });
                               },
                             )
                           : null,
                        (provider.supportListData != null
                            && provider.supportListData?.assignedstatuscode != "CLOSED"
                            && provider.supportListData?.requeststatus != "Cancelled"
                            && provider.supportListData?.escalatedByName == provider.userName
                            || (provider.supportListData != null
                                && provider.supportListData?.assignedstatuscode != "CLOSED"
                                && provider.supportListData?.requeststatus != "Cancelled"
                                && provider.isSuperUser))?MenuItemModel(
                          title: 'Edit Support',
                          icon: Icons.support_agent,
                          onTap: () {
                            GoRouter.of(context).pushNamed(
                                AppRoutes.addSupportRequest,
                                extra: {
                                  "projectId": provider.supportListData?.projectid??0,
                                  "isFromEditSupport":true,
                                  "supportId": provider.supportListData?.id??0,
                                  "points":provider.requestDescription,
                                  "targetClosureDate":provider.supportListData?.targetClosureDate
                                      ??DateTime.now().toString(),
                                  "owner":provider.supportListData?.assignedTo,
                                  "ccUsers":provider.ccUsers
                                      .map((user) => user.username)
                                      .whereType<String>()
                                      .toList(),
                                  "isCritical":provider.supportListData?.iscriticalyn,
                                }
                            );
                          },
                        ):null
                      ],
                    );
                  }
                ),
              ],

            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Ensures it detects taps on empty space
              onTap: () {
                FocusScope.of(context)
                    .unfocus(); // Dismisses keyboard and removes focus
              },
              child: BaseConsumer(
                provider: closeSupportRequestProvider,
                builder: (context,provider,ref) {
                  final providerScope = ProviderScope.containerOf(context);
                  bool isClosedTab = (providerScope.read(allSupportRequestProvider).bottomBarStatus == AllObservationAndSupportStatus.closed);
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                              visible: provider.ccUsers.isNotEmpty && provider.ccUsersWithUrl.isNotEmpty,
                              child: GenericProfilePictureList(
                                title: "CC members",
                                items: provider.ccUsersWithUrl,

                                scrollController: ScrollController(),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: ScrollConfiguration(
                                  behavior: ScrollBehavior().copyWith(overscroll: false),
                                  child: SingleChildScrollView(
                                    physics: ClampingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if (provider.supportListData != null
                                            && provider.supportListData!.additionalMaterialJson.isNotEmpty)
                                          AdditionalMaterialHeaderCard(
                                            item: provider.supportListData!.additionalMaterialJson.first,
                                            isProjectDepartment: false,
                                            onUpdateQty: () {
                                              ///you can use the commented code for updating quantity.
                                              // showDialog(
                                              //   context: context,
                                              //   builder: (_) => UpdateAdditionalMaterialQtyDialog(
                                              //     item: provider.supportListData!.additionalMaterialJson.first,
                                              //     projectId: provider.projectId,
                                              //     optionId: provider.materialChartParentOptionId
                                              //   )
                                              // );
                                            },
                                          ),
                                        provider.scheduleTaskDtlJson.isEmpty
                                            ? SizedBox(height: 0)
                                            : DependencyTaskCard(
                                          taskTypeHeader: "Request against task schedule",
                                          remainingDays:  provider.scheduleTaskDtlJson.first.duration??'',
                                          profilePicture: (provider.scheduleTaskDtlJson.first.taskuserprofileurl?.isEmpty)?? true
                                              ? ""
                                              : provider.scheduleTaskDtlJson.first.taskuserprofileurl??"",
                                          taskName:  provider.scheduleTaskDtlJson.first.taskname??"",
                                          taskId:  provider.scheduleTaskDtlJson.first.taskid??0,
                                          userName:  provider.scheduleTaskDtlJson.first.taskuser??"",
                                          taskStatus:provider.scheduleTaskDtlJson.first.status??"",
                                          onTap: (){
                                            GoRouter.of(context).pushNamed(
                                              AppRoutes.taskDetailFromCloseSupport,
                                              extra: {
                                                "projectName": provider.supportListData?.projectName,
                                                "taskId": provider.scheduleTaskDtlJson.first.id,
                                                "isFromSupport": true,
                                                "taskName":"",
                                                "projectId":provider.projectId,
                                                "isFromLoggedInUser": (provider.loginUserID != provider.scheduleTaskDtlJson.first.taskuserid),
                                                "predecessorData": null,


                                              },
                                            );
                                          },

                                        ),
                                        SizedBox(height: 8,),

                                        if (provider.supportListData != null && provider.supportListData?.momJson != null &&
                                            provider.supportListData!.momJson.isNotEmpty)...[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                                            child: InkWell(
                                              onTap: (){
                                                GoRouter.of(context).pushNamed(AppRoutes.addMOMScreen, extra: {
                                                  "projectId": provider.projectId,
                                                  "momId": provider.supportListData?.momJson.first.id,
                                                  "editMode": true
                                                });
                                              },
                                              child: MomDetailCard(
                                                meetingTitle: provider.supportListData?.momJson.first.meetingtitle ?? "—",
                                                dateTime: provider.supportListData?.momJson.first.datetime,
                                                actionItem: provider.supportListData?.momJson.first.actionitem,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8,),
                                        ],
                                        provider.fromProjectSchedule
                                            ? SupportDetailCommonHeader(
                                                projectName: !provider.isFromCallTracker
                                                    ? provider.supportListData?.projectName
                                                    : provider.supportListData?.reftransaction,
                                                assignedTo:  ((provider.supportListData?.requeststatus == "PENDING" ||
                                                        (provider.supportListData?.assignedstatuscode == "SUBMIT")
                                                        || (provider.supportListData?.assignedstatuscode == "CLOSED"
                                                            && provider.supportListData?.assignedFromId == provider.loginUserID)))
                                                    || (provider.supportListData?.requeststatus == "Closed")
                                                        || (provider.supportListData?.assignedstatuscode == "CLOSED")
                                                    ? provider.supportListData?.assignedFrom
                                                    : (provider.supportListData?.assignedstatuscode == "CANCELLED")
                                                    ? provider.supportListData?.assignedFromId == provider.loginUserID
                                                    ? "You"
                                                    :provider.supportListData?.assignedFrom
                                                    :provider.supportListData?.assignedTo,
                                                transNo: provider.supportListData?.transNo,
                                                expectedClosureDate: provider.expectedClosureDate.toString(),
                                                createdLabel: provider.supportListData?.createdLabel ?? "",
                                                statusLabel: provider.supportListData?.statusLabel ?? "",
                                                toUserProfileUrl:  ((provider.supportListData?.requeststatus == "PENDING" ||
                                                        provider.supportListData?.assignedstatuscode == "SUBMIT"
                                                        || (provider.supportListData?.assignedstatuscode == "CLOSED"
                                                            && provider.supportListData?.assignedFromId == provider.loginUserID)))
                                                    || (provider.supportListData?.requeststatus == "Closed")
                                                        || (provider.supportListData?.assignedstatuscode == "CLOSED")
                                                    ? provider.supportListData?.assignedFromProfileUrl ?? ""
                                                    : (provider.supportListData?.assignedstatuscode == "CANCELLED")
                                                      ?provider.supportListData?.assignedFromProfileUrl ?? ""
                                                      :provider.supportListData?.assignedToUserProfileUrl ?? "",
                                                loginUserName: provider.supportListData?.assignedFrom,
                                              )
                                            : SupportDetailCommonHeader(
                                            projectName: !provider.isFromCallTracker
                                                ? provider.supportListData?.projectName
                                                : provider.supportListData?.reftransaction,
                                            assignedTo:provider.supportListData?.assignedstatuscode == "CLOSED"
                                                ?provider.supportListData?.closedBy
                                                :isClosedTab
                                                  ? provider.supportListData?.assignedFrom ??""
                                                  : provider.supportListData?.assignedTo,
                                            transNo: provider.supportListData?.transNo,
                                            expectedClosureDate: provider.expectedClosureDate.toString(),
                                          toUserProfileUrl: provider.supportListData?.assignedstatuscode == "CLOSED"
                                              ? provider.supportListData?.closedbyprofileurl??""
                                              : isClosedTab
                                              ? provider.supportListData?.assignedFromProfileUrl ??""
                                              : provider.supportListData?.assignedToUserProfileUrl ?? "",
                                          createdLabel: provider.supportListData?.createdLabel ?? "",
                                          statusLabel: provider.supportListData?.statusLabel ?? "",
                                          loginUserName: provider.supportListData?.assignedFrom,
                                        ),

                                        // Points Card Widget
                                        Builder(
                                          builder: (context) {
                                            String status = provider.assignedStatusCode;
                                            bool showLastRemarks = status == "FORWARD" || status == "REASSIGNED" || status == "SUBMIT";
                                            return Column(
                                              children: [
                                                Visibility(
                                                    visible: showLastRemarks,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: CustomExpandableCard(
                                                      title: status == "FORWARD"?"Forwarded remarks": status == "SUBMIT" ? "Submitted remarks" : "Reassigned remarks",
                                                      content: provider.assignedRemarks,
                                                      trimLength: 500,
                                                      minHeightFactor: 0.14,
                                                      showCopyButton: true,
                                                    ),
                                                  ),
                                                ),
                                                // Points Card Widget
                                                CustomExpandableCard(
                                                  title: "Points",
                                                  content: provider.requestDescription,
                                                  trimLength: !showLastRemarks
                                                      ? 500
                                                      : 250,
                                                  minHeightFactor: !showLastRemarks
                                                      ? 0.28
                                                      : 0.14,
                                                  showCopyButton: true,
                                                ),
                                              ],
                                            );
                                          }
                                        ),


                                        SizedBox(height: 192),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: (provider.supportListData?.requeststatus != "Closed")
                            ? (provider.supportListData?.assignedTo == provider.userName || provider.isSuperUser) ? true : false : false,
                        child: Form(
                          key: formKey,
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            elevation: 0.5,
                            color: Theme.of(context).cardColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8,right: 8,top: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: BaseTextField(

                                      controller: provider.remarksController,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      isEnabled: provider.rightsyn,
                                      displayTitle: "",
                                      customValidationMessage: "Please enter Remarks",
                                      hintText: "Remarks",
                                      maxLength: 2000,
                                      isAutoValidateMode: true,
                                      isRequiredField: true,
                                      hintTextNeeded: true,
                                    ),
                                  ),

                                  Visibility(
                                    visible: provider.rightsyn == false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text("Support request cannot be closed since you have no rights.",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                              color: bayaInfraRedColor
                                          )),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Action buttons
                                  Visibility(
                                    visible: (provider.supportListData?.requeststatus != "Closed")
                                        ? (provider.supportListData?.assignedTo == provider.userName
                                        || provider.isSuperUser) ? true : false : false,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [


                                          Expanded(
                                            child: BaseElevatedIconButton(
                                              iconWidget: (provider.supportListData?.assignedstatus == "Submitted") ? Icon(Icons.compare_arrows,size: 24,color: bayaInfraGreen,) : Icon(Icons.forward,size: 24,color: bayaInfraGreen,),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              fontSize: 15,


                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30  ),
                                              ),

                                              onPressed: provider.rightsyn == false
                                                  ? null
                                                  : () {
                                                if(!formKey.currentState!.validate()){
                                                  return;
                                                }
                                               if(provider.isFromCallTracker){
                                                 showSelectionDialog<EmployeeModel>(
                                                   context,
                                                   items: provider.employeeList.where((item) => item.id != provider.supportListData!.escalatedById).toList(),
                                                   getDisplayName: (employee) => employee.name,
                                                   onSelect: (employee) {
                                                     provider.setSelectedEmployee(employee);
                                                     GoRouter.of(context).pop();
                                                     closeConfirmDialog(
                                                         context: context,
                                                         actionType: (provider.supportListData?.assignedstatus == "Submitted") ? "Reassign Support" :'Forward Support',
                                                         provider: provider,ref: ref,
                                                         title: "Do you want to ${(provider.supportListData?.assignedstatus == "Submitted") ? "reassign" : "forward"}  this support request to ${provider.selectedEmployee?.name}?",
                                                         subtitle: "${provider.supportListData?.transNo}",
                                                         icon: (provider.supportListData?.assignedstatus == "Submitted") ?
                                                         Icon(Icons.forward,
                                                           size: 36,
                                                           color: bayaInfraGreen,)
                                                             : Icon(Icons.forward,
                                                           size: 36,
                                                           color: bayaInfraGreen,),
                                                         onTapYes: (){
                                                           _submitForm(context,provider, ref,(provider.supportListData?.assignedstatus == "Submitted") ? "Reassigned" : "Forward");
                                                         });

                                                   },
                                                   title: "Select Employee",
                                                   searchHint: "Search employee",
                                                 );
                                               }else{
                                                 showUserListDialog(context,userList: provider.ownerDetails,
                                                     onForward: (item){
                                                       provider.setSelectedOwner(item);
                                                       closeConfirmDialog(
                                                           context: context,
                                                           actionType: (provider.supportListData?.assignedstatus == "Submitted") ? "Reassign Support" :'Forward Support',
                                                           provider: provider,ref: ref,
                                                           title: "Do you want to ${(provider.supportListData?.assignedstatus == "Submitted") ? "reassign" : "forward"}  this support request to ${provider.selectedOwner?.name}?",
                                                           subtitle: "${provider.supportListData?.transNo}",
                                                           icon: (provider.supportListData?.assignedstatus == "Submitted") ?
                                                           Icon(Icons.forward,
                                                             size: 36,
                                                             color: bayaInfraGreen,)
                                                               : Icon(Icons.forward,
                                                             size: 36,
                                                             color: bayaInfraGreen,),
                                                           onTapYes: (){
                                                             _submitForm(context,provider, ref,(provider.supportListData?.assignedstatus == "Submitted") ? "Reassign" : "Forward");
                                                           });
                                                     });

                                               }

                                              },
                                              text:(provider.supportListData?.assignedstatus == "Submitted") ? "Reassign" : "Forward",

                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                              child: BaseElevatedIconButton(
                                                iconWidget: Icon(Icons.check_circle,
                                                  size: 24,
                                                  color:bayaInfraGreen,),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                fontSize: 15,

                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30  ),
                                                ),

                                                onPressed: provider.rightsyn == false
                                                    ? null
                                                    : () {
                                                  if( (provider.supportListData?.assignedstatus  != "Submitted")
                                                      && !formKey.currentState!.validate()){
                                                    return;
                                                  }
                                                  closeConfirmDialog(
                                                      context: context,
                                                      actionType: (provider.supportListData?.assignedstatus == "Submitted") ? 'Close' : 'Submit',
                                                      provider: provider,ref: ref,
                                                      title: (provider.supportListData?.assignedstatus == "Submitted") ? "Do you want to close this support request" : "Do you want to submit this support request to ${provider.supportListData?.escalatedByName}?",
                                                      subtitle: "${provider.supportListData?.transNo}",
                                                      icon: Icon(Icons.check_circle,
                                                        size: 36,
                                                        color: bayaInfraGreen,),
                                                      onTapYes: (){
                                                        _submitForm(context,provider, ref,(provider.supportListData?.assignedstatus == "Submitted") ? "Close" : "Submit");
                                                      });
                                                },
                                                text:(provider.supportListData?.assignedstatus == "Submitted") ? "Close" : "Submit",

                                              ),
                                            ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),

        ),
      ),
    );
  }

  closeConfirmDialog({required BuildContext context,
    required CloseSupportRequestProvider provider,
    required WidgetRef ref,
    required String title,
    required String actionType,
    required String subtitle,
    required Function() onTapYes,
    required Widget icon}){

    return BaseDialog.show(
        context: context,
        title: "Confirm",
        message: title,
        subtitle: subtitle,
        icon: icon,
        actions: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                  child: BaseElevatedButton(
                    borderRadius: 24,
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    backgroundColor: bayaInfraDisabledColor,
                    text: "No",
                  )),

              Expanded(
                  child: BaseElevatedButton(
                    borderRadius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    text:"Yes",
                    onPressed: () {
                      print("Action Type $actionType");
                      // GoRouter.of(context).pop();
                      GoRouter.of(context).pushNamed(
                        provider.isFromNotification
                            ? AppRoutes.successLoaderSupportDirect
                            : AppRoutes.successLoaderSupport,
                        extra: {
                          'provider': provider,
                          'transNo': "${provider.supportListData?.transNo}",
                          'actionType' : actionType,
                          'title': (actionType == 'Forward Support') ? "Support request successfully forwarded to ${provider.isFromCallTracker?provider.selectedEmployee?.name:provider.selectedOwner?.name}"
                              : (actionType == "Reassign Support") ? "Support request successfully reassigned to ${provider.isFromCallTracker?provider.selectedEmployee?.name:provider.selectedOwner?.name}"
                              : (actionType == "Submit") ? "Support request successfully submitted to ${provider.supportListData?.escalatedByName}"
                              : (actionType == 'CANCELLED') ?"Support request successfully cancelled" :"Support request successfully closed"
                          ,
                          // "prevRoute": provider.prevRoute,
                          // "screenExtra" : provider.screenExtra,
                          // 'onPressed': (routePath, extra) {
                          'onPressed': () {
                            if(provider.isFromNotification){
                              GoRouter.of(context).go(AppRoutes.home);
                              return;
                            }
                            ref.read(calledFromOption.notifier).state = "MOB_CLOSE_SUPPORT_REQ";
                            // if(provider.isFromCallTracker){
                            //   final router = GoRouter.of(context);
                            //   while (router.state.name != AppRoutes.serviceCallTrackerDetailViewDirect) {
                            //     if (!router.canPop()) {
                            //       return;
                            //     }
                            //     router.pop();
                            //   }
                            // }else{
                              GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                              GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                              GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                            // }
                          },
                        },
                      );

                      onTapYes();

                    },
                  ))
            ],
          )
        ]
    );

  }

  void _submitForm(BuildContext context,CloseSupportRequestProvider provider, WidgetRef ref,String status) {
    if(status == 'Submit'){
      provider.submitSupportRequest(ref: ref,status: status,onSuccess: (){
        if(provider.isFromNotification){
          final container = ProviderScope.containerOf(context);
          HomeProvider _homeProvider = container.read(homeProvider);
          _homeProvider.fetchPendingCount(projectIds: [
            provider.supportListData ==null
                ? 0
                :provider.supportListData?.projectid??0]);
        }
        ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      });
    }else if(status == "Forward"){
      provider.forwardSupportRequest(ref: ref,status: status,onSuccess: (){
        if(provider.isFromNotification){
          final container = ProviderScope.containerOf(context);
          HomeProvider _homeProvider = container.read(homeProvider);
          _homeProvider.fetchPendingCount(projectIds: [
            provider.supportListData ==null
                ? 0
                :provider.supportListData?.projectid??0]);
        }
        ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      });
    }
    else if(status == "Reassign"){
      provider.reassignedSupportRequest(ref: ref, status: status, onSuccess: (){
        if(provider.isFromNotification){
          final container = ProviderScope.containerOf(context);
          HomeProvider _homeProvider = container.read(homeProvider);
          _homeProvider.fetchPendingCount(projectIds: [
            provider.supportListData ==null
                ? 0
                :provider.supportListData?.projectid??0]);
        }
        ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      });
    }else if(status == "CANCELLED"){
      provider.cancelSupportRequest(ref: ref, status: status, onSuccess: (){
        if(provider.isFromNotification){
          final container = ProviderScope.containerOf(context);
          HomeProvider _homeProvider = container.read(homeProvider);
          _homeProvider.fetchPendingCount(projectIds: [
            provider.supportListData ==null
                ? 0
                :provider.supportListData?.projectid??0]);
        }
        ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      });
    }
    else{
      provider.closeSupportRequest(ref: ref, status: status, onSuccess: (){
        if(provider.isFromNotification){
          final container = ProviderScope.containerOf(context);
          HomeProvider _homeProvider = container.read(homeProvider);
          _homeProvider.fetchPendingCount(projectIds: [
            provider.supportListData ==null
                ? 0
                :provider.supportListData?.projectid??0]);
        }
        ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      });
    }
  }

  void onSaveDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String message,
    required VoidCallback onClick,
  }) {
    showDialogBox(
        context: context,
        title: title,
        titleIcon: icon,
        message: message,
        action: onClick,
        buttonType: DialogButtonType.okOnly);
  }
}


