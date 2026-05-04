import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/reassign_enginner_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:intl/intl.dart';

class ReassignEngineerScreen extends ConsumerStatefulWidget {
  const ReassignEngineerScreen({super.key});

  @override
  ConsumerState<ReassignEngineerScreen> createState() =>
      _ReassignEngineerScreenState();
}

class _ReassignEngineerScreenState
    extends ConsumerState<ReassignEngineerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(reassignEngineerProvider);
    return BaseView<ReassignEngineerProvider>(
      appBar: CustomAppBar(
        title: Text(provider.isAssignMode?"Assign Task Owner":"Reassign Task Owner"),
      ),
      provider: reassignEngineerProvider,
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initState(extra: extra);
      },
      builder: (context, provider, ref) {
        return WillPopScope(
          onWillPop: () async {
            ref
                .watch(serviceDetailsLandingProvider)
                .changeShouldRefreshAfterPop(true);
            return true;
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ── Header Info Card ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A1D23).withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(context: context,subTitle: provider.selectedTicket?.ticketNo??"",title: "Ticket No :"),
                        _buildHeader(context: context,subTitle: provider.task?.description??"",title: "Task Name :"),
                        const Divider(height: 1, color: Color(0xFFEEEFF3)),

                        _buildInfoRow(
                          context: context,
                          userName: provider.task?.assignedUser ?? "",
                          imageUrl:
                              provider.task?.assignedUserProfileUrl ??
                                  "",
                          label: 'Task Owner',
                          value: provider.task?.assignedUser ?? "",
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ── Engineer Selection ───────────────────────────────
                   Padding(
                     padding: const EdgeInsets.only(left: 4.0),
                     child: Text(
                      provider.isAssignMode
                          ? 'Select a Task Owner to assign this task'
                          : 'Select an Task Owner to reassign this ticket',
                      style:  Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14
                                       ),
                                       ),
                   ),

                  const SizedBox(height: 8),

                  _buildDropdownField(
                    context: context,
                    label: "Task Owner",
                    controller: provider.reassignEngineerController,
                    hintText: "Select Task Owner",
                    isRequired: true,
                    selectedValue: provider.selectedReassignEngineer?.name,
                    isEmpty: provider.engineerList.isEmpty,
                    isEditable: true,
                    onTap: () async {
                      _showEngineerDialog(context, provider);
                    },
                  ),

                  /// ── Target Closure Date (visible in Assign mode) ─────
                  if (provider.isAssignMode) ...[
                    const SizedBox(height: 16),
                    Text("Target Closure Date",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium),
                    SizedBox(
                      height: 10,
                    ),
                    CommonDatesPicker(
                      onChange: (date) {

                        provider.setTargetClosureDate(date);
                      },
                      initialDate: provider.taskTargetClosureDate == null || provider.taskTargetClosureDate!.isEmpty
                          ?null
                          :DateTime.parse(provider.taskTargetClosureDate??''),
                    )

                  ],

                  const SizedBox(height: 32),

                  /// ── Submit Button ────────────────────────────────────
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if((provider.taskTargetClosureDate == null || provider.taskTargetClosureDate!.isEmpty) && provider.isAssignMode){
                          BaseSnackBar().show(message: "Selected Target Closure Date");
                          return;
                        }
                        provider.reassignEngineer(onSuccess: () {
                          _showResultDialog(
                              context: context,
                              title: "Success",
                              message: provider.isAssignMode
                                  ? "Task Owner assigned successfully"
                                  : "Task Owner reassigned successfully",
                              icon: Icons.check_circle_outlined,
                              iconColor: bayaInfraGreen,
                              onClick: () {
                                GoRouter.of(context).pop();
                                ref
                                    .watch(serviceDetailsLandingProvider)
                                    .changeShouldRefreshAfterPop(true);
                                GoRouter.of(context).pop();
                              });
                        }, onFailure: (exception) {
                          _showResultDialog(
                              context: context,
                              title: "Failure",
                              message: exception,
                              icon: Icons.error,
                              iconColor: bayaInfraRed,
                              onClick: () {
                                GoRouter.of(context).pop();
                              });
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(provider.isAssignMode ? Icons.person_add_alt_1 : Icons.swap_horiz_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          provider.isAssignMode ? 'Assign Task Owner' : 'Reassign Task Owner',
                          style: const TextStyle(
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required bool isRequired,
  required String? selectedValue,
  required bool isEmpty,
  required bool isEditable,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: isEditable ? onTap : null,
    child: AbsorbPointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            enabled: isEditable,
            validator: (val) {
              return (selectedValue == null && isRequired)
                  ? "Please select $label"
                  : null;
            },
            controller: controller,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
              labelStyle: Theme.of(context).textTheme.labelLarge,
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.54,
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.54,
                      color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10)),
              errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 0.54, color: bayaInfraRedColor),
                  borderRadius: BorderRadius.circular(10)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 0.54, color: bayaInfraRedColor),
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.54,
                      color: isEmpty
                          ? Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildHeader({required BuildContext context, required String title, required String subTitle}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    child: Row(
      children: [
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title , style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: null
            ),),
            SizedBox(height: 4,),
            Text(
              subTitle,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                 color: Theme.of(context).primaryColor
            )),
          ],
        ),
      ],
    ),
  );
}

Widget _buildInfoRow({
  required String imageUrl,
  required String userName,
  required String label,
  required String value,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        CachedNetworkImageWidget(
          imageUrl: imageUrl,
          userName: userName,
          size: 36,
          iconSize: 14,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(),
            ),
          ],
        ),
      ],
    ),
  );
}


void _showEngineerDialog(
    BuildContext context, ReassignEngineerProvider provider) {
  showSelectionDialogWithSubtitle<CommonMasterModel>(
    context,
    items: provider.engineerList,
    getDisplayName: (engineer) => engineer.name,
    getSubtitle: (engineer) => engineer.description,
    onSelect: (engineer) {
      provider.setReassignedEngineer(engineer);
      GoRouter.of(context).pop();
    },
    title: "Select Task Owner",
    searchHint: "Search Task Owner",
  );
}

void _showResultDialog({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required Color iconColor,
  required VoidCallback onClick,
}) {
  BaseDialog.show(
    context: context,
    title: title,
    message: message,
    transNo: "",
    icon: Icon(icon, color: iconColor, size: 36),
    actions: [
      BaseElevatedButton(
         borderRadius: 24,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: onClick,
        text: "Ok",
      ),
    ],
  );
}
