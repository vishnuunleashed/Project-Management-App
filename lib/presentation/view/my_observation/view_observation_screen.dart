import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation_export.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/view_observation_provider/view_observation_provider.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/settings.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/presentation/rich_readmore.dart';
import 'package:interior_design/presentation/view/common/expansion_tile/expansion_tile_for_close_page.dart';
import 'package:interior_design/presentation/view/common/mom_deatil_card.dart';
import 'package:interior_design/presentation/view/common/observation/observation_detail_common_header.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class ViewClosedObservationScreen extends StatelessWidget {
  const ViewClosedObservationScreen({super.key});
  @override
  Widget build(BuildContext context) {

    return BaseView<ViewObservationProvider>(
    provider: viewObservationProvider,
    initState: (context,provider,ref) async {
      provider.initValues();
      final state = GoRouterState.of(context);
      final extra = state.extra as Map<String, dynamic>?;
      final observationId = extra?['observationId']??extra?['transid'];
      provider.setObservationId(observationId);
      provider.fetchObservationDetails();
      provider.getUserDetails();
      provider.fetchActivityGroup();

    },

      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: viewObservationProvider,
        builder: (context, provider, ref) {
          return ExpandableFab(
            bottomPadding: 60,
            distance: 70,
          );
        },
      ),
    appBar: CustomAppBar(
      shadowNeeded: true,
        useLeading: true,
      action: [],
      title: BaseConsumer(
          provider: viewObservationProvider,
          builder:  (context,provider,ref)=> Text(
            "View Observation",
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
                              observer: provider.displayprofilename,
                              transNo: provider.transNo,
                              selectedDate: provider.selectedDate,
                              profileUrl: provider.displayProfileUrl,
                              createdLabel: provider.createdLabel ,
                              statusLabel: provider.statusLabel ,),

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
                                                color:Theme.of(context).primaryColor.withOpacity(0.1),
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

                                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.4)),

                                  // Tags body
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: (provider.observationList.first.activitygroupid == null &&
                                        provider.observationList.first.sourceoferrorid == null)
                                    // Empty state
                                        ? Row(
                                      children: [
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
                                        : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
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
                                          _openImageViewer(context, provider.attachmentUrl,provider, 0);
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
                                                _openImageViewer(context, provider.attachmentUrl,provider, index);
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
                          SizedBox(height: 12,),
                          if ( provider.observationList.isNotEmpty
                              && provider.attachmentUrlToBeUploaded.isNotEmpty) ...[
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
                          Column(
                            children: [
                              Visibility(
                                visible: provider.remarksController.text.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomExpandableCard(
                                    title: provider.observationList.first.logstatuscode == "REJECTED"
                                        ? "Rejected remarks"
                                        : "Closed remarks",
                                    content: provider.remarksController.text,
                                    trimLength: 500,
                                    minHeightFactor: 0.14,
                                    showCopyButton: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Builder(
                              builder: (context) {
                                return Column(
                                  children: [
                                    Visibility(
                                      visible: (provider.observationList.isNotEmpty &&
                                          provider.observationList.first.submittedremarks !=null
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
                          // Points Card Widget
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


          ],
        ),
      );
    },
        );
    }




  Widget expansionTile(BuildContext context,
      ViewObservationProvider provider,
      String fullContent,
      double maxContentHeight) {


    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top:  12.0,bottom: 16),
              child: Text(
                "Points",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Spacer(),
            IconButton(onPressed: () async {
              await Clipboard.setData(ClipboardData(text: fullContent));
            }, icon: Icon(
                Icons.copy,
            size: 20,
              color: Theme.of(context).iconTheme.color,)),


          ],
        ),
      ),

          // Content with measurement & ellipsis
          LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = MediaQuery.of(context).size.height;
              double minContentHeight = screenHeight * 0.28;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minContentHeight,
                  maxHeight:  double.infinity,
                ),
                child: Container(
                  margin: EdgeInsets.zero,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        width: 0.3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),

                  // use Stack so we can overlay debug counts if needed
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RichReadMoreText.fromString(
                      text: fullContent.trim(),
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      settings: LengthModeSettings(
                          trimLength: 500,
                          textAlign: TextAlign.justify,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: 'Show less',
                          moreStyle: TextStyle(
                              color: Theme.of(context).primaryColor,),
                          lessStyle: TextStyle(
                              color: Theme.of(context).primaryColor,)
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openImageViewer(BuildContext context,List<AttachmentModel> attachments, ViewObservationProvider provider, int initialIndex) async {
    try {


      if (attachments.isNotEmpty) {
        List<String> urls = attachments.map((e) => e.url).toList().reversed.toList();

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
          imageUrl:  imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context),
          errorWidget: (context, url, error) => _buildPlaceholder(context),
      ),
    ),
  ));
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

void _showUpdateTagDialog(BuildContext context, ViewObservationProvider provider) {
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

Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required bool isEmpty,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);

  return GestureDetector(
    onTap:  onTap,
    child: AbsorbPointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            style: theme.textTheme.titleSmall?.copyWith(
                color:theme.textTheme.bodyLarge?.color
            ),
            decoration: InputDecoration(
              suffixIcon: Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color:  theme.colorScheme.primary
              ),
              hintText: hintText,
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
              labelStyle: theme.textTheme.titleMedium,

              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.54,
                  color: theme.disabledColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),

              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.54,
                  color: isEmpty
                      ? theme.disabledColor.withOpacity(0.5)
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
        ],
      ),
    ),
  );
}

void _showActivityGroupDialog(BuildContext context, ViewObservationProvider provider) {
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

void _showSourceOfErrorDialog(BuildContext context, ViewObservationProvider provider) {
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

String formatDate(String? date) {
  if (date == null || date.isEmpty) return "";
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;

  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
}