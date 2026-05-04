import 'dart:io';

import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_schedule/task_status_drodown_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/check_list_bottom_sheet.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/predecessor_card.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/progress_bar.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends ConsumerWidget {
  final int? taskId;
  final String? projectName;

  const TaskDetailPage({
    super.key,
    this.projectName,
    this.taskId,
  });

  String formatDateWithoutSeconds(String input) {
    final inputFormat = DateFormat("dd-MM-yyyy hh:mm:ss a");
    final outputFormat = DateFormat("dd-MM-yyyy | hh:mm a");
    return outputFormat.format(inputFormat.parse(input));
  }

  String _formatRemainingDays(String value) {
    if (value.isEmpty) return value;

    final match = RegExp(r'([\d\.]+)\s*(\w+)').firstMatch(value);
    if (match != null) {
      final numPart = match.group(1);
      final unitPart = match.group(2) ?? "";
      final parsed = num.tryParse(numPart ?? "");

      if (parsed != null) {
        final intValue = parsed.toInt();

        String finalUnit = unitPart;
        if (intValue == 1 && finalUnit.toLowerCase().endsWith('s')) {
          finalUnit = finalUnit.substring(0, finalUnit.length - 1);
        }

        return "$intValue $finalUnit";
      }
    }

    return value;
  }

  static Future<void> _openImageViewer(
      BuildContext context,
      ProjectScheduleProvider provider,
      int initialIndex,
      ) async {
    try {
      await provider.fetchAttachmentsDetail(
        attachmentList: provider.images,
      );

      if (provider.attachmentUrl.isNotEmpty) {
        final urls = provider.attachmentUrl.map((e) => e.url).toList();

        if (context.mounted) {
          GoRouter.of(context).pushNamed(
            'imageViewer',
            extra: {
              'images': urls,
              'initialIndex': initialIndex,
            },
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No images found")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load images")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return BaseView<ProjectScheduleProvider>(
      provider: projectScheduleProvider, // <─ provider is injected from parent
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.projectDetailInitValues();
        provider.setParameterDetailPage(extra);
      },
      onWillPop: (context) async {
        GoRouter.of(context).pop();
        return false;
      },

      virtualFloatingActionButton: BaseConsumer(
        provider: projectScheduleProvider,
        builder: (context, provider, ref) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    minWidth: 56,
                  ),
                  child: ExpandableFab(
                    distance: 60,
                    bottomPadding: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Visibility(
                  visible: provider.isProjectLocked && !provider.isFromReporteeTask && (provider.predecessorDataFromOverride == null
                      ? provider.projectTaskFillData.isEmpty
                      ? false
                      : provider.projectTaskFillData.first.taskUserId == provider.loggedInId
                      : provider.predecessorDataFromOverride?.taskUserId == provider.loggedInId)
                      && ((provider.projectTaskFillData.isEmpty
                          ? false
                          : provider.projectTaskFillData.first.statusCode != "COMPLETED")
                          || (provider.isFromSupport &&
                              !provider.isFromOtherUser &&
                              provider.isSuperUser)),
                  child: FloatingActionButton(
                    heroTag: "fab_camera",
                    elevation: 0,
                    onPressed: () async {
                      final List<File>? files =
                      await MediaServiceWithCrop.instance.pickImage(
                        context,
                        enableCrop: true,
                        enableMultiSelect: true,
                      );

                      if (files != null) provider.uploadImageFile(files);
                    },
                    tooltip: 'Add image',
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      appBar: CustomAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Task View'),
        action: [
          BaseStatelessConsumer<ProjectScheduleProvider>(
            provider: projectScheduleProvider,
            builder: (context,provider,ref){
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(onPressed: (){
                  GoRouter.of(context).pushNamed(AppRoutes.taskAgainstSupportListPage,extra: {'taskId' : provider.taskId});
                }, icon: Icon(Icons.support_agent,color: Theme.of(context).iconTheme.color,)),
              );
            },

          )
        ],
      ),

      builder: (context, provider, ref) {
        if (provider.projectTaskFillData.isEmpty) {
          return const SizedBox.shrink();
        }


        return SingleChildScrollView(
          child: Column(
            children: [
              provider.projectDetailList.isEmpty
                  ? SizedBox(height: 0,)
                  : ProjectHeaderCard(
                  projectName: provider.projectDetailList.first.projectName??"",
                  endDate: provider.projectDetailList.first.endDate??DateTime.now(),
                  locationName: provider.projectDetailList.first.location??""
              ),

              provider.projectTaskPredecessorData.isEmpty
                  ? SizedBox(height: 0)
                  : SizedBox(
                height: MediaQuery.of(context).size.height*0.14 ,
                // width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: provider.pageControllerHeaderCard,
                    physics: ClampingScrollPhysics(),
                    itemCount: provider.projectTaskPredecessorData.length,
                    itemBuilder: (context,index) {
                      return PredecessorCard(
                        taskTypeHeader: "Predecessor Task",
                        taskName: provider.projectTaskPredecessorData[index].taskName??"",
                        taskId: provider.projectTaskPredecessorData[index].taskId??0,
                        profilePicture:  provider.projectTaskPredecessorData[index].taskuserprofileurl??"",
                        userName: provider.projectTaskPredecessorData[index].taskUser??"",
                        remainingDays: provider.projectTaskPredecessorData[index].lagDuration??"",
                        dependencytype: provider.projectTaskPredecessorData[index].dependencyType??"",
                        taskStatus: provider.projectTaskPredecessorData[index].taskstatus??"",
                        index: index,
                        totalItems: provider.projectTaskPredecessorData.length,
                        onTap: (){
                          GoRouter.of(context).pushNamed(
                            AppRoutes.taskDetail,
                            extra: {
                              "projectName": provider.projectDetailList.first.projectName,
                              "projectId": provider.projectDetailList.first.projectId,
                              "taskId": provider.projectTaskPredecessorData[index].id,
                              "tabName": provider.selectedTab == 0
                                  ? "my_task"
                                  : "reporting_to",
                              "predecessorData": provider.projectTaskPredecessorData[index],
                              "isProjectLocked":provider.isProjectLocked,

                            },
                          );
                        },
                        onTapPredecessorForward: (){
                          provider.pageControllerHeaderCard?.animateToPage(
                            index + 1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        onTapPredecessorBackward: (){
                          provider.pageControllerHeaderCard?.animateToPage(
                            index -1 ,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    }
                ),
              ),



              // Task Details Card
              Card(
                elevation: 0.5,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Name with Icon
                      Row(
                        children: [
                          SvgPicture.asset(
                            width: 40,
                            height: 40,
                            'assets/svgs/task_icon.svg',
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.projectTaskFillData.first.taskName??"",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Start Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Start Date',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatDateWithoutSeconds(provider.projectTaskFillData.first.plannedStartDate??""),
                                  style: Theme.of(context).textTheme.titleSmall,
                              ),

                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time spent',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),

                                Text(
                                  _formatRemainingDays(provider.projectTaskFillData.first.duration ?? ""),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // End Date with Team Members

                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    'End Date',
                                      style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatDateWithoutSeconds(provider.projectTaskFillData.first.plannedEndDate??""),
                                  style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Team member avatars
                          Padding(
                            padding: const EdgeInsets.only(right: 25.5),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: provider.projectTaskFillData.first.taskUser != null
                                      && provider.projectTaskFillData.first.taskUser != "",
                                  child:  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          ProfileImageDialog.show(context: context,
                                            imageUrl: provider.projectTaskFillData.first.taskuserprofileurl??"",
                                            userName:  provider.projectTaskFillData.first.taskUser,);

                                        },
                                        child:CachedNetworkImageWidget(
                                          imageUrl: provider.projectTaskFillData.first.taskuserprofileurl??"",
                                          userName:provider.projectTaskFillData.first.taskUser ?? "" ,
                                          padding: EdgeInsets.symmetric(vertical: 4),
                                          size: 50,
                                        ),
                                      ),
                                      Text(
                                        provider.projectTaskFillData.first.taskUser??"",
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            fontSize: 12
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Visibility(
                        visible:  provider.projectTaskFillData.first.activityGroupName != null
                            && provider.projectTaskFillData.first.activityGroupName!.isNotEmpty,
                        child: Row(
                          spacing: 5,
                          children: [
                            Text(
                              "Activity Group : ",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              provider.projectTaskFillData.first.activityGroupName.toString(),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Task Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "Task id : ",
                                maxLines: 1,
                                  style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                provider.projectTaskFillData.first.taskId.toString(),
                                maxLines: 1,
                                  style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Spacer(),
                          Visibility(
                            visible: provider.isProjectLocked && !provider.isFromReporteeTask && (provider.predecessorDataFromOverride == null
                                ? provider.projectTaskFillData.first.taskUserId == provider.loggedInId
                                : provider.predecessorDataFromOverride?.taskUserId == provider.loggedInId)
                                && ( (provider.projectTaskFillData.isEmpty
                                    ? false
                                  : provider.projectTaskFillData.first.statusCode != "COMPLETED")
                                    || (provider.isFromSupport &&
                                        !provider.isFromOtherUser &&
                                        provider.isSuperUser)),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                GoRouter.of(context)
                                    .pushNamed(AppRoutes.addSupportRequest,
                                    extra: {"isFromSchedules":true,
                                      'taskId' : provider.projectTaskFillData.first.id,
                                      'projectId' : provider.projectTaskFillData.first.projectId,

                                    });
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: bayaInfraBlue600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(8),
                              ),
                              icon: Icon(
                                Icons.add,
                                size: 16,
                                color: bayaInfraWhiteColor,
                              ),
                              label: Text(
                                "Raise Support Request",
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: bayaInfraWhiteColor,
                                  ),
                              ),
                            ),
                          ),

                        ],
                      ),

                      if (provider.attachmentUrl.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // slot width = 1/3 of total width
                                final double slotWidth = constraints.maxWidth / 3;

                                final urls = provider.attachmentUrl.map((e) => e.url).toList();

                                final firstThree = urls.length > 3 ? urls.sublist(0, 3) : urls;
                                return Row(
                                  children: List.generate(3, (i) {
                                    if (i < firstThree.length) {
                                      return SizedBox(
                                        width: slotWidth,
                                        child: GestureDetector(
                                          onTap: () {
                                            _openImageViewer(context, provider, i);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: _buildImageContainer(firstThree[i], context,i,provider),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // empty slot
                                      return SizedBox(
                                        width: slotWidth,
                                      );
                                    }
                                  }),
                                );
                              },
                            ),
                          ),
                        ),
                      ],


                      const SizedBox(height: 24),

                      // Progress Bar - Now draggable
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8,),
                          ProgressBarWidget(enabled:!(provider.isProjectLocked && !provider.isFromReporteeTask && (provider.predecessorDataFromOverride == null
                              ? provider.projectTaskFillData.first.taskUserId == provider.loggedInId
                              : provider.predecessorDataFromOverride?.taskUserId == provider.loggedInId)
                              && ((provider.projectTaskFillData.isEmpty
                                  ? false
                                  : provider.projectTaskFillData.first.statusCode != "COMPLETED")
                                  || (provider.isFromSupport &&
                                      !provider.isFromOtherUser &&
                                      provider.isSuperUser)))

                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Status Dropdown
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      BaseDropDownButtonFormField<TaskStatusDropdownDtlModel>(
                        initialValue: provider.selectedStatus,
                        padding: EdgeInsets.zero,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items:  provider.selectedStatus?.taskStatusCode == "COMPLETED"
                            ? [provider.taskStatusDropdownList.firstWhere((item){
                              return item.taskStatusCode == "COMPLETED";})]
                            : provider.taskStatusDropdownList,

                        onChanged:  !(provider.isProjectLocked && !provider.isFromReporteeTask && (provider.predecessorDataFromOverride == null
                            ? provider.projectTaskFillData.first.taskUserId == provider.loggedInId
                            : provider.predecessorDataFromOverride?.taskUserId == provider.loggedInId)
                            && ((provider.projectTaskFillData.isEmpty
                                ? false
                                : provider.projectTaskFillData.first.statusCode != "COMPLETED")
                                || (provider.isFromSupport &&
                                    !provider.isFromOtherUser &&
                                    provider.isSuperUser)))
                            ? null
                            :(value) {
                          provider.changeStatus(value);
                        },
                        builder: (value) {
                          return Text(value.taskStatusDescription??"",);
                        },
                      ),


                      const SizedBox(height: 24),

                      // Action Buttons
                      Builder(
                        builder: (context) {

                          return Visibility(
                            visible:   provider.isProjectLocked && !provider.isFromReporteeTask && (provider.predecessorDataFromOverride == null
                                ? provider.projectTaskFillData.first.taskUserId == provider.loggedInId
                                : provider.predecessorDataFromOverride?.taskUserId == provider.loggedInId)
                                && ((provider.projectTaskFillData.isEmpty
                                    ? false
                                    : provider.projectTaskFillData.first.statusCode != "COMPLETED")
                                    || (provider.isFromSupport &&
                                        !provider.isFromOtherUser &&
                                        provider.isSuperUser)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: BaseElevatedButton(
                                      height: 40,
                                      backgroundColor: bayaInfraDisabledColor,
                                      onPressed: () {
                                        provider.clearValues();
                                      },
                                      text: 'Clear'
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: BaseElevatedButton(
                                    height: 40,
                                    onPressed: () {
                                      if (provider.checkLists.isNotEmpty) {
                                        showChecklistBottomSheet(
                                          context,
                                          title: 'Schedule Task Checklist',
                                          subtitle: 'Check and confirm each item',
                                          isCompleted:
                                          provider.selectedStatus?.taskStatusCode == "COMPLETED",
                                          items: provider.checkLists,
                                          onReviewed: (updatedList) {

                                            //  Delay to avoid context issues
                                            Future.delayed(const Duration(milliseconds: 200), () {
                                              final dialogContext =
                                              NavigatorKey.navKey.currentContext!;

                                              BaseDialog.show(
                                                context: dialogContext,
                                                title: "Update Task",
                                                message: "Do you want to update this task?",
                                                icon: const Icon(Icons.info_outline),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: BaseElevatedButton(
                                                          borderRadius: 24,
                                                          backgroundColor: bayaInfraDisabledColor,
                                                          text: "No",
                                                          onPressed: () {
                                                            GoRouter.of(dialogContext).pop();
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: BaseElevatedButton(
                                                          borderRadius: 24,
                                                          backgroundColor:
                                                          Theme.of(dialogContext).primaryColor,
                                                          text: "Yes",
                                                          onPressed: () {
                                                            GoRouter.of(dialogContext).pop();

                                                            //  API call
                                                            provider.updateTaskStatus(
                                                              selectedCheckLists: updatedList,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            });
                                          },
                                        );
                                      } else {
                                        //  Without checklist
                                        BaseDialog.show(
                                          context: NavigatorKey.navKey.currentContext!,
                                          title: "Update Task",
                                          message: "Do you want to update this task?",
                                          icon: const Icon(Icons.info_outline),
                                          actions: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: BaseElevatedButton(
                                                    borderRadius: 24,
                                                    backgroundColor: bayaInfraDisabledColor,
                                                    text: "No",
                                                    onPressed: () {
                                                      GoRouter.of(
                                                          NavigatorKey.navKey.currentContext!)
                                                          .pop();
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: BaseElevatedButton(
                                                    borderRadius: 24,
                                                    backgroundColor: Theme.of(
                                                        NavigatorKey.navKey.currentContext!)
                                                        .primaryColor,
                                                    text: "Yes",
                                                    onPressed: () {
                                                      GoRouter.of(
                                                          NavigatorKey.navKey.currentContext!)
                                                          .pop();

                                                      provider.updateTaskStatus();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                    text: 'Submit',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),



            ],
          ),
        );
      },
    );
  }
  Widget _buildImageContainer(String? imageUrl, BuildContext context,int index,ProjectScheduleProvider provider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        elevation: 0.5,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            width: 0.5,
            color: Theme.of(context).cardColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: (){
              GoRouter.of(context).pushNamed(
                AppRoutes.imageGridScreen,
                extra: {
                  "index": index,
                  "setImageParams": true,
                  "projectScheduleProvider": provider
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl??"",
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(context),
              errorWidget: (context, url, error) => _buildPlaceholder(context),
            ),
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
}