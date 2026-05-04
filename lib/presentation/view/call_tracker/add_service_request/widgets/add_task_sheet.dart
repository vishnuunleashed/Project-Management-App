import 'dart:io';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/attachment_list.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';

import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';


class AddTaskSheet extends ConsumerStatefulWidget {
  final int taskId;
  final ServiceTaskModel task;
  final bool isEditMode;
  final int? editIndex;
  final bool isFromTile;

  const AddTaskSheet({
    super.key,

    required this.taskId,
    required this.task,
    required this.isEditMode,
    required this.editIndex,
    this.isFromTile = false,
  });

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final provider = ref.watch(addServiceRequestProvider);


    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dragHandle(),

                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        (widget.isFromTile) ?"Edit Task" : 'Add New Task',
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.clearTaskBottomSheet();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ── Scrollable body ────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Task Name ──────────────────────────────────────
                        BaseTextField(
                          isEnabled: true,
                          isRequiredField: true,
                          controller: provider.taskNameCtrl,
                          displayTitle: "Task Description",

                        ),

                        const SizedBox(height: 16),
                        Text("Target Closure Date",
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium),
                        SizedBox(
                          height: 10,
                        ),
                        CommonDatesPicker(
                          onChange: (date) {
                            provider.setTargetClosureDate(date);
                          },
                          initialDate: provider.taskTargetClosureDate == null
                              || provider.taskTargetClosureDate!.isEmpty
                              ? null
                              : DateTime.parse(
                              provider.taskTargetClosureDate ?? ""),
                        ),
                        const SizedBox(height: 16),

                        // ── Task Owner ──────────────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            final addServiceReqProv = ref.read(
                                addServiceRequestProvider);
                            showSelectionDialog<CommonMasterModel>(
                              context,
                              items: addServiceReqProv.engineerList,
                              getDisplayName: (owner) => owner.name,
                              onSelect: (owner) {
                                provider.setTaskOwner(owner.id, owner.name);
                                GoRouter.of(context).pop();
                              },
                              title: "Select Task Owner",
                              searchHint: "Search task owner",
                            );
                          },
                          child: AbsorbPointer(
                            child: BaseTextField(
                              isEnabled: true,
                              controller: TextEditingController(
                                text: provider.taskOwnerName ?? '',
                              ),
                              displayTitle: "Task Owner",
                              hintText: "Select task owner",
                              suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Client Dependency ──────────────────────────────────
                        Row(
                          children: [
                            Checkbox(
                              value: provider.isClientDependency,
                              onChanged: (bool? value) {
                                provider.isClientDependency = value ?? false;
                                provider.notifyListeners();
                              } ,
                            ),
                            const Text("Client Dependency"),
                          ],
                        ),



                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Attachments',
                                    style: theme.textTheme.labelLarge
                                        ?.copyWith(fontSize: 12),
                                  ),
                                  if (provider.newTaskAttachments
                                      .isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: theme.primaryColor
                                          .withValues(alpha: .15),
                                      child: Text(
                                        provider.newTaskAttachments.length
                                            .toString(),
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: provider.isUploadingNew
                                        ? null
                                        : () =>
                                        _showNewAttachmentSheet(context, ref),
                                    icon: const Icon(
                                      Icons.attach_file_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Add',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (provider.isUploadingNew)
                                const _UploadingIndicator()
                              else
                                if (provider.newTaskAttachments.isEmpty)
                                  _EmptyAttachments(theme: theme)
                                else
                                  AttachmentList(
                                    attachments: provider.newTaskAttachments,
                                    onRemove: provider.removeAttachment,
                                  ),
                            ],
                          ),




                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            provider.clearTaskBottomSheet();
                          },
                          child: Text(
                            'Cancel',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: provider.isUploadingNew
                              ? null
                              : () {
                            // Validate task name before submitting
                            if (!_formKey.currentState!.validate()) return;

                            // Validate: target closure date is mandatory if task owner is selected
                            final bool hasOwner = provider.taskOwnerId != null;
                            final bool hasDate = provider
                                .taskTargetClosureDate != null &&
                                provider.taskTargetClosureDate!.isNotEmpty;

                            if (hasOwner && !hasDate) {
                              onSaveDialog(
                                transNo: "",
                                context: context,
                                title: "Failure",
                                message: "Target Closure Date is required when a Task Owner is selected.",
                                icon: Icons.error,
                                iconColor: bayaInfraRed,
                                onClick: () => GoRouter.of(context).pop(),
                              );

                              return;
                            }

                            if (hasDate && !hasOwner) {
                              onSaveDialog(
                                transNo: "",
                                context: context,
                                title: "Failure",
                                message: "Task Owner is required when a Target Closure Date is selected.",
                                icon: Icons.error,
                                iconColor: bayaInfraRed,
                                onClick: () => GoRouter.of(context).pop(),
                              );

                              return;
                            }

                            provider.submitNewTask(
                              taskId: widget.taskId,
                              editIndex: widget.editIndex,
                              isEditMode: widget.isEditMode,
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            (widget.isFromTile) ? 'Edit Task' : 'Add Task',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
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
    );
  }
}
  void onSaveDialog({
    required BuildContext context,
    required String title,
    required String transNo,
    required IconData icon,
    required Color iconColor,
    required String message,
    required VoidCallback onClick,
  }) {
    BaseDialog.show(
        context: context,
        title: title,
        message: message,
        transNo: transNo,
        icon: Icon(icon,color: iconColor,size: 36,),
        actions: [
          BaseElevatedButton(
              fontWeight: FontWeight.w700,
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: onClick,
              text: "Ok")
        ]);
  }

  // ── Dialogs & Sheets ──────────────────────────────────────────────────────



  void _showNewAttachmentSheet(BuildContext context, WidgetRef ref) {
    final provider = ref.read(addServiceRequestProvider);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dragHandle(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF6366F1),
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await MediaServiceWithCrop.instance.pickImage(
                        context,
                        enableCrop: true,
                        enableMultiSelect: true,
                        enableDoodling: true,
                      );
                      if (files != null && files.isNotEmpty) {
                        await provider.uploadNewTaskFiles(files);
                      }
                    },
                  ),
                  _SourceOption(
                    icon: Icons.folder_open_rounded,
                    label: 'Files',
                    color: const Color(0xFF0EA5E9),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                      if (result != null) {
                        final files = result.files
                            .where((f) => f.path != null)
                            .map((f) => File(f.path!))
                            .toList();
                        if (files.isNotEmpty) {
                          await provider.uploadNewTaskFiles(files);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _dragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }



class _UploadingIndicator extends StatelessWidget {
  const _UploadingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            'Uploading attachment…',
            style: TextStyle(color: theme.primaryColor),
          ),
        ],
      ),
    );
  }
}

// ── Source option button ───────────────────────────────────────────────────
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Empty attachments placeholder ──────────────────────────────────────────
class _EmptyAttachments extends StatelessWidget {
  final ThemeData theme;
  const _EmptyAttachments({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined,
              size: 32, color: theme.textTheme.bodySmall?.color),
          const SizedBox(height: 6),
          Text('No attachments yet', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

