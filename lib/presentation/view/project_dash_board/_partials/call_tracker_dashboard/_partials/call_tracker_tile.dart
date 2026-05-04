
// Call Track Support Tile Widget
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/project_based_dashboard/_partials/_project_sub_dashboard.dart';
class CallTrackSupportTicket {
  final int ticketId;
  final int clientid;
  final String clientName;
  final int ticketCount;
  final String? siteName;
  final String ticketNo;
  final String isEngineerYN;
  final int optionId;

  final int open;
  final int openSubmit;
  final int openAssigned;
  final int openReassigned;
  final int openForwarded;

  final int delayed;
  final int delayedSubmit;
  final int delayedAssigned;
  final int delayedReassigned;
  final int delayedForwarded;
  bool isExpandedOpen;
  bool isExpandedDelayed ;


  final int total;

  CallTrackSupportTicket({
    required this.ticketId,
    required this.clientid,
    required this.clientName,
    this.siteName,
    required this.ticketNo,
    required this.isEngineerYN,
    required this.optionId,
    required this.open,
    required this.openSubmit,
    required this.openAssigned,
    required this.openReassigned,
    required this.openForwarded,
    required this.delayed,
    required this.delayedSubmit,
    required this.delayedAssigned,
    required this.delayedReassigned,
    required this.delayedForwarded,
    required this.total,
    required this.ticketCount,
     this.isExpandedDelayed =false,
     this.isExpandedOpen = false,
  });



  int get subtotal => open + delayed;

  CallTrackSupportTicket copyWith({
    int? ticketId,
    int? clientid,
    String? clientName,
    int? ticketCount,
    String? siteName,
    String? ticketNo,
    String? isEngineerYN,
    int? optionId,
    int? open,
    int? openSubmit,
    int? openAssigned,
    int? openReassigned,
    int? openForwarded,
    int? delayed,
    int? delayedSubmit,
    int? delayedAssigned,
    int? delayedReassigned,
    int? delayedForwarded,
    bool? isExpandedOpen,
    bool? isExpandedDelayed,
    int? total,
  }) {
    return CallTrackSupportTicket(
      ticketId: ticketId ?? this.ticketId,
      clientid: clientid ?? this.clientid,
      clientName: clientName ?? this.clientName,
      ticketCount: ticketCount ?? this.ticketCount,
      siteName: siteName ?? this.siteName,
      ticketNo: ticketNo ?? this.ticketNo,
      isEngineerYN: isEngineerYN ?? this.isEngineerYN,
      optionId: optionId ?? this.optionId,
      open: open ?? this.open,
      openSubmit: openSubmit ?? this.openSubmit,
      openAssigned: openAssigned ?? this.openAssigned,
      openReassigned: openReassigned ?? this.openReassigned,
      openForwarded: openForwarded ?? this.openForwarded,
      delayed: delayed ?? this.delayed,
      delayedSubmit: delayedSubmit ?? this.delayedSubmit,
      delayedAssigned: delayedAssigned ?? this.delayedAssigned,
      delayedReassigned: delayedReassigned ?? this.delayedReassigned,
      delayedForwarded: delayedForwarded ?? this.delayedForwarded,
      isExpandedOpen: isExpandedOpen ?? this.isExpandedOpen,
      isExpandedDelayed: isExpandedDelayed ?? this.isExpandedDelayed,
      total: total ?? this.total,
    );
  }
}

class CallTrackSupportTile extends ConsumerStatefulWidget {
  final CallTrackSupportTicket ticket;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  final VoidCallback onAllOpenTap;
  final VoidCallback onAllDelayedTap;
  final VoidCallback onTapClientName;
  final VoidCallback onAllTap;
  final int index;

  final Function(String status,String subStatus, bool isDelayed, CallTrackSupportTicket ticket)? onSubCountTap;
  const CallTrackSupportTile({
    super.key,
    required this.index,
    required this.ticket,
    required this.scaffoldKeyHome,
    required this.onAllOpenTap,
    required this.onAllDelayedTap,
    required this.onSubCountTap,
    required this.onTapClientName,
    required this.onAllTap,
  });

  @override
  ConsumerState<CallTrackSupportTile> createState() =>
      _CallTrackSupportTileState();
}

class _CallTrackSupportTileState extends ConsumerState<CallTrackSupportTile> {
  @override
  Widget build(BuildContext context) {
    return BaseConsumer(
      provider: projectDashboardProvider,
      builder: (context, provider, ref) {
        return GestureDetector(
          onLongPress: () {
            // widget.onLongPress();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: widget.onTapClientName,
                                      child: Text(
                                        widget.ticket.clientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.ticket.ticketNo.isNotEmpty && widget.ticket.ticketNo != 'null')
                                  Text(
                                    'Ticket #${widget.ticket.ticketNo}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  )
                                else if (widget.ticket.siteName != null && widget.ticket.siteName!.isNotEmpty)
                                  Text(
                                    widget.ticket.siteName!,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                              ],
                            ),
                            IconButton(
                              tooltip: "All Service Support",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: widget.onAllTap,
                              icon: Icon(
                                Icons.all_inclusive,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.ticket.open > 0)
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                            provider.toggleTicketExpandedOpen(widget.index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: new6.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.ticket.isExpandedOpen
                                    ? new6
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Text(
                                  '${widget.ticket.open}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: new9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Open',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: new9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.ticket.open > 0 && widget.ticket.delayed > 0)
                      const SizedBox(width: 12),
                    if (widget.ticket.delayed > 0)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            provider.toggleTicketExpandedDelayed(widget.index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: new7.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.ticket.isExpandedDelayed
                                    ? new7
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Text(
                                  '${widget.ticket.delayed}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: new7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Delayed',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: new7,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.ticket.isExpandedOpen || widget.ticket.isExpandedDelayed)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.ticket.isExpandedOpen
                                  ? 'OPEN BREAKDOWN'
                                  : 'DELAYED BREAKDOWN',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                             GestureDetector(
                              onTap: () {
                                if (widget.ticket.isExpandedOpen) {
                                  provider.toggleTicketExpandedOpen(widget.index);
                                } else {
                                  provider.toggleTicketExpandedDelayed(widget.index);
                                }
                              },
                              child: const Icon(Icons.close, size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: widget.ticket.isExpandedOpen
                              ? [
                                  _buildStatusChip("All", widget.ticket.open, context, onTap: () => widget.onAllOpenTap.call()),
                                  _buildStatusChip("Assigned", widget.ticket.openAssigned, context, onTap: () => widget.onSubCountTap?.call("OPEN","ASSIGNED", false,widget.ticket)),
                                  _buildStatusChip("Forwarded", widget.ticket.openForwarded, context, onTap: () => widget.onSubCountTap?.call("OPEN","FORWARD", false,widget.ticket)),
                                  _buildStatusChip("Submit", widget.ticket.openSubmit, context, onTap: () => widget.onSubCountTap?.call("OPEN","SUBMIT", false,widget.ticket)),
                                  _buildStatusChip("Reassigned", widget.ticket.openReassigned, context, onTap: () => widget.onSubCountTap?.call("OPEN","REASSIGNED", false,widget.ticket)),
                                ]
                              : [
                                  _buildStatusChip("All", widget.ticket.delayed, context, onTap: () => widget.onAllDelayedTap.call(), isDelayed: true),
                                  _buildStatusChip("Assigned", widget.ticket.delayedAssigned, context, onTap: () => widget.onSubCountTap?.call("DELAYED","ASSIGNED", true,widget.ticket), isDelayed: true),
                                  _buildStatusChip("Forwarded", widget.ticket.delayedForwarded, context, onTap: () => widget.onSubCountTap?.call("DELAYED","FORWARD", true,widget.ticket), isDelayed: true),
                                  _buildStatusChip("Submitted", widget.ticket.delayedSubmit, context, onTap: () => widget.onSubCountTap?.call("DELAYED","SUBMIT", true,widget.ticket), isDelayed: true),
                                  _buildStatusChip("Reassigned", widget.ticket.delayedReassigned, context, onTap: () => widget.onSubCountTap?.call("DELAYED","REASSIGNED", true,widget.ticket), isDelayed: true),
                                ],
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
  }

  Widget _buildStatusChip(String label, int count, BuildContext context,
      {bool isDelayed = false, VoidCallback? onTap}) {
    if (count == 0) return const SizedBox.shrink();
    final Color baseColor = isDelayed ? new7 : new6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: baseColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

