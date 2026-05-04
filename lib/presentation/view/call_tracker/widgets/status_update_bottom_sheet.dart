import 'dart:io';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/attachment_list.dart';

class StatusUpdateBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final String statusCode;
  final ServiceTaskModel task;
  final bool showWorkStatus;
  final bool showAttachments;

  const StatusUpdateBottomSheet({
    super.key,
    required this.title,
    required this.statusCode,
    required this.task,
    required this.showWorkStatus,
    required this.showAttachments,
  });

  @override
  ConsumerState<StatusUpdateBottomSheet> createState() => _StatusUpdateBottomSheetState();
}

class _StatusUpdateBottomSheetState extends ConsumerState<StatusUpdateBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: BaseConsumer(
        initState: (context,provider,ref){
          provider.newTaskAttachments = [];
          provider.remarkCtrl.clear();
          provider.fetchWorkStatusOptions();
        },
        provider:serviceRequestDashboardProvider,
        builder: (context,provider,ref) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (widget.showWorkStatus) ...[
                            Text("Work Status", style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            BaseDropDownButtonFormField<CommonMasterModel>(
                              initialValue: provider.selectedWorkStatusOption,
                              items: provider.workStatusOptionList,
                              builder: (value) {
                                return Text(value.description );
                              },
                              onChanged: (val) {
                                provider.changedWorkStatusOption(val);
                              },

                              validator: (val) => val == null ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text("Remarks", style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          BaseTextField(
                            controller: provider.remarkCtrl,
                            hintText: "Enter your remarks here...",
                            isRequiredField: true,
                            maxLines: 4,
                          ),
                          if (widget.showAttachments) ...[
                            const SizedBox(height: 16),

                            _buildAttachmentSection(),
                          ],
                          const SizedBox(height: 24),

                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BaseElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          text: "Cancel",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BaseElevatedButton(
                          text: "Confirm",
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final String statusCode = widget.statusCode;
                              String? confirmTitle;
                              String? confirmMessage;

                              if (statusCode == "SUBMITTED") {
                                confirmTitle = "Update Status - Submit";
                                confirmMessage =
                                    "Are you sure you want to submit for review this task?";
                              }else if (statusCode == "REJECTED") {
                                confirmTitle = "Confirm Status Change";
                                confirmMessage =
                                    "Are you sure you want to reject this task?";
                              } else if (statusCode == "SEND_BACK") {
                                confirmTitle = "Confirm Status Change";
                                confirmMessage =
                                    "Are you sure you want to reject this task?";
                              } else if (statusCode == "REOPENED") {
                                confirmTitle = "Confirm Status Change";
                                confirmMessage =
                                    "Are you sure you want to reopen this task?";
                              }

                              if (confirmTitle != null &&
                                  confirmMessage != null) {
                                final bool? confirmed = await BaseDialog.show<
                                    bool>(
                                  context: context,
                                  title: confirmTitle,
                                  message: confirmMessage,
                                  actions: [
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Expanded(
                                          child: BaseElevatedButton(
                                            backgroundColor:
                                                bayaInfraDisabledColor,
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            text: "No",
                                          ),
                                        ),
                                        Expanded(
                                          child: BaseElevatedButton(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                await provider.updateStatus(
                                                  statusCode: widget.statusCode,
                                                  task: widget.task,
                                                  statusType: "TASK",
                                                  onSuccess: (msg) {
                                                    onSaveDialog(
                                                        context: context,
                                                        title: "Success",
                                                        transNo:"",
                                                        icon: Icons.check_circle_outlined,
                                                        iconColor: bayaInfraGreen,
                                                        message: "Task Status updated successfully.",

                                                        onClick: () {

                                                          GoRouter.of(context).pop();
                                                          GoRouter.of(context).pop();
                                                          GoRouter.of(context).pop();

                                                        });

                                                  },
                                                  onFailure: (err) async {
                                                    onSaveDialog(
                                                      transNo:"",
                                                      context: context,
                                                      title: "Failure",
                                                      message: err.toString(),
                                                      icon: Icons.error,
                                                      iconColor: bayaInfraRed,
                                                      onClick: () => GoRouter.of(context).pop(),
                                                    );
                                                  },
                                                );
                                              }

                                            },
                                            text: "Yes",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );

                                if (confirmed != true) return;
                              }


                            }
                          },


                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  static void onSaveDialog({
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

  Widget _buildAttachmentSection() {
    final theme = Theme.of(context);

    return BaseConsumer(
      provider: serviceRequestDashboardProvider,
      builder: (context,provider,ref) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Attachments',
                  style: theme.textTheme.titleLarge,
                ),
                if (provider.newTaskAttachments.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: theme.primaryColor.withValues(alpha: .15),
                    child: Text(
                      provider.newTaskAttachments.length.toString(),
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
                      : () => _showNewAttachmentSheet(context, provider),
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
            else if (provider.newTaskAttachments.isEmpty)
              _EmptyAttachments(theme: theme)
            else
              AttachmentList(
                attachments: provider.newTaskAttachments,
                onRemove: provider.removeAttachment ,
              ),
          ],
        );
      }
    );
  }


  void _showNewAttachmentSheet(BuildContext context, ServiceRequestDashboardProvider provider) {

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