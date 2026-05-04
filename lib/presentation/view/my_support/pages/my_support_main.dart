import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_elevated_icon_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/view_support_request/view_support_request_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/drop_down_menu_support.dart';
import 'package:interior_design/presentation/view/common/expansion_tile/expansion_tile_for_close_page.dart';
import 'package:interior_design/presentation/view/common/mom_deatil_card.dart';
import 'package:interior_design/presentation/view/common/profile_picture_card.dart';
import 'package:interior_design/presentation/view/common/support/support_detail_common_header.dart';
import 'package:interior_design/presentation/view/common/support/tracking_button.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/dependency_task_card.dart';
import 'package:interior_design/utils/routes.dart';



class MySupportMainWidget extends StatefulWidget {
  const MySupportMainWidget({super.key});

  @override
  State<MySupportMainWidget> createState() => _MySupportMainWidgetState();
}

class _MySupportMainWidgetState extends State<MySupportMainWidget> {
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

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final container = ProviderScope.containerOf(context);
    ViewSupportRequestProvider _viewSupportRequestProvider = container.read(viewSupportRequestProvider);
    return WillPopScope(
      onWillPop: ()async{
        final hasRemarks = _viewSupportRequestProvider.remarksController.text.isNotEmpty
        && _viewSupportRequestProvider.supportListData?.requeststatus != "Closed";
        if (hasRemarks) {
          return await _onWillPop(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          shadowNeeded: true,
          useLeading: true,
          onBack: (context) async {
            final hasRemarks = _viewSupportRequestProvider.remarksController.text.isNotEmpty
            && _viewSupportRequestProvider.supportListData?.requeststatus != "Closed";
            if (hasRemarks) {
              return await _onWillPop(context);
            }
            return true;
          },
          title: BaseConsumer(
              provider: viewSupportRequestProvider,
              builder:  (context,provider,ref)=> Text(
                "View Support Request",
                style: Theme.of(context).textTheme.titleLarge,
              )
          ),
          action: [
            BaseConsumer(
                provider: viewSupportRequestProvider,
                builder: (context,provider,ref) {
                  return ThreeDotMenu(
                    items: [
                      MenuItemModel(
                        title: 'Track Support',
                        icon: Icons.travel_explore,

                        onTap: () {
                          _viewSupportRequestProvider.changePage(1);
                        },
                      ),

                      (provider.supportListData != null
                          && provider.supportListData?.assignedstatuscode != "CLOSED"
                          && provider.supportListData?.requeststatus != "Cancelled"
                          && provider.supportListData?.escalatedByName == provider.userName
                          || provider.isSuperUser)? MenuItemModel(
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
          provider: viewSupportRequestProvider,
          builder: (context,provider,ref) {
            final providerScope = ProviderScope.containerOf(context);
            int currentTabIndex = providerScope.read(mySupportProvider).currentTabIndex;
            Status bottomBarStatus = providerScope.read(mySupportProvider).bottomBarStatus;
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                 provider.scheduleTaskDtlJson.isEmpty
                                      ? SizedBox(height: 0,)
                                      : DependencyTaskCard(
                                    taskTypeHeader: "Request against task schedule",
                                    remainingDays: provider.scheduleTaskDtlJson.first.duration??"",
                                   profilePicture: provider.scheduleTaskDtlJson.isEmpty
                                       ? ""
                                       : provider.scheduleTaskDtlJson.first.taskuserprofileurl ??"",
                                    userName: provider.scheduleTaskDtlJson.first.taskuser??"",
                                    taskName: provider.scheduleTaskDtlJson.first.taskname??"",
                                    taskId: provider.scheduleTaskDtlJson.first.taskid??0,
                                    statusName: provider.scheduleTaskDtlJson.first.status??"",
                                    statusId: provider.scheduleTaskDtlJson.first.statusid??0,
                                   taskStatus:  provider.scheduleTaskDtlJson.first.status??"",
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

                                  SupportDetailCommonHeader(
                                      projectName: provider.supportListData?.projectName.toString(),
                                      assignedTo:  (currentTabIndex == 0 && bottomBarStatus != Status.readyToClose
                                          && ((provider.supportListData?.requeststatus == "PENDING" ||
                                          (provider.supportListData?.assignedstatuscode == "SUBMIT")
                                          || (provider.supportListData?.assignedstatuscode == "CLOSED"
                                              && provider.supportListData?.assignedFromId == provider.loginUserID))))
                                          || ( currentTabIndex == 1 && (provider.supportListData?.requeststatus == "Closed")
                                              || (provider.supportListData?.assignedstatuscode == "CLOSED"))
                                          ? provider.supportListData?.assignedFrom
                                          :(provider.supportListData?.assignedstatuscode == "CANCELLED")
                                            ? provider.supportListData?.escalatedByName == provider.userName
                                              ? "You"
                                              : provider.supportListData?.escalatedByName
                                            :provider.supportListData?.assignedTo,
                                      transNo: provider.supportListData?.transNo,
                                      expectedClosureDate: provider.expectedClosureDate.toString(),
                                    createdLabel: provider.supportListData?.createdLabel ?? "",
                                    statusLabel: provider.supportListData?.statusLabel ?? "",
                                    toUserProfileUrl: (currentTabIndex == 0 && bottomBarStatus != Status.readyToClose
                                        && ((provider.supportListData?.requeststatus == "PENDING" ||
                                        provider.supportListData?.assignedstatuscode == "SUBMIT"
                                            || (provider.supportListData?.assignedstatuscode == "CLOSED"
                                            && provider.supportListData?.assignedFromId == provider.loginUserID))))
                                      || ( currentTabIndex == 1 && (provider.supportListData?.requeststatus == "Closed")
                                                || (provider.supportListData?.assignedstatuscode == "CLOSED"))
                                        ? provider.supportListData?.assignedFromProfileUrl ?? ""
                                        : (provider.supportListData?.assignedstatuscode == "CANCELLED")
                                          ? provider.escalatedByProfileImageURL ?? ""
                                          :provider.supportListData?.assignedToUserProfileUrl ?? "",
                                    loginUserName: provider.supportListData?.escalatedByName,
                                  ),

                                  const SizedBox(height: 20),
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
                                                  title: status == "FORWARD"
                                                      ? "Forwarded remarks" : status == "SUBMIT" ? "Submitted remarks" :
                                                      "Reassigned remarks" ,
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
                  visible: provider.status == Status.readyToClose,
                  child: Form(
                    key: formKey,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      color: Theme.of(context).cardColor,
                      elevation: 0.5,
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
                                maxLines: 3,
                                style: Theme.of(context).textTheme.bodyLarge,
                                isEnabled: true,
                                displayTitle: "",
                                hintText: "Remarks",
                                isRequiredField: true,
                                customValidationMessage: "PLease enter remarks",
                                hintTextNeeded: true,
                              ),
                            ),

                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [


                                  Expanded(
                                    child: BaseElevatedIconButton(
                                      iconWidget: Icon(Icons.swap_horizontal_circle,size: 24,color: bayaInfraGreen,),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      fontSize: 15,


                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30  ),
                                      ),

                                      onPressed: provider.rightsyn == false
                                          ? null
                                          : () {
                                       if(formKey.currentState!.validate()) {
                                         showUserListDialog(
                                             context, userList: provider.ownerDetails,
                                             onForward: (item) {
                                               provider.setSelectedOwner(item);
                                               closeConfirmDialog(
                                                   context: context,
                                                   actionType: 'Reassign Support',
                                                   provider: provider,
                                                   ref: ref,
                                                   title: "Do you want to reassign this support request to ${provider
                                                       .selectedOwner?.name}?",
                                                   subtitle: "${provider
                                                       .supportListData?.transNo}",
                                                   icon: Icon(
                                                     Icons.swap_horizontal_circle,
                                                     size: 36,
                                                     color: bayaInfraGreen,),
                                                   onTapYes: () {
                                                     _submitForm(
                                                         context, provider, ref,
                                                         "Reassign");
                                                   });
                                             });
                                       }
                                      },
                                      text:"Reassign",

                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: BaseElevatedIconButton(
                                      iconWidget: Icon(Icons.check_circle,
                                        size: 24,
                                        color: bayaInfraGreen,),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      fontSize: 15,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30  ),
                                      ),

                                      onPressed: provider.rightsyn == false
                                          ? null
                                          : () {
                                        closeConfirmDialog(
                                            context: context,
                                            actionType: 'Close',
                                            provider: provider,ref: ref,
                                            title: "Do you want to close this support request?",
                                            subtitle: "${provider.supportListData?.transNo}",
                                            icon: Icon(Icons.check_circle,
                                              size: 36,
                                              color: bayaInfraGreen,),
                                            onTapYes: (){
                                              _submitForm(context,provider, ref,"Close");
                                            });
                                      },
                                      text:"Close Request",

                                    ),
                                  ),
                                ],
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
      ),),
    );
  }

  closeConfirmDialog({required BuildContext context,
    required ViewSupportRequestProvider provider,
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

                    // GoRouter.of(context).pop();
                    GoRouter.of(context).pushNamed(
                      provider.isFromNotification
                          ? AppRoutes.successLoaderSupportDirect
                          : AppRoutes.successLoaderMySupport,
                      extra: {
                        'provider': provider,
                        'transNo': "${provider.supportListData?.transNo}",
                        'actionType' : actionType,
                        'title': (actionType == 'Reassign Support')
                            ? "Support request successfully reassigned to ${provider.selectedOwner?.name}"
                            :(actionType ==  "CANCELLED")
                            ? "Support request cancelled successfully"
                            : "Support request closed successfully",
                        'onPressed': () {
                          if(provider.isFromNotification){
                            GoRouter.of(context).go(AppRoutes.home);
                            return;
                          }
                          ref.read(calledFromOption.notifier).state = "MOB_CLOSE_SUPPORT_REQ";

                          final router = GoRouter.of(context);
                          while (router.state.name != AppRoutes.mySupportRequestScreen) {
                            if (!router.canPop()) {
                              return;
                            }
                            router.pop();
                          }
                          ref.read(mySupportProvider).refreshPage();
                        },
                      },
                    );

                    onTapYes();

                  },
                ),
              )
            ],
          )
        ]
    );

  }

  void _submitForm(BuildContext context,
      ViewSupportRequestProvider provider,
      WidgetRef ref,
      String status) {
    if(status == "Close"){
      provider.closeSupportRequest(ref: ref,status: status,
        onSuccess: (){
          ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
        },
      );
    }else if(status == "CANCELLED"){
      provider.cancelSupportRequest(ref: ref,status: status,
        onSuccess: (){
          ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
        },
      );
    }else{
      provider.reassignSupportRequest(ref: ref,status: status,
        onSuccess: (){
          ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
        },
      );
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
