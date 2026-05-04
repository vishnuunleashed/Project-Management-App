import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_labour_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_labour_count_provider.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';

class LabourCountScreen extends StatelessWidget {
  const LabourCountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectScheduleLabourCountProvider>(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValues(extra);
      },
      provider: projectScheduleLabourCountProvider,
      appBar: CustomAppBar(
        title: const Text('Labour Count'),
        shadowNeeded: true,
      ),
      builder: (context, provider, ref) {

        final list = provider.activityGroupLabourList;
        if (list.isEmpty) {
          return EmptyListView(emptyText: "No data found", );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _LabourCountCard(
              item: list[index],
              provider: provider,
            );
          },
        );
      },
    );
  }
}

class _LabourCountCard extends StatelessWidget {
  final ActivityGroupLabourModel item;
  final ProjectScheduleLabourCountProvider provider;

  const _LabourCountCard({required this.item, required this.provider});

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _UpdateLabourCountDialog(
          item: item,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row → Code + Button
          Row(
            children: [
              /// Code badge
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.code ?? "—",
                    maxLines: 2, // allow wrapping
                    overflow: TextOverflow.ellipsis, // safe fallback
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: accentColor,
                        ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// Update Button
              GestureDetector(
                onTap: () => _showUpdateDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // IMPORTANT
                    children: const [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Update Count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              item.description ?? "No description",
              style: theme.textTheme.titleMedium?.copyWith(),
            ),
          ),

          const SizedBox(height: 14),

          /// Labour Count Section
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          //   decoration: BoxDecoration(
          //     color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(Icons.people_alt_rounded, size: 18, color: accentColor),
          //       const SizedBox(width: 8),
          //       Text(
          //         "Labour Count",
          //         style: theme.textTheme.labelMedium?.copyWith(
          //           fontWeight: FontWeight.w600,
          //
          //         ),
          //       ),
          //       const Spacer(),
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //         decoration: BoxDecoration(
          //           color: accentColor.withOpacity(0.1),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: Text(
          //           // "${item.labourCount ?? 0}",
          //           "0",
          //           style: TextStyle(
          //             color: accentColor,
          //             fontWeight: FontWeight.w700,
          //             fontSize: 13,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ── Dialog (unchanged logic, kept as-is) ────────────────────────────────────

class _UpdateLabourCountDialog extends StatefulWidget {
  final ActivityGroupLabourModel item;
  final ProjectScheduleLabourCountProvider provider;

  const _UpdateLabourCountDialog({required this.item, required this.provider});

  @override
  State<_UpdateLabourCountDialog> createState() =>
      _UpdateLabourCountDialogState();
}

class _UpdateLabourCountDialogState extends State<_UpdateLabourCountDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BaseConsumer<ProjectScheduleLabourCountProvider>(
        provider: projectScheduleLabourCountProvider,
        builder: (context,provider,ref) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.edit_note_rounded,
                            color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Labour Count',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.code ?? "—",
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.provider.clearDialog();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close_rounded,
                            color: Colors.grey[500], size: 20),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text("Select Date", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  CommonDatesPicker(
                    onChange: (date) {
                      widget.provider.changeLabourDate(date);
                    },
                    initialDate: provider.selectedLabourDate,
                  ),
                  const SizedBox(height: 20),
                  Text('Labour Count', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: provider.countController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Enter count',
                      prefixIcon: Icon(Icons.people_outline_rounded,
                          color: accentColor, size: 20),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a labour count';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count <= 0) {
                        return 'Please enter a valid count greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: BaseElevatedButton(
                          backgroundColor: bayaInfraDisabledColor,
                          onPressed: () {
                            widget.provider.clearDialog();
                            Navigator.pop(context);
                          },
                          text:'Cancel',
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BaseElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.provider.updateScheduleDataLabourCount(
                                activityGroupID: widget.item.id,
                                onSuccess: () {
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  onSaveDialog(
                                    context: context,
                                    title: "Success",
                                    transNo: "",
                                    icon: Icons.check_circle_outlined,
                                    iconColor: bayaInfraGreen,
                                    message: "Labour count updated successfully",
                                    onClick: () {
                                      NavigatorKey.navKey.currentState!.pop();
                                    },
                                  );
                                },
                                onFailure: (message){
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  onSaveDialog(
                                    transNo: "",
                                    context: context,
                                    title: "Failure",
                                    message: message,
                                    icon: Icons.error,
                                    iconColor: bayaInfraRed,
                                    onClick: () {
                                      NavigatorKey.navKey.currentState!.pop();
                                    },
                                  );

                                }
                              );
                            }
                          },
                          text: 'Update',
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
      context: NavigatorKey.navKey.currentState!.context,
      title: title,
      message: message,
      transNo: transNo,
      icon: Icon(icon, color: iconColor, size: 36),
      actions: [
        BaseElevatedButton(
          borderRadius: 24,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: onClick,
          text: "Ok",
        )
      ],
    );
  }
}
