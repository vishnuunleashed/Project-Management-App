import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation_export.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/close_observation/close_observation_provider.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/expansion_tile/expansion_tile_for_close_page.dart';
import 'package:interior_design/presentation/view/common/mom_deatil_card.dart';
import 'package:interior_design/presentation/view/common/observation/observation_detail_common_header.dart';
import 'package:interior_design/utils/routes.dart';

class CloseObservationScreen extends StatefulWidget {
  const CloseObservationScreen({super.key});

  @override
  State<CloseObservationScreen> createState() => _CloseObservationScreenState();
}

class _CloseObservationScreenState extends State<CloseObservationScreen> {
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
            )
          ],
        ),
      ],
    );

    return shouldExit ?? false; // false = don't pop
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context);
    CloseObservationProvider _closeObservationProvider = container.read(closeObservationProvider);

    return WillPopScope(
      onWillPop: () async {
        final hasRemarks = _closeObservationProvider.remarksController.text.isNotEmpty
            && _closeObservationProvider.observationstatuscode != "CLOSED"
            && _closeObservationProvider.observationstatuscode != "NO_ACTION";

        if (hasRemarks) {
          return await _onWillPop(context);
        }
        return true;
      },
      child: BaseView<CloseObservationProvider>(
      provider: closeObservationProvider,
      initState: (context,provider,ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        final observationId = extra?['observationId']??extra?['transid'];

        provider.fromNotification(extra?['transid']!=null);

        int userId = await BaseSecureStorage.getInt(BaseConstants.userID);

        final parsedObservationId =
        observationId is int ? observationId : int.tryParse(observationId?.toString() ?? '');

        if (parsedObservationId != null) {
          provider.setObservationId(parsedObservationId);
        }

       provider.initValues();
        provider.getUserDetails();
        provider.setLoginUserId(userId);
        int projectId = 0;
        if(extra != null && extra["projectId"] != null){
          projectId = int.parse(extra["projectId"].toString());
        }else if (extra != null && extra["transid"] != null){
          projectId = int.parse(extra["transid"].toString());
        }
        provider.setProjectId(projectId);
        provider.fetchStatusTypes();
        provider.fetchObservationDetails();
        provider.fetchActivityGroup();

        if(extra!["notificationid"] != null){
          provider.setNotificationId(extra["notificationid"]);
        }else if(extra["notificationId"] != null){
          provider.setNotificationId(extra["notificationId"]);
        }


      },

        virtualFloatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BaseStatelessConsumer(
              provider: closeObservationProvider,
              builder: (context, provider, ref) {

                return ExpandableFab(
                  bottomPadding: provider.observationList.isNotEmpty
                      && provider.observationList.first.tocloseyn == "Y" ?90:0,
                  distance: 70,

                );
              },
            ),
            Consumer(
                builder: (context, ref, __) {
                  final provider = ref.watch(closeObservationProvider);
                  return Visibility(
                    visible: provider.showActionButtons,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Align(
                          heightFactor: 2,
                          widthFactor: 1,
                          child: FloatingActionButton(
                              elevation: 0,
                              onPressed: () async {
                                final List<File>? files = await MediaServiceWithCrop.instance.pickImage(context,enableCrop: true,enableMultiSelect: true);
                                if (files != null) {
                                  provider.uploadImageFile(files);
                                }
                              },
                              tooltip: 'Add image',
                              child: Icon(Icons.camera_alt)
                          )
                      ),
                    ),
                  );
                }
            )
          ],
        ),
      appBar: CustomAppBar(
        shadowNeeded: true,
          useLeading: true,
          onBack: (context) async {
            final hasRemarks = _closeObservationProvider.remarksController.text.isNotEmpty
                && _closeObservationProvider.observationstatuscode != "CLOSED"
                && _closeObservationProvider.observationstatuscode != "NO_ACTION"
                && _closeObservationProvider.observationList.first.logstatuscode != "REJECTED";
            if (hasRemarks) {
              return await _onWillPop(context); // show confirm
            }
            return true; // exit directly
          },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: BaseConsumer(
            provider: closeObservationProvider,
            builder:  (context,provider,ref)=> Text(
                provider.appBarTitle,
            )
        ),

      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder:(context,provider,ref) {
        final tagUpdateRights = (provider.observationList.isNotEmpty) ?( (provider.isSuperUser || provider.observationList.first.closingauthorityyn == "Y" || provider.observationList.first.ownerid== provider.loginUserId) && provider.observationstatuscode != "CLOSED") : false;
        final isAnyTagExist = (provider.observationList.isNotEmpty) ? (provider.observationList.first.activitygroupid != null || provider.observationList.first.sourceoferrorid != null) : false;
        return provider.observationList.isEmpty
            ? SizedBox(height: 0)
            : GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Ensures it detects taps on empty space
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Dismisses keyboard and removes focus
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (provider.observationList.first.momJson != null &&
                                provider.observationList.first.momJson!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: InkWell(
                                  onTap: (){
                                    GoRouter.of(context).pushNamed(AppRoutes.addMOMScreen, extra: {
                                      "projectId": provider.projectId,
                                      "momId": provider.observationList.first.momJson!.first.id,
                                      "editMode": true
                                    });
                                  },
                                  child: MomDetailCard(
                                    meetingTitle: provider.observationList.first.momJson!.first.meetingtitle ?? "—",
                                    dateTime: provider.observationList.first.momJson!.first.datetime,
                                    actionItem: provider.observationList.first.momJson!.first.actionitem,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8,),
                            ObservationDetailCommonHeader(
                                projectName: provider.projectName,
                                profileUrl: provider.displayProfileUrl,
                                transNo: provider.transNo,
                                selectedDate: provider.selectedDate,
                              observer: provider.displayprofilename,
                                createdLabel: provider.createdLabel,
                                statusLabel: provider.statusLabel,),
                            SizedBox(height: 8,),
                            /// Tags section
                            Visibility(
                              visible: isAnyTagExist || tagUpdateRights,
                              child: Card(
                                color: Theme.of(context).cardColor,
                                margin: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Tags",
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible: tagUpdateRights,
                                            child: InkWell(
                                              onTap: () => _showUpdateTagDialog(context, provider),
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color:Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children:  [
                                                    Icon(Icons.edit_outlined, size: 13, color: Theme.of(context).primaryColor),
                                                    SizedBox(width: 5),
                                                    Text(
                                                       "Update",
                                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                        color: Theme.of(context).primaryColor
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),

                                    // Tags body
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: (provider.observationList.first.activitygroupid == null &&
                                          provider.observationList.first.sourceoferrorid == null)
                                      // Empty state
                                          ? Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "No tags added yet",
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      // Filled state
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 8,
                                      children: [
                                        if (provider.observationList.first.activitygroupid != null)
                                          _buildTagChip(
                                            context: context,
                                            label: provider.observationList.first.activitygroup ?? "",
                                            prefix: "Activity Group",
                                            dotColor: bayaInfraBlue600 ?? Colors.grey, // purple dot
                                          ),
                                        if (provider.observationList.first.sourceoferrorid != null)
                                          _buildTagChip(
                                            context: context,
                                            label: provider.observationList.first.sourceoferror ?? "",
                                            prefix: "Source of Error",
                                            dotColor: bayaInfraLightRedColor, // orange dot
                                          ),
                                      ],
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8,),
                            Visibility(
                              visible: provider.attachmentUrl.isNotEmpty,
                              child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Uploaded images",
                                        style: Theme.of(context).textTheme.titleMedium,

                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.15,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,


                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10)
                                          ),
                                        ),
                                        child: provider.attachmentUrl.length == 1
                                            ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: (){
                                                  _openImageViewer(context,provider.attachmentUrl, provider, 0);
                                                },
                                                child: Center(
                                                   child: _buildImageContainer(
                                                   provider.attachmentUrl.first.url,
                                                   context,
                                                   ),
                                                ),
                                              ),
                                            )
                                            : Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: GridView.builder(
                                                scrollDirection: Axis.horizontal,
                                                physics: BouncingScrollPhysics(),
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                   crossAxisCount: 1,
                                                   mainAxisSpacing: 12,
                                                   childAspectRatio: 1.0,),
                                                itemCount: provider.attachmentUrl.length,
                                                itemBuilder: (context, index) {
                                              final urls = provider.attachmentUrl
                                                  .map((e) => e.url)
                                                  .toList()
                                                  .reversed
                                                  .toList();
                                              return GestureDetector(
                                                onTap: (){
                                                  _openImageViewer(context,provider.attachmentUrl, provider, index);
                                                },
                                                  child: _buildImageContainer(urls[index], context));
                                              },
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                            ),



                            if (provider.attachmentUrlToBeUploaded.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Submitted images",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.15,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,


                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                  ),
                                  child: provider.attachmentUrlToBeUploaded.length == 1
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: (){
                                        _openImageViewer(context,provider.attachmentUrlToBeUploaded, provider, 0);
                                      },
                                      child: Center(
                                        child: _buildImageContainer(
                                          provider.attachmentUrlToBeUploaded.first.url,
                                          context,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.0,),
                                      itemCount: provider.attachmentUrlToBeUploaded.length,
                                      itemBuilder: (context, index) {
                                        final urls = provider.attachmentUrlToBeUploaded
                                            .map((e) => e.url)
                                            .toList()
                                            .reversed
                                            .toList();
                                        return GestureDetector(
                                            onTap: (){
                                              _openImageViewer(context,provider.attachmentUrlToBeUploaded, provider, index);
                                            },
                                            child: _buildImageContainer(urls[index], context));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // Points Card Widget
                            Column(
                              children: [
                                Visibility(
                                  visible: provider.closedRemarksController.text.isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: CustomExpandableCard(
                                      title:  provider.observationList.first.logstatuscode == "REJECTED"
                                          ? "Rejected remarks"
                                          : "Closed remarks",
                                      content: provider.closedRemarksController.text,
                                      trimLength: 500,
                                      minHeightFactor: 0.14,
                                      showCopyButton: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),// Points Card Widget
                            Builder(
                                builder: (context) {
                                  return Column(
                                    children: [
                                      Visibility(
                                        visible: ( provider.observationList.first.submittedremarks !=null
                                            && provider.observationList.first.submittedremarks!.isNotEmpty),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: CustomExpandableCard(
                                            title: "Submitted remarks",
                                            content: provider.submittedRemarksController.text,
                                            trimLength: 500,
                                            minHeightFactor: 0.14,
                                            showCopyButton: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            ),
                            CustomExpandableCard(
                              title: "Points",
                              content: provider.points,
                              trimLength: 500,
                              minHeightFactor: 0.26,
                              showCopyButton: true,
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
                visible: provider.observationList.isNotEmpty
                    && provider.observationstatuscode != "CLOSED"
                    && (provider.isSuperUser ||
                       ((provider.observationList.first.tocloseyn == "Y"
                        && provider.observationList.first.closingauthorityyn == "Y"
                        || (provider.observationList.first.tocloseyn == "N" &&
                            provider.observationList.first.assignedto == provider.userName))
                    && ((provider.observationList.first.closingauthorityyn == "Y")
                    || provider.ownername == provider.userName))),
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
                              displayTitle: "",
                              controller: provider.remarksController,
                              maxLines: 2,
                              maxLength: 2000,
                              customValidationMessage: "Please enter Remarks",
                              hintText: "Remarks",
                              isAutoValidateMode: true,
                              isRequiredField: true,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                              ),

                              isEnabled: provider.rightsyn && provider.showActionButtons,
                              hintTextNeeded: true,
                            ),
                          ),
                          Visibility(
                            visible: provider.rightsyn == false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text("Observation request cannot be closed since you have no rights.",
                                  textAlign: TextAlign.center,
                                  style:  Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: bayaInfraRedColor
                                  )),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Action buttons
                          Visibility(
                            visible: provider.showActionButtons,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (provider.showAssignButton)
                                    Expanded(
                                      child: BaseElevatedIconButton(
                                        iconWidget: Icon(Icons.person, size: 24, color: bayaInfraGreen),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        fontSize: 15,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        onPressed: provider.rightsyn == false ? null : () {
                                          GoRouter.of(context).pushNamed(AppRoutes.addObservation, extra: {"observationList": provider.observationList.first});
                                        },
                                        text: "Assign",
                                      ),
                                    ),
                                  if (provider.showAssignButton && (provider.showRejectButton || provider.showClosedButton || provider.showRequestForClosureButton))
                                    SizedBox(width: 8),
                                  if (provider.showRejectButton)
                                    Expanded(
                                      child: BaseElevatedIconButton(
                                        iconWidget: Icon(Icons.check_circle, size: 24, color: bayaInfraGreen),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        fontSize: 15,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        onPressed: provider.rightsyn == false ? null : () {
                                          if (!formKey.currentState!.validate()) return;
                                          closeConfirmDialog(
                                            context: context,
                                            actionType: "Reject",
                                            provider: provider,
                                            ref: ref,
                                            title: "Do you want to reject this observation?",
                                            subtitle: provider.observationList.first.transno ?? "",
                                            icon: Icon(Icons.check_circle, size: 36, color: bayaInfraGreen),
                                            onTapYes: () => _submitForm(context, provider, ref, "Reject"),
                                          );
                                        },
                                        text: "Reject",
                                      ),
                                    ),
                                  if (provider.showRejectButton && (provider.showClosedButton || provider.showRequestForClosureButton))
                                    SizedBox(width: 8),
                                  if (provider.showRequestForClosureButton)
                                    Expanded(
                                      child: BaseElevatedIconButton(
                                        iconWidget: Icon(Icons.check_circle, size: 24, color: bayaInfraGreen),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        fontSize: 15,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        onPressed: provider.rightsyn == false ? null : () {
                                          if (provider.imagesDtl.isEmpty) {
                                            BaseSnackBar().show(message: "Please attach at least one image.");
                                            return;
                                          }
                                          closeConfirmDialog(
                                            context: context,
                                            actionType: "Request for closure",
                                            provider: provider,
                                            ref: ref,
                                            title: "Do you want to submit this observation for closure?",
                                            subtitle: provider.observationList.first.transno ?? "",
                                            icon: Icon(Icons.check_circle, size: 36, color: bayaInfraGreen),
                                            onTapYes: () => _submitForm(context, provider, ref, "Pending"),
                                          );
                                        },
                                        text: "Submit",
                                      ),
                                    ),
                                  if (provider.showRequestForClosureButton && provider.showClosedButton)
                                    SizedBox(width: 8),
                                  if (provider.showClosedButton)
                                    Expanded(
                                      child: BaseElevatedIconButton(
                                        iconWidget: Icon(Icons.check_circle, size: 24, color: bayaInfraGreen),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        fontSize: 15,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        onPressed: provider.rightsyn == false ? null : () {
                                          if (provider.imagesDtl.isEmpty) {
                                            BaseSnackBar().show(message: "Please attach at least one image.");
                                            return;
                                          }
                                          closeConfirmDialog(
                                            context: context,
                                            actionType: "Closed",
                                            provider: provider,
                                            ref: ref,
                                            title: "Do you want to close this observation?",
                                            subtitle: provider.observationList.first.transno ?? "",
                                            icon: Icon(Icons.check_circle, size: 36, color: bayaInfraGreen),
                                            onTapYes: () => _submitForm(context, provider, ref, "Closed"),
                                          );
                                        },
                                        text: "Close",
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
              )
            ],
          ),
        );


      },


    ));
    }

  closeConfirmDialog({required BuildContext context,
      required CloseObservationProvider provider,
      required WidgetRef ref,
      required String title,
      required String subtitle,
      required Function() onTapYes,
      required Widget icon,
    required String actionType
  }){

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
                          GoRouter.of(context).pushNamed(
                            provider.isFromNotification? AppRoutes.successLoaderObservationDirect:AppRoutes.successLoaderObservation,
                            extra: {
                              'provider': provider,
                              'transNo': provider.transNo,
                              'actionType' : actionType,
                              'title': (actionType == "Closed") ? "Observation closed successfully"
                                  : (actionType == "Request for closure")
                                  ? "Observation submitted successfully"
                                  :(actionType == "Reject")
                                  ? "Observation rejected successfully"
                                  : "No action taken successfully",
                              'onPressed': () {
                                if(provider.isFromNotification){
                                  GoRouter.of(context).go(AppRoutes.home);
                                  return;
                                }
                                // set calledFromOption to get that variable in didpopnext of projectDetails screen
                                ref.read(calledFromOption.notifier).state = "MOB_CLOSE_OBSERVATION";
                                //Reroute to Project details screen
                                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                              },
                            },
                          );
                          onTapYes();

                        },
                      )),
                ],
              ),
            ],
          );

  }

  void _submitForm(BuildContext context,CloseObservationProvider provider, WidgetRef ref,String status) {
    provider.closeObservation(
        status,
        onSuccess: () {
          final container = ProviderScope.containerOf(context);
      if(provider.isFromNotification){
        HomeProvider _homeProvider = container.read(homeProvider);
        _homeProvider.fetchPendingCount(projectIds: [provider.observationList.first.projectid??0]);
      }
      ProjectDashboardProvider _projectDashboardProvider = container.read(projectDashboardProvider);
      _projectDashboardProvider.fetchDashboard();

      }, onFailure: (e) {
        });
  }

  Future<void> _openImageViewer(BuildContext context,List<AttachmentModel> attachments,CloseObservationProvider provider, int initialIndex) async {
    try {


      if (attachments.isNotEmpty) {
        final urls = attachments.map((e) => e.url).toList().reversed.toList();

        GoRouter.of(context).pushNamed(
          'imageViewer',
          extra: {
            'images': urls,
            'initialIndex': initialIndex,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No images found")),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before showing error
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load images")),
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

Widget _buildImageContainer(String imageUrl, BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.3,
    child: Card(
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
         imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context),
          errorWidget: (context, url, error) => _buildPlaceholder(context),
        ),
      ),
    ),
  );
}

Widget _buildPlaceholder(BuildContext context) {
  return  SizedBox(
    height: MediaQuery.of(context).size.height*0.15,
    child: Center(
      child: Icon(
        Icons.attach_file,
        size: 32,
        color: Theme.of(context).iconTheme.color,
      ),
    ),
  );
}

Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required bool isEmpty,
  required VoidCallback onTap,
  VoidCallback? onClear,
}) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          // Dropdown Field
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    hintText: hintText,
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                    labelStyle: theme.textTheme.titleMedium,
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.54,
                        color: theme.disabledColor.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.54,
                        color: isEmpty
                            ? theme.disabledColor.withValues(alpha: 0.5)
                            : theme.colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.54,
                        color: theme.colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(width: 0.54, color: bayaInfraRedColor),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(width: 0.54, color: bayaInfraRedColor),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Remove button outside, only visible when field has value
          if (onClear != null && controller.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    ],
  );
}

void _showActivityGroupDialog(BuildContext context, CloseObservationProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.activityGroupList,
    getDisplayName: (item) => item.description,
    onSelect: (value) {
      provider.setActivityGroup(value);
      GoRouter.of(context).pop();
    },
  );
}

void _showSourceOfErrorDialog(BuildContext context, CloseObservationProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.activityGroupList,
    getDisplayName: (item) => item.description,
    onSelect: (value) {
      provider.setSourceOfError(value);
      GoRouter.of(context).pop();
    },
  );
}

void _showUpdateTagDialog(BuildContext context, CloseObservationProvider provider) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Update Tags"),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown 1
              _buildDropdownField(
                context: context,
                label: "Activity Group",
                controller: provider.activityGroupController,
                hintText: "Activity Group",
                isEmpty: provider.activityGroupList.isEmpty,
                onTap: () =>
                    _showActivityGroupDialog(context, provider),
                onClear: (){
                  provider.clearActivityGroup();
                }
              ),

              const SizedBox(height: 12),

              // Dropdown 2
              _buildDropdownField(
                context: context,
                label: "Source of Error",
                controller: provider.sourceOfErrorController,
                hintText: "Source of Error",
                isEmpty: provider.activityGroupList.isEmpty,
                onTap: () =>
                    _showSourceOfErrorDialog(context, provider),
                  onClear: (){
                  provider.clearSourceOfError();
                  }
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              // Save
              Expanded(
                child: BaseElevatedButton(
                  onPressed: () {
                    provider.clearTagsDialog();
                    Navigator.pop(context);
                  },
                  text: "Cancel",
                  backgroundColor: bayaInfraDisabledColor,
                ),
              ),
              SizedBox(width: 4,),
              // Cancel
              Expanded(
                child: BaseElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.updateActivityStatus(onSuccess: (){
                      provider.fetchObservationDetails();
                      BaseSnackBar().show(message: "Tag updated successfully");
                    });
                  },
                  text: "Save",
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _buildTagChip({
  required BuildContext context,
  required String label,
  required String prefix,
  required Color dotColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).disabledColor,
        width: 0.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$prefix: ",
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}