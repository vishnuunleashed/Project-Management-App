import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_details_landing_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/widgets/status_badge_parent.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart' as intl;

/// Grid-menu landing page for a service ticket.
/// Shows a ticket summary header + 3×3 grid of feature tiles.
class ServiceDetailsLandingPage extends ConsumerStatefulWidget {
  const ServiceDetailsLandingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceDetailsLandingPage> createState() =>
      _ServiceDetailsLandingPageState();
}

class _ServiceDetailsLandingPageState
    extends ConsumerState<ServiceDetailsLandingPage> with RouteAware {
  ServiceRequestDashboardProvider? _dashProvider;
  ServiceDetailsLandingProvider? _landingProvider;

  // ── RouteAware lifecycle ───────────────────────────────────────────────

  @override
  void didPopNext() {
    final provider = ref.read(serviceDetailsLandingProvider);

    provider.refreshIfNeeded();
    final dashProvider = ref.read(serviceRequestDashboardProvider);
    dashProvider.fetchCallTrackerInfo();
    dashProvider.fetchServiceBasedSupportDashboardData();
    ref.read(callTrackerProvider).loadTickets();
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dashProvider = ref.read(serviceRequestDashboardProvider);
    _landingProvider = ref.read(serviceDetailsLandingProvider);
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _dashProvider?.disposeVariables();
    _landingProvider?.disposeVariables();
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BaseView<ServiceDetailsLandingProvider>(
      provider: serviceDetailsLandingProvider,
      initState: (context, provider, ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initState(extra: extra);

        // Also initialize the shared dashboard provider used by child routes
        ref.read(serviceRequestDashboardProvider).initState(extra: extra);
      },

      appBar: CustomAppBar(
        title: const Text('Service Ticket'),
      ),
      builder: (context, provider, ref) {
        final dashProvider = ref.watch(serviceRequestDashboardProvider);
        final ticket = dashProvider.currentTicket;
        return Stack(
          children: [
            _buildBody(context, provider, ticket),
            Visibility(
              visible: provider.isCancelServiceTicketLoading && (provider.loadingStatus.loader != Loader.loading),
                child:Center(
                  child: BaseLoadingView(progress: provider.loadingProgress,
                    message: provider.loadingStatus.message,),
                ) )
          ],
        );
      },
    );
  }

  // ── Body: ticket header + grid ─────────────────────────────────────────

  Widget _buildBody(BuildContext context,
      ServiceDetailsLandingProvider provider, CallTicketModel? ticket) {
    final items = _buildMenuItems(provider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ticket summary card ──────────────────────────────────────
          if (ticket != null) _TicketSummaryCard(ticket: ticket),
          const SizedBox(height: 4),

          // ── 3×3 Grid menu ───────────────────────────────────────────
          if (items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              elevation: 0.5,

              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).cardColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 0,
                  childAspectRatio: 0.8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: items.map((item) {
                    return _MenuTile(
                      icon: item.icon,
                      label: item.label,
                      color: item.color,
                      onTap: item.onTap,
                      bgColor: item.bgColor,
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Menu item definitions ──────────────────────────────────────────────
  List<_MenuItem> _buildMenuItems(ServiceDetailsLandingProvider provider) {
    final items = <_MenuItem>[];

    // 1 — Service Details → Steel Blue (position 0 → cardAccents[0] of Observations)
    items.add(_MenuItem(
      icon: Icons.description_outlined,
      label: 'Service\nDetails',
      color: const Color(0xFF4A6580),       // cardIconColors[0]
      bgColor: const Color(0xFFEEF3F8),     // cardAccents[0]
      onTap: () => GoRouter.of(context).pushNamed(
        AppRoutes.serviceDetailsScreen,
        extra: {'transid': provider.currentTicketId},
      ),
    ));

    // 2 — Edit Ticket → Terracotta (position 1)
    if (provider.canEditTicket) {
      items.add(_MenuItem(
        icon: Icons.edit_outlined,
        label: 'Edit\nTicket',
        color: const Color(0xFFB8745A),     // cardIconColors[1]
        bgColor: const Color(0xFFF7ECE8),   // cardAccents[1]
        onTap: () => GoRouter.of(context).pushNamed(
          AppRoutes.addServiceRequestScreen,
          extra: {"currentTicketDetails": provider.currentTicket},
        ),
      ));
    }

    // 3 — Add Support → Moss Green (position 2)
    if (provider.canAddSupport) {
      items.add(_MenuItem(
        icon: Icons.add_circle_outline,
        label: 'Add\nSupport',
        color: const Color(0xFF4A8C55),     // cardIconColors[2]
        bgColor: const Color(0xFFEDF6EF),   // cardAccents[2]
        onTap: () {
          GoRouter.of(context).pushNamed(
            AppRoutes.addSupportRequest,
            extra: {
              "IsFromCallTracker": true,
              "callTrackerId": provider.currentTicket?.id,
            },
          );
        },
      ));
    }

    // 4 — Support Requests → Dusty Purple (position 3)
    items.add(_MenuItem(
      icon: Icons.support_agent_outlined,
      label: 'Support\nRequests',
      color: const Color(0xFF7B6C8D),       // cardIconColors[3]
      bgColor: const Color(0xFFF2EEF6),     // cardAccents[3]
      onTap: () => GoRouter.of(context).pushNamed(
        AppRoutes.serviceSupportSummaryScreen,
        extra: {'transid': provider.currentTicketId},
      ),
    ));

    // 5 — Ticket Tracking → Steel Blue (position 4, wraps back to [0])
    items.add(_MenuItem(
      icon: Icons.travel_explore,
      label: 'Ticket\nTracking',
      color: const Color(0xFF4A6580),       // cardIconColors[4]
      bgColor: const Color(0xFFEEF3F8),     // cardAccents[4]
      onTap: () => GoRouter.of(context).pushNamed(
        AppRoutes.serviceTrackingProgressScreen,
        extra: {'ticketId': provider.currentTicket?.id},
      ),
    ));

    // 6 — Reassign Engineer → Terracotta (position 5 → index 1)
    // if (provider.canReassignEng) {
    //   items.add(_MenuItem(
    //     icon: Icons.person_add_alt_1_outlined,
    //     label: 'Reassign\nEngineer',
    //     color: const Color(0xFFB8745A),     // cardIconColors[1]
    //     bgColor: const Color(0xFFF7ECE8),   // cardAccents[1]
    //     onTap: () {
    //       GoRouter.of(context).pushNamed(
    //         AppRoutes.reassignEngineerScreen,
    //         extra: {'currentTicket': provider.currentTicket},
    //       );
    //     },
    //   ));
    // }

    // 7 — Update Closure Date → Moss Green (position 6 → index 2)
    // if (provider.canUpdateClosure) {
    //   items.add(_MenuItem(
    //     icon: Icons.edit_calendar_outlined,
    //     label: 'Update\nClosure Date',
    //     color: const Color(0xFF4A8C55),     // cardIconColors[2]
    //     bgColor: const Color(0xFFEDF6EF),   // cardAccents[2]
    //     onTap: () {
    //       _showUpdateClosureDateDialog(
    //         context,
    //         lastModDate: provider.currentTicket?.lastModDate,
    //         ticketId: provider.currentTicket?.id ?? 0,
    //         initialDate: provider.changedTgtClosureDate,
    //       );
    //     },
    //   ));
    // }


    /// -check ticket cancellation antigravity
    if(provider.canCancelTicket) {
      items.add(_MenuItem(
        icon: Icons.cancel_outlined,
        label: 'Ticket\nCancellation',
        color: const Color(0xFFB8745A),
        // cardIconColors[2]
        bgColor: const Color(0xFFF7ECE8),
        // cardAccents[2]
        onTap: () {
          ticketCancelConfirmDialog(context: NavigatorKey.navKey.currentState!.context,
              ticketNo:provider.currentTicket?.ticketNo ?? "" ,
              provider: provider,
              ref: ref,
              title: provider.isTicketStarted
                  ? "Warning"
                  : "Ticket Cancellation",
              subTitle: provider.isTicketStarted
                  ? "Some tasks are still waiting for action. Are you sure you want to cancel this ticket?"
                  : "Are you sure you want to cancel this ticket?",
              onTapYes: () {
                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  emailSendConfirmDialog(
                    context: context,
                    provider: provider,
                    ref: ref,
                    title: 'Do you want to send an email notification to the client?',
                    icon: const Icon(Icons.email_outlined),
                    onTapYes: () async {
                      await provider.cancelServiceTicket(
                        ticketId: provider.currentTicket?.id ?? 0,
                        lastModDate: provider.currentTicket?.lastModDate ?? "",
                        notifyClientYN: "Y",
                        onSuccess: () {
                          ref.read(serviceRequestDashboardProvider).fetchCallTrackerInfo();
                          _showResultDialog(
                            context: NavigatorKey.navKey.currentState!.context,
                            title: "Success",
                            message: "Service ticket cancelled successfully",
                            icon: Icons.check_circle_outlined,
                            iconColor: bayaInfraGreen,
                            onClick: () => GoRouter.of(
                              NavigatorKey.navKey.currentState!.context,
                            ).pop(),
                          );
                        },
                      );
                    },
                    onTapNo: () async {
                      await provider.cancelServiceTicket(
                        ticketId: provider.currentTicket?.id ?? 0,
                        lastModDate: provider.currentTicket?.lastModDate ?? "",
                        notifyClientYN: "N",
                        onSuccess: () {
                          ref.read(serviceRequestDashboardProvider).fetchCallTrackerInfo();
                          _showResultDialog(
                            context: NavigatorKey.navKey.currentState!.context,
                            title: "Success",
                            message: "Service ticket cancelled successfully",
                            icon: Icons.check_circle_outlined,
                            iconColor: bayaInfraGreen,
                            onClick: () => GoRouter.of(
                              NavigatorKey.navKey.currentState!.context,
                            ).pop(),
                          );
                        },
                      );
                    },
                  );
                });
              },
              icon: Icon(Icons.close, size: 36, color: bayaInfraRedColor));
        },
      ));
    }

    return items;
  }
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
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: onClick,
        text: "Ok",
      ),
    ],
  );
}

ticketCancelConfirmDialog({required BuildContext context,
  required ServiceDetailsLandingProvider provider,
  required WidgetRef ref,
  required String title,
  required String ticketNo,
  required String subTitle,
  required Function() onTapYes,
  required Widget icon}){

  return BaseDialog.show(
    barrierDismissible: false,
      context: context,
      title: "Confirm",
      subtitle: ticketNo,
      message: subTitle,
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
                  onTapYes();

                },
              ),
            )
          ],
        )
      ]
  );

}

emailSendConfirmDialog({
  required BuildContext context,
  required ServiceDetailsLandingProvider provider,
  required WidgetRef ref,
  required String title,
  required Function() onTapYes,
  required Function() onTapNo,
  required Widget icon,
}) {
  return BaseDialog.show(
    barrierDismissible: false,
    context: context,
    title: "Notify Client",
    message: title,
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
                onTapNo();
              },
              backgroundColor: bayaInfraDisabledColor,
              text: "No",
            ),
          ),
          Expanded(
            child: BaseElevatedButton(
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              text: "Yes",
              onPressed: () {
                GoRouter.of(context).pop();
                onTapYes();
              },
            ),
          ),
        ],
      )
    ],
  );
}

// void _showUpdateClosureDateDialog(BuildContext context, {String? lastModDate, int? ticketId, DateTime? initialDate}) {
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return BaseStatelessConsumer<ServiceDetailsLandingProvider>(
//         provider: serviceDetailsLandingProvider,
//         builder: (context, provider, ref) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title:  Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Update Closure Date',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 4),
//                 Text(
//                   'Target Closure Date',
//                   style: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 const SizedBox(height: 4),
//                 CommonDatesPicker(
//                   key: ValueKey(provider.changedTgtClosureDate),
//                   onChange: (date) {
//                     provider.setSelectedClosureDate(date);
//                   },
//                   initialDate:
//                   provider.changedTgtClosureDate ?? DateTime.now(),
//                   firstDate: DateTime.now(),
//                 ),
//               ],
//             ),
//             actions: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: BaseElevatedButton(
//                       text: "Cancel",
//                       textColor: Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.color ??
//                           Colors.grey,
//                       backgroundColor:
//                       Theme.of(context).scaffoldBackgroundColor,
//                       borderColor: Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.color ??
//                           Colors.grey,
//                       elevation: 0,
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         provider.clearSelectedClosureDate();
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: BaseElevatedButton(
//                       text: 'Submit',
//                       onPressed: () {
//                         print("last mod date 2-- ${lastModDate}");
//                         provider.updateClosureDate(
//                           ticketId: ticketId ?? 0,
//                           lastModDate: lastModDate,
//                           onSuccess: () {
//                             GoRouter.of(context).pop();
//                             BaseSnackBar().show(
//                                 message:
//                                 "Closure date updated successfully");
//                           },
//                           onFailure: (e) {
//                             GoRouter.of(context).pop();
//                             BaseSnackBar().show(message: e.toString());
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }
// ═══════════════════════════════════════════════════════════════════════════════
// TICKET SUMMARY CARD — compact overview pulled from service detail tab one
// ═══════════════════════════════════════════════════════════════════════════════

class _TicketSummaryCard extends StatelessWidget {
  final CallTicketModel ticket;

  const _TicketSummaryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0.5,

      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).cardColor,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Ticket No + Status Badge ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket No :',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        ticket.ticketNo ?? '',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      // Priority badge
                      _buildPriorityBadge(theme),
                    ],
                  ),
                ),
                StatusBadge(
                  status: ticket.status ?? '',
                  size: StatusButtonSize.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Row 2: Date progress ──────────────────────────────────
            // _buildDateProgress(context, theme, colorScheme),

            // ── Row 3: Key details chips ──────────────────────────────
            if (ticket.client != null && ticket.client!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip(theme, Icons.business, ticket.client!),
                  if (ticket.category != null && ticket.category!.isNotEmpty)
                    _buildChip(theme, Icons.category, ticket.category!),
                  // if (ticket.assignedUser != null &&
                  //     ticket.assignedUser!.isNotEmpty)
                  //   _buildChip(
                  //       theme, Icons.engineering, ticket.assignedUser!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:  getPriorityColor(ticket.priority).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 14, color: getPriorityColor(ticket.priority)),
          const SizedBox(width: 4),
          Text(
            ticket.priority ?? '',
            style: theme.textTheme.labelSmall?.copyWith(
              color: getPriorityColor(ticket.priority),
            ),
          ),
        ],
      ),
    );
  }

  // Get priority color
  Color getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;

    if (priority.contains('1')) {
      return Colors.red;
    } else if (priority.contains('2')) {
      return Colors.orange;
    } else if (priority.contains('3')) {
      return bayaInfraPaleGreen;
    } else {
      return Colors.green;
    }
  }

  Widget _buildChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDateProgress(
  //     BuildContext context, ThemeData theme, ColorScheme colorScheme) {
  //
  //   final now = DateTime.now();
  //
  //   DateTime? createdDate = DateTime.tryParse(ticket.ticketDate ?? '');
  //   // DateTime? targetClosureDate = DateTime.tryParse(ticket.targetClosureDate ?? '');
  //   DateTime? statusDate = DateTime.tryParse(ticket.statusDate ?? '');
  //
  //   int delayedDays = 0;
  //   int remainingDays = 0;
  //   int closedDays = 0;
  //
  //   if (createdDate != null && targetClosureDate != null) {
  //     final normalizedNow = DateTime(now.year, now.month, now.day);
  //
  //     remainingDays = targetClosureDate.difference(normalizedNow).inDays;
  //     if (remainingDays < 0) remainingDays = 0;
  //
  //     if (targetClosureDate.isBefore(now)) {
  //       delayedDays = now.difference(targetClosureDate).inDays;
  //     }
  //   }
  //
  //   if (ticket.status == "Closed" &&
  //       statusDate != null &&
  //       targetClosureDate != null) {
  //     closedDays = statusDate.difference(targetClosureDate).inDays;
  //     if (closedDays < 0) closedDays = 0;
  //   }
  //
  //   /// Date labels
  //   final leftLabel = ticket.status == "Closed" ? "Tgt Closure" : "Created";
  //   final rightLabel = ticket.status == "Closed" ? "Closed" : "Tgt Closure";
  //
  //   // final leftDate = ticket.status == "Closed"
  //   //     ? _formatDate(ticket.targetClosureDate)
  //   //     : _formatDate(ticket.ticketDate);
  //   //
  //   // final rightDate = ticket.status == "Closed"
  //   //     ? _formatDate(ticket.statusDate)
  //   //     : _formatDate(ticket.targetClosureDate);
  //
  //   /// Status pill
  //   Widget statusPill;
  //
  //   if (targetClosureDate == null) {
  //     statusPill = _pill("Closure date not set", Colors.grey, theme);
  //   } else if (ticket.status == "Closed" && statusDate != null) {
  //     statusPill = (statusDate.isAfter(targetClosureDate))
  //         ? _pill(
  //         "$closedDays day${closedDays == 1 ? '' : 's'} delayed",
  //         bayaInfraRed,
  //         theme)
  //         : _pill("On Time", bayaInfraGreen, theme);
  //   } else if (delayedDays > 0) {
  //     statusPill = _pill(
  //         "$delayedDays day${delayedDays == 1 ? '' : 's'} delayed",
  //         bayaInfraRed,
  //         theme);
  //   } else if (remainingDays > 0) {
  //     statusPill = Text(
  //       "$remainingDays day${remainingDays == 1 ? '' : 's'} left",
  //       style: theme.textTheme.titleSmall,
  //     );
  //   } else {
  //     statusPill = _pill("Due today", Colors.orange, theme);
  //   }
  //
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(leftLabel,
  //               style: theme.textTheme.labelMedium),
  //           statusPill,
  //           Text(rightLabel,
  //               style: theme.textTheme.labelMedium),
  //         ],
  //       ),
  //       const Divider(thickness: 1.5, color: Color(0xFFB0B0B0)),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(leftDate,
  //               style: theme.textTheme.labelLarge),
  //           Text(rightDate,
  //               style: theme.textTheme.labelLarge),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _pill(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: bayaInfraWhiteColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "";
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return "";
    return intl.DateFormat('MMM dd, yyyy').format(parsed);
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: bgColor,             // ← exact palette bg instead of opacity hack
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}