import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_loading_spinner.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/add_service_request/widgets/add_task_sheet.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/pdf_viewer_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/widgets/status_update_bottom_sheet.dart';
import 'package:interior_design/utils/routes.dart';
import 'google_docs_viewer_screen.dart';
import 'network_image_view_screen.dart';
import 'package:intl/intl.dart';

class DashboardTaskCard extends ConsumerStatefulWidget {
  final ServiceTaskModel task;
  final int taskIndex;
  final ServiceTasksProvider provider;


  const DashboardTaskCard({
    super.key,
    required this.task,
    required this.taskIndex,

    required this.provider,
  });

  @override
  ConsumerState<DashboardTaskCard> createState() => _DashboardTaskCardState();
}

class _DashboardTaskCardState extends ConsumerState<DashboardTaskCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final taskIndex = widget.taskIndex;
    final provider = widget.provider;


    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final serviceRequestProvider = ref.watch(serviceRequestDashboardProvider);
    final isEditMode = provider.isEditMode || (task.id == 0);

    final enableSubmitButton = (serviceRequestProvider.tickets.isNotEmpty)
        ? ((task.statusCode == "PENDING" || task.statusCode == "SEND_BACK") &&
            serviceRequestProvider.tickets.first.statusCode == "IN_PROGRESS" &&
            (widget.task.assignedUserId ==
                    serviceRequestProvider.loggedInUserID ||
                provider.isSuperUser))
        : false;

    final enableReviewSendBackButton = task.statusCode == "SUBMITTED" &&
        (serviceRequestProvider.serviceReportUserId ==
                serviceRequestProvider.loggedInUserID ||
            provider.isSuperUser);

    final enableAddButton = isEditMode || task.id == 0;

    final hasAnyAction = task.statusCode != "REVIEWD" &&
        (enableSubmitButton || enableReviewSendBackButton || enableAddButton);



    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Always-visible header row ──────────────────────────
            // ── Always-visible header row ──────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ── Header band ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Serial number chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "T${(enableAddButton) ? taskIndex + 1 : (task.slNo ?? taskIndex + 1)}",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: bayaInfraWhiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Spacer(),
                      /// Status badge
                      Visibility(
                        visible: task.workStatusCode == "NOTINSCOPE",
                          child: _buildNotInScopeBadge(context, task.workStatusName ?? "",hasAnyAction)),
                      SizedBox(width: 8,),
                      /// Status badge
                      _buildTaskStatusBadge(context, task.statusCode ?? "", hasAnyAction),

                      if ((task.isCoordinator || serviceRequestProvider.isSuperUser) &&  provider.currentTicket?.statusCode != "CLOSED" && provider.currentTicket?.statusCode != "CANCELLED")
                        _buildCoordinatorMenu(context, serviceRequestProvider),
                    ],
                  ),
                ),


                /// ── Description — full width, no siblings ────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Task Description',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if(task.clientdependancyyn == "Y")
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    size: 13,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Client Dependent",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if ((task.assignedUser ?? '').isNotEmpty ||
                    (task.targetclosuredate ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if ((task.assignedUser ?? '').isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Owner',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.assignedUser ?? '',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        if ((task.targetclosuredate ?? '').isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Closure Date',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.targetclosuredate == null ||
                                        task.targetclosuredate!.isEmpty
                                    ? ""
                                    : DateFormat('dd-MM-yyyy').format(
                                        DateTime.parse(
                                            task.targetclosuredate ??
                                                DateTime.now().toString())),
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            // Remarks
            if ((task.statusRemarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (task.statusCode == "SEND_BACK" || task.statusCode == "REJECTED")
                        ? 'Rejected Remarks :'
                        : task.statusCode == "REOPENED"
                          ?'Reopened Remarks :'
                          :'Submitted Remarks :',
                    style: theme.textTheme.titleSmall?.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    task.statusRemarks ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 2),
            ],
            if (task.submittedAttachments.isNotEmpty
                || task.attachments.isNotEmpty
                || task.prevSubmittedAttachments .isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  /// Attachments title container
                  Expanded(
                    child: InkWell(
                      onTap: _toggleExpanded,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 14,
                              color: hasAnyAction
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Attachments",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: hasAnyAction
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).primaryColor.withValues(
                                            alpha: 0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// Expand / Collapse button container
                  InkWell(
                    onTap: _toggleExpanded,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: hasAnyAction
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // ── Expandable details section ─────────────────────────
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 6),

                    /// Attachments
                    if (task.attachments.isNotEmpty) ...[
                      const Divider(height: 0.4),
                      const SizedBox(height: 6),
                      Text(
                        'Task attachments',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          color: !hasAnyAction
                              ? theme.textTheme.labelLarge?.color
                                  ?.withValues(alpha: 0.7)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _AttachmentsRow(
                        task: task,
                        provider: provider,
                      ),
                    ],

                    /// Submitted Attachments
                    if (task.submittedAttachments.isNotEmpty) ...[
                      const Divider(height: 0.4),
                      const SizedBox(height: 6),
                      Text(
                        'Submitted attachments',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _AttachmentsRow(
                        task: ServiceTaskModel(
                          attachments: task.submittedAttachments,
                        ),
                        provider: provider,
                      ),
                    ],

                    /// Previous Attachments
                    if (task.prevSubmittedAttachments.isNotEmpty) ...[
                      const Divider(height: 0.4),
                      const SizedBox(height: 6),
                      Text(
                        'Previously submitted attachments',
                        style: theme.textTheme.titleSmall,
                        ),
                      const SizedBox(height: 8),
                      _AttachmentsRow(
                        task: ServiceTaskModel(
                          attachments: task.prevSubmittedAttachments,
                        ),
                        provider: provider,
                      ),
                    ],
                  ],
              ),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),
            _buildActionButtons(context, serviceRequestProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ServiceRequestDashboardProvider provider) {
    final task = widget.task;
    final statusCode = task.statusCode?.toUpperCase() ?? "";
    
    // Role Checks (Using backend-provided flags)
    final bool isTaskOwner = (task.isEngineer || provider.isSuperUser);
    final bool isReviewer = (task.isReporter || provider.isSuperUser);
    final bool isCoordinator = (task.isCoordinator || provider.isSuperUser);

    List<Widget> buttons = [];

    // ── Task Owner Actions ───────────────────────────────────────────
    if (isTaskOwner) {
      if (statusCode == 'ASSIGNED') {
        buttons.add(_actionButton(context, "Accept", Colors.green, Icons.check, () {
          BaseDialog.show(
            context: context,
            title: "Accept Assignment",
            message: "Do you want to accept this assignment",
            actions: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: BaseElevatedButton(
                      backgroundColor: bayaInfraDisabledColor,
                      onPressed: () => context.pop(),
                      text: "No",
                    ),
                  ),
                  Expanded(
                    child: BaseElevatedButton(
                      backgroundColor:Theme.of(context).primaryColor,
                      onPressed: () {
                        context.pop();
                        provider.acceptTask(
                          task: task,
                          onSuccess: (msg) {
                            onSaveDialog(
                                context: context,
                                title: "Success",
                                transNo:"",
                                icon: Icons.check_circle_outlined,
                                iconColor: bayaInfraGreen,
                                message: "Task accepted successfully.",

                                onClick: () {
                                  
                                  GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();

                                });
                          },
                          onFailure: (err) {
                            onSaveDialog(
                              transNo:"",
                              context: context,
                              title: "Failure",
                              message: err.toString(),
                              icon: Icons.error,
                              iconColor: bayaInfraRed,
                              onClick: () =>  GoRouter.of(NavigatorKey.navKey.currentState!.context).pop(),
                            );
                          },
                        );
                      },
                      text: "Yes",
                    ),
                  ),
                ],
              ),
            ],
          );
        }));
      } else if (statusCode == 'ACCEPTED' || statusCode == 'SEND_BACK' || statusCode == 'REOPENED' || statusCode == 'IN_PROGRESS') {
        buttons.add(_actionButton(context, "Submit", Colors.blue, Icons.send, () {
          _showStatusSheet(context, "Submit Task", "SUBMITTED", true, true);
        }));
      }
    }

    // ── Reviewer Actions ──────────────────────────────────────────────
    if (isReviewer && statusCode == 'SUBMITTED') {
      buttons.add(_actionButton(context, "Review", Colors.green, Icons.rate_review, () {
        _showStatusSheet(context, "Review Task", "REVIEWD", false, false);
      }));
      buttons.add(const SizedBox(width: 8));
      buttons.add(_actionButton(context, "Reject", bayaInfraRed, Icons.replay, () {
        _showStatusSheet(context, "Send Back Task", "SEND_BACK", false, false);
      }));
    }

    if (isReviewer && statusCode == 'REJECTED') {

      buttons.add(_actionButton(context, "Send Back", bayaInfraRed, Icons.replay, () {
        _showStatusSheet(context, "Send Back Task", "SEND_BACK", false, false);
      }));
    }

    // ── Coordinator Actions ───────────────────────────────────────────
    if (isCoordinator) {
      if (statusCode == 'REVIEWD' || statusCode == 'REVIEWED') {
        buttons.add(_actionButton(context, "Close", Colors.teal, Icons.done_all, () {
          BaseDialog.show(
            context: context,
            title: "Confirm Status Change",
            message: "Are you sure you want to close this task?",
            actions: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: BaseElevatedButton(
                      backgroundColor: bayaInfraDisabledColor,
                      onPressed: () => context.pop(),
                      text: "No",
                    ),
                  ),
                  Expanded(
                    child: BaseElevatedButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        context.pop();
                        // Second step: Notify Client
                        BaseDialog.show(
                          context: context,
                          title: "Notify Client",
                          message: "Do you want to send an email notification to the client?",
                          actions: [
                            Row(
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: BaseElevatedButton(
                                    backgroundColor: bayaInfraDisabledColor,
                                    onPressed: () {
                                      GoRouter.of(context).pop();
                                      provider.updateStatus(
                                        statusCode: "CLOSED",
                                        task: task,
                                        statusType: "TASK",
                                        notifyClient: false,
                                        onSuccess: (msg) {
                                          onSaveDialog(
                                              context: context,
                                              title: "Success",
                                              transNo:"",
                                              icon: Icons.check_circle_outlined,
                                              iconColor: bayaInfraGreen,
                                              message: "Task Closed Successfully",
                                              onClick: () {
                                                GoRouter.of(context).pop();

                                              });
                                        },
                                        onFailure: (err) {
                                          onSaveDialog(
                                            transNo:"",
                                            context: context,
                                            title: "Failure",
                                            message: err.toString(),
                                            icon: Icons.error,
                                            iconColor: bayaInfraRed,
                                            onClick: () {
                                              GoRouter.of(context).pop();
                                            },
                                          );
                                        },

                                      );
                                    },
                                    text: "No",
                                  ),
                                ),
                                Expanded(
                                  child: BaseElevatedButton(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      GoRouter.of(context).pop();

                                      provider.updateStatus(
                                        statusCode: "CLOSED",
                                        task: task,
                                        statusType: "TASK",
                                        notifyClient: true,
                                        onSuccess: (msg) {
                                          onSaveDialog(
                                              context: context,
                                              title: "Success",
                                              transNo:"",
                                              icon: Icons.check_circle_outlined,
                                              iconColor: bayaInfraGreen,
                                              message: "Task Closed Successfully",

                                              onClick: () {
                                                GoRouter.of(context).pop();


                                              });
                                        },
                                        onFailure: (err) {
                                          onSaveDialog(
                                            transNo:"",
                                            context: context,
                                            title: "Failure",
                                            message: err.toString(),
                                            icon: Icons.error,
                                            iconColor: bayaInfraRed,
                                            onClick: () {
                                              GoRouter.of(context).pop();
                                            },
                                          );
                                        },
                                      );
                                    },
                                    text: "Yes",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      text: "Yes",
                    ),
                  ),
                ],
              ),
            ],
          );
        }));
        buttons.add(const SizedBox(width: 8));
        buttons.add(_actionButton(context, "Reject", bayaInfraRed, Icons.close, () {
          _showStatusSheet(context, "Update Status - Reject", "REJECTED", false, false);
        }));
      } else if (statusCode == 'CLOSED') {
        buttons.add(_actionButton(context, "Reopen", Colors.deepPurple, Icons.history, () {
          _showStatusSheet(context, "Reopen Task", "REOPENED", false, false);
        }));
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(children: buttons.map((e) => e is SizedBox ? e : Expanded(child: e)).toList());
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

  Widget _actionButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context, String title, String code, bool workStatus, bool attachments) {
    ServiceRequestDashboardProvider provider = ProviderScope.containerOf(context).read(serviceRequestDashboardProvider);
    if(code == "REVIEWD"){
      BaseDialog.show<
          bool>(
        context: context,
        title: "Confirm Status Change",
        message: "Are you sure you want to review this task?",
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

                      await provider.updateStatus(
                        statusCode: code,
                        task: widget.task,
                        statusType: "TASK",
                        onSuccess: (msg) {
                          onSaveDialog(
                              context: context,
                              title: "Success",
                              transNo:"",
                              icon: Icons.check_circle_outlined,
                              iconColor: bayaInfraGreen,
                              message: " Task reviewed successfully.",

                              onClick: () {
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
                        },);


                  },
                  text: "Yes",
                ),
              ),
            ],
          ),
        ],
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatusUpdateBottomSheet(
        title: title,
        statusCode: code,
        task: widget.task,
        showWorkStatus: workStatus,
        showAttachments: attachments,
      ),
    );
  }

  Widget _buildCoordinatorMenu(BuildContext context, ServiceRequestDashboardProvider provider) {
    ServiceTaskModel task = widget.task;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      icon: Icon(Icons.more_horiz, size: 24, color: Theme.of(context).primaryColor),
      onSelected: (value) {
        switch (value) {
          case 'reassign':
            context.pushNamed(
              AppRoutes.reassignEngineerScreen,
              extra: {'currentTicket': provider.currentTicket,"task": task, "isAssignMode": false},
            );
            break;
            case 'assign':
            context.pushNamed(
              AppRoutes.reassignEngineerScreen,
              extra: {'currentTicket': provider.currentTicket,"task": task, "isAssignMode": true},
            );
            break;
          case 'closure_date':
            _showClosureDateDialog(context, provider);
            break;
          case 'client_dependency':
            _showClientDependencyDialog(context, provider);
            break;
        }
      },
      itemBuilder: (context) => [
        if((task.statusCode == "ASSIGNED"
            ||task.statusCode == "ACCEPTED" || task.statusCode == "SEND_BACK" || task.statusCode == "REOPENED"))
        const PopupMenuItem(
          value: 'reassign',
          height: 38,
          child: Row(children: [Icon(Icons.person_add_alt_1, size: 18), SizedBox(width: 8), Text('Reassign Task Owner', style: TextStyle(fontSize: 13))]),
        ),
        if(task.statusCode == "ASSIGNMENT_PENDING")
        const PopupMenuItem(
          value: 'assign',
          height: 38,
          child: Row(children: [Icon(Icons.person_add_alt_1, size: 18), SizedBox(width: 8), Text('Assign Task Owner', style: TextStyle(fontSize: 13))]),
        ),
        const PopupMenuItem(
          value: 'closure_date',
          height: 38,
          child: Row(children: [Icon(Icons.calendar_month, size: 18), SizedBox(width: 8), Text('Update Closure Date', style: TextStyle(fontSize: 13))]),
        ),
        const PopupMenuItem(
          value: 'client_dependency',
          height: 38,
          child: Row(children: [Icon(Icons.link, size: 18), SizedBox(width: 8), Text('Update Client Dependency', style: TextStyle(fontSize: 13))]),
        ),
      ],
    );
  }

  void _showClosureDateDialog(BuildContext context, ServiceRequestDashboardProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                Theme.of(context).primaryColorDark,
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
            textSelectionTheme:
            const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.black26,
              selectionHandleColor: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      provider.updateTaskClosureDate(
        taskId: widget.task.id ?? 0,
        targetClosureDate: formattedDate,
        lastModDate: widget.task.lastModDate ?? "",
        onSuccess: () {
          onSaveDialog(
              context: context,
              title: "Success",
              transNo:"",
              icon: Icons.check_circle_outlined,
              iconColor: bayaInfraGreen,
              message: "Target Closure Date updated successfully.",

              onClick: () {

                GoRouter.of(context).pop();

              });

        },
        onFailure: (err) {
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
  }

  void _showClientDependencyDialog(BuildContext context, ServiceRequestDashboardProvider provider) {
    bool isChecked = widget.task.clientdependancyyn == "Y";
    final initialChecked = isChecked;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Update Client Dependency",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDisabledField("Ticket No", provider.currentTicket?.ticketNo ?? ""),
                          const SizedBox(height: 16),
                          _buildDisabledField("Task", widget.task.taskName ?? widget.task.description ?? ""),
                          const SizedBox(height: 20),
                          Text(
                            "Update the client dependency status for this task:",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: isChecked,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      isChecked = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text("Client Dependency", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BaseElevatedButton(
                            width: MediaQuery.of(context).size.width * 0.2,
                            onPressed: () => Navigator.pop(context),
                            backgroundColor: Theme.of(context).primaryColor,
                            text: "Cancel",
                          ),
                          const SizedBox(width: 12),
                          BaseElevatedButton(
                            width: MediaQuery.of(context).size.width * 0.2,
                            onPressed: () {
                              if (isChecked == initialChecked) {
                                onSaveDialog(
                                  transNo:"",
                                  context: context,
                                  title: "Failure",
                                  message: "The client dependency value has not changed.",
                                  icon: Icons.error,
                                  iconColor: bayaInfraRed,
                                  onClick: () => GoRouter.of(context).pop(),
                                );
                                return;
                              }
                              _confirmUpdate(context, provider, isChecked ? "Y" : "N");
                            },

                            text: "Submit",

                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.titleLarge,
            children: const [
               TextSpan(text: " : ", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style:Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  void _confirmUpdate(BuildContext context, ServiceRequestDashboardProvider provider, String newStatus) {
    BaseDialog.show(
      context: context,
      title: "Confirm Update",
      message: "Are you sure you want to update the client dependency for this task?",
      actions: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: BaseElevatedButton(
                backgroundColor: bayaInfraDisabledColor,
                onPressed: () => Navigator.pop(context),
                text: "No",
              ),
            ),
            Expanded(
              child: BaseElevatedButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {

                  provider.updateTaskClientDependency(
                    taskId: widget.task.id ?? 0,
                    clientDependencyYN: newStatus,
                    lastModDate: widget.task.lastModDate ?? "",
                    onSuccess: () {
                      onSaveDialog(
                        context: context,
                        title: "Success",
                        transNo: "",
                        icon: Icons.check_circle_outlined,
                        iconColor: bayaInfraGreen,
                        message: "Client dependency updated successfully",
                        onClick: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    },
                    onFailure: (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message))),
                  );
                },
                text: "Yes",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// _AttachmentsRow  (unchanged)

class _AttachmentsRow extends StatelessWidget {
  final ServiceTaskModel task;
  final ServiceTasksProvider provider;

  const   _AttachmentsRow({
    required this.task,
    required this.provider,
  });

  static _FileTypeStyle _styleFor(String hint) {
    switch (hint) {
      case 'pdf':
        return const _FileTypeStyle('assets/png/pdf.png', Color(0xFFE74C3C));
      case 'xls':
        return const _FileTypeStyle('assets/png/excel.png', Color(0xFF27AE60));
      case 'doc':
        return const _FileTypeStyle('assets/png/doc.png', Color(0xFF2980B9));
      case 'image':
        return const _FileTypeStyle('assets/png/image.png', Color(0xFF6366F1));
      default:
        return const _FileTypeStyle('assets/png/file.png', Color(0xFF8E44AD));
    }
  }

  String _getShortFileName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return 'File';
    final dotIndex = fileName.lastIndexOf('.');
    String name = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    String ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';
    if (name.length > 8) name = '${name.substring(0, 5)}...';
    return '$name$ext';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (task.attachments.isEmpty) {
      return Row(
        children: [
          Icon(Icons.attachment_rounded, size: 18, color: theme.hintColor),
          const SizedBox(width: 6),
          Text(
            'No attachments',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: task.attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final att = task.attachments[index];
          final hint = provider.getFileType(att.fileName);
          final style = _styleFor(hint);
          final isImage = hint == 'image';
          final shortName = _getShortFileName(att.fileName);

          return GestureDetector(
            onTap: () =>
                _openAttachment(context, att, hint),
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isImage
                        ? Image.network(
                            att.url ?? '',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _iconTile(style, 50),
                          )
                        : _iconTile(style, 45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconTile(_FileTypeStyle style, double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.08),
      ),
      child: Image.asset(style.assetPath, fit: BoxFit.contain),
    );
  }

  void _openAttachment(
      BuildContext context, TaskAttachmentModel att, String hint) {
    final url = att.url ?? '';
    final name = att.fileName ?? '';

    switch (hint) {
      case 'image':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NetworkImageViewerScreen(url: url, fileName: name),
        ));
        break;
      case 'pdf':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: url, fileName: name),
        ));
        break;
      default:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GoogleDocsViewerScreen(fileUrl: url, fileName: name),
        ));
    }
  }
}

class _FileTypeStyle {
  final String assetPath;
  final Color color;
  const _FileTypeStyle(this.assetPath, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildTaskStatusBadge(
    BuildContext context, String status, bool hasAnyAction) {
  Color backgroundColor;
  Color textColor = bayaInfraWhiteColor;
  IconData icon;
  String displayStatus = status;

  switch (status.toUpperCase()) {
    case "ASSIGNMENT_PENDING":
    case "PENDING":
      backgroundColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF475569);
      icon = Icons.pending_outlined;
      displayStatus = "PENDING";
      break;
    case "ASSIGNED":
      backgroundColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0369A1);
      icon = Icons.person_outline;
      displayStatus = "ASSIGNED";
      break;
    case "ACCEPTED":
    case "IN_PROGRESS":
      backgroundColor = const Color(0xFFD8FCD8);
      textColor = const Color(0xFF1C811C);
      icon = Icons.play_circle_outline;
      displayStatus = status.toUpperCase();
      break;
    case "SUBMITTED":
      backgroundColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1D4ED8);
      icon = Icons.send_rounded;
      displayStatus = "SUBMITTED";
      break;
    case "REVIEWD":
    case "REVIEWED":
      backgroundColor = const Color(0xFFEDE9FE);
      textColor = const Color(0xFF6D28D9);
      icon = Icons.rate_review_outlined;
      displayStatus = "REVIEWED";
      break;
    case "SEND_BACK":
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      icon = Icons.replay;
      displayStatus = "REJECTED";
      break;
    case "REJECTED":
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      icon = Icons.assignment_return_outlined;
      displayStatus = "REJECTED";
      break;
    case "CLOSED":
      backgroundColor = const Color(0xFF1C811C);
      textColor = Colors.white;
      icon = Icons.check_circle_outline;
      displayStatus = "CLOSED";
      break;
    case "REOPENED":
      backgroundColor = const Color(0xFFFAD4FA);
      textColor = const Color(0xFFC5219C);
      icon = Icons.history_rounded;
      displayStatus = "REOPENED";
      break;
    case "CANCELLED":
      backgroundColor = const Color(0xFFDC2626);
      textColor = Colors.white;
      icon = Icons.cancel_outlined;
      displayStatus = "CANCELLED";
      break;
    default:
      backgroundColor = bayaInfraGreyColor;
      textColor = Colors.white;
      icon = Icons.help_outline;
      displayStatus = status.toUpperCase();
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: textColor.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 6),
        Text(
          displayStatus,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 10,
              ),
        ),
      ],
    ),
  );
}
Widget _buildNotInScopeBadge(
    BuildContext context, String status, bool hasAnyAction) {
  Color textColor = bayaInfraWhiteColor;
  String displayStatus = status;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [new4, new4.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block, size: 12, color: textColor),
        const SizedBox(width: 6),
        Text(
          displayStatus,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}