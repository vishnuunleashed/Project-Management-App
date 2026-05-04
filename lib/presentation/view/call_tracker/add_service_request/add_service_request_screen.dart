import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/add_service_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/add_service_request/service_ticket_add_screen.dart';
import 'package:interior_design/presentation/view/service_tasks/service_task_screen_add_card.dart';
import 'package:interior_design/presentation/view/service_tasks/service_tasks_screen.dart';

class AddServiceRequestScreen extends ConsumerWidget {
   AddServiceRequestScreen({super.key});
   final GlobalKey<ServiceTicketAddScreenState> _serviceTicketKey =
   GlobalKey<ServiceTicketAddScreenState>();



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
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () => GoRouter.of(context).pop(true),
                text: "Yes",
              ),
            ),
            Expanded(
              child: BaseElevatedButton(
                backgroundColor: bayaInfraDisabledColor,
                onPressed: () => GoRouter.of(context).pop(false),
                text: "No",
              ),
            ),
          ],
        ),
      ],
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final container = ProviderScope.containerOf(context);
    final provider = container.read(addServiceRequestProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: WillPopScope(
        onWillPop: () async {
            
          if (provider.hasUnsavedChanges()) {
            return await _onWillPop(context);
          }
          ref.watch(serviceDetailsLandingProvider).changeShouldRefreshAfterPop(true);
          return true;
        },
        child: BaseView<AddServiceRequestProvider>(

          provider: addServiceRequestProvider,
          appBar: CustomAppBar(
            shadowNeeded: true,
            title: ref.watch(addServiceRequestProvider).isEditMode
                ? const Text("Edit Ticket")
                : const Text("Add Service Ticket"),
            onBack: (context) async {
              if (provider.hasUnsavedChanges()) {
                return await _onWillPop(context);
              }
              return true;
            },
          ),
          initState: (context, provider, ref) {
            provider.initValues();
            final state = GoRouterState.of(context);
            final extra = state.extra as Map<String, dynamic>?;
            provider.setParameters(extra: extra);
          },
          dispose: (context) {},
          builder: (context, provider, ref) {
            final theme = Theme.of(context);
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // ── Tab bar ────────────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: TabBar(
                      isScrollable: false,
                      tabAlignment: TabAlignment.fill,
                      splashBorderRadius: BorderRadius.circular(10),
                      indicator: BoxDecoration(
                        color: theme.hintColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.primaryColor,
                          width: 1,
                        ),
                      ),
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).primaryColor,
                      dividerHeight: 0,
                      unselectedLabelColor: theme.textTheme.titleMedium?.color,
                      labelStyle: theme.textTheme.titleMedium,
                      unselectedLabelStyle: theme.textTheme.titleMedium,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 4),
                      tabs: [
                        Tab(
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Service Ticket',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Tab(
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Tasks',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Tab views ──────────────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 0: Service ticket form — zero params needed
                        ServiceTicketAddScreen(key: _serviceTicketKey,),
                        // Tab 1: Tasks
                        AddServiceTasksScreen(),
                      ],
                    ),
                  ),

                  // ── Bottom actions ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      spacing: 12,
                      children: [
                        if (!provider.isViewOnlyMode)
                          Visibility(
                            visible: !ref.watch(addServiceRequestProvider).isEditMode,
                            child: Expanded(
                              child: BaseElevatedButton(
                                text: "Clear",
                                textColor:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                    Colors.grey,
                                backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                                borderColor:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                    Colors.grey,
                                elevation: 0,
                                onPressed: () => provider.initValues(),
                              ),
                            ),
                          ),
                        Expanded(
                          child: BaseElevatedButton(
                            text: 'Save Ticket',
                            onPressed: provider.isViewOnlyMode
                                ? null
                                : () {
                              if (provider.isViewOnlyMode) {
                                GoRouter.of(context).pop();
                                return;
                              }

                              final formState = _serviceTicketKey
                                  .currentState?.formKey.currentState;

                              if (formState == null) {
                                BaseSnackBar().show(
                                    message:
                                    "Please switch to the Service Ticket tab and fill in required fields.");
                                return;
                              }

                              if (formState.validate()) {
                                if(provider.tasks.isNotEmpty){
                                   if(provider.tasks.any((task) => task.assignedUserId != null && (task.targetclosuredate == null || task.targetclosuredate!.isEmpty))) {
                                    BaseSnackBar().show(
                                        message:
                                        "Please set a target closure.");
                                  }
                                  else if(provider.selectedReporter == null && (provider.selectedEngineer != null || provider.tasks.any((task) => task.assignedUserId != null))){
                                    BaseSnackBar().show(
                                        message:
                                        "A Reviewer must be selected when a Task Owner is assigned");
                                  }
                                  else{
                                    BaseDialog.show(
                                      barrierDismissible: false,
                                        context: context,
                                        title: "Notify Client",
                                        message: 'Do you want to send an email notification to the client?',
                                        icon: Icon(Icons.email_outlined),
                                        actions: [
                                          Row(
                                            spacing: 8,
                                            children: [
                                              Expanded(
                                                  child: BaseElevatedButton(
                                                    borderRadius: 24,
                                                    onPressed: () {
                                                      GoRouter.of(context).pop();
                                                      _submitForm(context, provider,false );
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
                                                    GoRouter.of(context).pop();
                                                    _submitForm(context, provider,true );

                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        ]
                                    );

                                  }
                                }
                                else{
                                  BaseSnackBar().show(
                                      message:
                                      "Please add at least one task to save the ticket.");
                                }

                              }
                              else{
                                BaseSnackBar().show(
                                    message:
                                    "Please fill required fields.");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm(
      BuildContext context, AddServiceRequestProvider provider, bool notifyClientYN) {
    FocusScope.of(context).unfocus();

    provider.saveServiceRequest(
      notifyClientYN:notifyClientYN,
      onRequestSuccess: () {
        _showResultDialog(
          context: context,
          title: "Success",
          message:  provider.isEditMode
              ? "Service ticket edited successfully"
              : "Service ticket added successfully",
          icon: Icons.check_circle_outlined,
          iconColor: bayaInfraGreen,
          onClick: () {
            provider.initValues();
            FocusScope.of(context).unfocus();
            ProviderScope.containerOf(context)
                .read(callTrackerProvider)
                .loadTickets(changeStart: true);
            GoRouter.of(context).pop();

          },
        );
      },
      onRequestFailure: (e) {
        _showResultDialog(
          context: context,
          title: "Failure",
          message: e.toString(),
          icon: Icons.error,
          iconColor: bayaInfraRed,
          onClick: () => GoRouter.of(context).pop(),
        );
      },
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
      barrierDismissible: false,
      context: context,
      title: title,
      message: message,
      transNo: "",
      icon: Icon(icon, color: iconColor, size: 36),
      actions: [
        BaseElevatedButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: onClick,
          text: "Ok",
        ),
      ],
    );
  }
}