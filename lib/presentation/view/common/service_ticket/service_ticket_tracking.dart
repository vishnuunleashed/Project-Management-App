/*------------------------------------------------------------------------------
AUTHOR          : [Your Name]
CREATED DATE    : 03/02/2026
PURPOSE         : Service Tracking Progress Screen
MODULE/TOPIC    : Service Tracking UI
REMARKS         : Follows BaseView structure, retains generic type
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#    DATE            MODIFIED BY     TICKET#         DESCRIPTION
--------------------------------------------------------------------------------
1       03/02/2026      [Your Name]                     Initial Creation
2       03/02/2026      [Your Name]                     Refactored to BaseView
                                                        structure
3       03/02/2026      [Your Name]                     Comments merged inline
                                                        into timeline sorted by
                                                        statusdate (logs) vs
                                                        lastmoddate (comments)
4       03/02/2026      [Your Name]                     Task-level tracking added:
                                                        task logs (PENDING/
                                                        SUBMITTED/REVIEWD/
                                                        SEND_BACK) merged into
                                                        unified timeline; Tasks
                                                        summary card added.
5       03/02/2026      [Your Name]                     Task logs rendered as
                                                        second-level nested under
                                                        the ticket status entry
                                                        they temporally belong to.
------------------------------------------------------------------------------*/

import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/base_service_ticket_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// ---------------------------------------------------------------------------
// Data structures for the two-level timeline
// ---------------------------------------------------------------------------

/// A task log entry paired with its 1-based task number.
class _TaskLogEntry {
  final TicketLogModel log;
  final int taskIndex;
  _TaskLogEntry(this.log, this.taskIndex);
}

/// A top-level timeline "bucket":
///   • one ticket-level log  (or a standalone comment)
///   • zero-or-more task logs that fall between this ticket event and the next
class _TimelineBucket {
  // Exactly one of these is set
  final TicketLogModel? ticketLog;
  final TicketCommentModel? comment;

  /// Task logs whose statusdate falls between this bucket's time and the next
  /// bucket's time (populated after all buckets are built).
  final List<_TaskLogEntry> taskLogs;

  final DateTime sortKey;

  _TimelineBucket.fromTicketLog(TicketLogModel l)
      : ticketLog = l,
        comment = null,
        taskLogs = [],
        sortKey = _parse(l.statusdate);

  _TimelineBucket.fromComment(TicketCommentModel c)
      : comment = c,
        ticketLog = null,
        taskLogs = [],
        sortKey = _parse(c.lastmoddate ?? '');

  static DateTime _parse(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime(1970);
    }
  }

  bool get isComment => comment != null;
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------
class ServiceTrackingProgressScreen<U extends BaseServiceTicketProvider>
    extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<U> provider;
  final String screenTitle;
  final Widget? headerIcon;

  const ServiceTrackingProgressScreen({
    super.key,
    required this.provider,
    this.screenTitle = 'Ticket Tracking',
    this.headerIcon,
  });

  @override
  ConsumerState<ServiceTrackingProgressScreen<U>> createState() =>
      _ServiceTrackingProgressScreenState<U>();
}

class _ServiceTrackingProgressScreenState<U extends BaseServiceTicketProvider>
    extends ConsumerState<ServiceTrackingProgressScreen<U>> with RouteAware {



  /// Which tasks are expanded inside the Tasks summary card (by task index).
  final Set<int> _expandedTasks = {};
  final commentFormKey = GlobalKey<FormState>();

  @override
  void didPopNext() {
    Future.microtask(() async {
      final provider = ref.read(widget.provider);
      provider.refreshTrackingData();
    });
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build the two-level timeline:
  //
  //   1. Create one bucket per ticket log + one per comment, sort chronologically.
  //   2. Collect every task log across all tasks into a flat list.
  //   3. For each task log, find the ticket-log bucket whose sortKey is the
  //      latest one that is still <= the task log's time, and attach the task
  //      log to it.  Task logs that predate all ticket logs go into bucket[0].
  // ---------------------------------------------------------------------------
  List<_TimelineBucket> _buildTimeline(U provider) {
    // Step 1 — buckets
    final buckets = <_TimelineBucket>[
      ...provider.trackingLogs.map(_TimelineBucket.fromTicketLog),
      ...provider.trackingComments.map(_TimelineBucket.fromComment),
    ];
    buckets.sort((a, b) => a.sortKey.compareTo(b.sortKey));

    if (buckets.isEmpty) return buckets;

    // Step 2 — flat task-log list
    final allTaskLogs = <_TaskLogEntry>[
      for (var i = 0; i < provider.trackingTasks.length; i++)
        ...provider.trackingTasks[i].logs.map((tl) => _TaskLogEntry(tl, provider.trackingTasks[i].slno)),
    ];

    // Only ticket-log buckets are valid attachment points.
    final ticketBuckets = buckets.where((b) => !b.isComment).toList();

    // Step 3 — attach each task log to its nearest preceding ticket bucket
    for (final entry in allTaskLogs) {
      final taskTime = _TimelineBucket._parse(entry.log.statusdate);

      _TimelineBucket? target;
      for (final tb in ticketBuckets) {
        if (tb.sortKey.compareTo(taskTime) <= 0) {
          target = tb;
        } else {
          break;
        }
      }
      // No preceding ticket bucket → use the earliest ticket bucket
      target ??= ticketBuckets.first;
      target.taskLogs.add(entry);
    }

    // Sort task logs within each bucket chronologically
    for (final b in buckets) {
      b.taskLogs.sort((a, b) =>
          _TimelineBucket._parse(a.log.statusdate)
              .compareTo(_TimelineBucket._parse(b.log.statusdate)));
    }

    return buckets;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BaseView<U>(
      provider: widget.provider,
      initState: (context, provider, ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        await provider.refreshTrackingData(extra: extra);
      },
      dispose: (context) {},
      appBar: CustomAppBar(
        title: Text(widget.screenTitle),
        action: [
          Consumer(
            builder: (context, ref, child) {
              final provider = ref.watch(widget.provider);
              return IconButton(
                padding: const EdgeInsets.only(right: 20),
                onPressed: () => provider.refreshTrackingData(),
                icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
              );
            },
          ),
        ],
      ),
      builder: (context, provider, ref) {
        return RefreshIndicator(
          onRefresh: () => provider.refreshTrackingData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTicketDetailsCard(context, provider),
                const SizedBox(height: 8,),
                if (provider.trackingTasks.isNotEmpty) ...[
                  _buildTasksCard(context, provider),
                  const SizedBox(height: 8),
                ],
                _buildTimelineCard(context, provider),
                const SizedBox(height: 8),
                if (provider.trackingLogs.isNotEmpty)
                  _buildParticipantsCard(context, provider.membersList ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: (context, provider, ref) => Visibility(
        visible: !provider.isTrackingClosed,
        child: _buildCommentInput(context, provider, commentFormKey),
      ),
    );
  }

  // ============================================================================
  // TICKET DETAILS CARD
  // ============================================================================

  Widget _buildTicketDetailsCard(BuildContext context, U provider) {
    final summary = provider.trackingSummary;
    if (summary == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16), //  main container padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
              Theme.of(context).primaryColor.withValues(alpha: 0.25),
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
              Theme.of(context).primaryColor.withValues(alpha: 0.15),
              Theme.of(context).primaryColor.withValues(alpha: 0.1)],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          summary.ticketno ?? "",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),


                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(summary.statusCode ?? ''),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summary.status ?? "",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                if (widget.headerIcon != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: widget.headerIcon,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            Divider(
              height: 1,
              thickness: 1,
            ),

            const SizedBox(height: 12),

            // Date Info
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildDateInfo(
            //         context,
            //         icon: Icons.calendar_today_outlined,
            //         label: 'Created',
            //         value: provider.formatDate(
            //           DateTime.parse(summary.ticketdate ?? DateTime.now().toString()),
            //         ),
            //       ),
            //     ),
            //     Container(
            //       width: 1,
            //       height: 32,
            //       color: Colors.blue[200]!.withValues(alpha: 0.5),
            //     ),
            //     Expanded(
            //       child: _buildDateInfo(
            //         context,
            //         icon: Icons.flag_outlined,
            //         label: 'Target Closure',
            //         value: provider.formatDate(
            //           DateTime.parse(summary.targetclosuredate ?? DateTime.now().toString()),
            //         ),
            //         alignment: CrossAxisAlignment.end,
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateInfo(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: provider.formatDate(
                    DateTime.parse(summary.ticketdate ?? DateTime.now().toString()),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Coordinator :",style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 0.5,),),
                    Text(
                      summary.coordinateUser??"",
                      style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Reviewer :",style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 0.5,),),
                    Text(
                      summary.serviceReportUser??"Unassigned",
                      style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status

          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        CrossAxisAlignment alignment = CrossAxisAlignment.start,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.end
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 12, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TASKS SUMMARY CARD
  // ============================================================================

  Widget _buildTasksCard(BuildContext context, U provider) {
    final tasks = provider.trackingTasks;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
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

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.task_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tasks (${tasks.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge?.copyWith(fontSize: 16.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(tasks.length, (i) {
                final task = tasks[i];
                final isExpanded = _expandedTasks.contains(i);
                final taskLabel = 'T${task.slno}';
                final taskDescription = task.description;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() =>
                      isExpanded ? _expandedTasks.remove(i) : _expandedTasks.add(i)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha:  0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade50,
                            width: 0.5
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              padding: EdgeInsets.symmetric(vertical: 6,horizontal: 8),
                              child: Text(taskLabel,style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),),
                            ),
                            const SizedBox(width: 10),
                            // CHANGE to:
                            Expanded(
                              child: _TaskDescriptionWithPopup(
                                description: taskDescription ?? "",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getTaskStatusColor(task.statusCode ?? ''),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(task.status ?? '',
                                  style: TextStyle(
                                      color: _getTaskStatusTextColor(task.statusCode ?? ''),
                                      fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 8),
                      if (task.logs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            'No activity logs for this task.',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            children: List.generate(
                              task.logs.length,
                                  (j) {
                                final reversedLogs = task.logs.reversed.toList();

                                return _buildCompactTaskLogRow(
                                  context,
                                  reversedLogs[j],
                                  isLast: j == reversedLogs.length - 1,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                    if (i < tasks.length - 1) const SizedBox(height: 8),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TIMELINE CARD — two-level: ticket log (L1) → nested task logs (L2)
  // ============================================================================

  Widget _buildTimelineCard(BuildContext context, U provider) {
    final buckets = _buildTimeline(provider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
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

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: buckets.isNotEmpty,
                child: Text(
                  'Timeline',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge?.copyWith(fontSize: 16.5),
                ),
              ),
              const SizedBox(height: 16),
              if (buckets.isEmpty)
                const SizedBox.shrink()
              else
                Column(
                  children: List.generate(
                    buckets.length,
                        (i) => _buildBucket(
                      context,
                      buckets[i],
                      bucketIndex: i,
                      isLast: i == buckets.length - 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top-level bucket renderer ─────────────────────────────────────────────

  Widget _buildBucket(
      BuildContext context,
      _TimelineBucket bucket, {
        required int bucketIndex,
        required bool isLast,
      }) {
    if (bucket.isComment) {
      return _buildCommentBucketItem(
        context,
        bucket.comment!,
        showConnector: !isLast,
      );
    }

    final log = bucket.ticketLog!;
    final statusColor = _getStatusColor(log.statusCode);
    final hasTaskLogs = bucket.taskLogs.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left rail ──────────────────────────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  child: Icon(_getStatusIcon(log.statusCode), size: 20),
                ),
                // if (!isLast)
                //   Container(
                //     width: 2,
                //     height: 40,
                //     color: statusColor.withOpacity(0.3),
                //     margin: const EdgeInsets.only(top: 8),
                //   ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Right content ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // L1: ticket log details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.status,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(DateTime.parse(log.statusdate)),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                      child: Text('By ',
                          style: Theme.of(context).textTheme.labelMedium),
                    ),
                    Text(': ${log.fromUser}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600
                        )),
                  ],
                ),
                if ((log.toUser ).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Text('To ',
                            style: Theme.of(context).textTheme.labelMedium),
                      ),
                      Text(': ${log.toUser}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600
                          )),
                    ],
                  ),
                ],
                if ((log.remarks ).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.remarks,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],

                // ── L2 toggle (only if this bucket has task logs) ──────────
                if (hasTaskLogs) ...[
                  const SizedBox(height: 8),

                  Text(
                    '${bucket.taskLogs.length} task '
                        '${bucket.taskLogs.length == 1 ? 'activity' : 'activities'}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),

                  const SizedBox(height: 12),

                  // ── Nested task-log block ─────────────────────────────
                  Column(
                    children: List.generate(bucket.taskLogs.length, (j) {
                      return _buildNestedTaskLogRow(
                        context,
                        bucket.taskLogs[j],
                        isLast: j == bucket.taskLogs.length - 1,
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── L2: nested task-log row inside the timeline ───────────────────────────

  Widget _buildNestedTaskLogRow(
      BuildContext context,
      _TaskLogEntry entry, {
        required bool isLast,
      }) {
    final tl = entry.log;
    final statusColor = _getTaskStatusColor(tl.statusCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small icon + connector
          Column(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                child: Icon(_getTaskStatusIcon(tl.statusCode),
                    color: _getTaskStatusTextColor(tl.statusCode), size: 15),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: statusColor.withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(top: 4),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Content bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tl.status,
                           style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      // Task #N badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          'T${entry.taskIndex}',
                          style: TextStyle(
                            color: statusColor, fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(DateTime.parse(tl.statusdate)),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Text('By ',
                            style: Theme.of(context).textTheme.labelMedium),
                      ),
                      Text(': ${tl.fromUser}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600
                          )),
                    ],
                  ),
                  if ((tl.toUser ).isNotEmpty) ...[
                  const SizedBox(height: 2),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text('To ',
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        Text(': ${tl.toUser}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600
                            )),
                      ],
                    ),
                  ],
                  //  Text('By : ${tl.fromUser}',
                  //      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  //          fontWeight: FontWeight.bold)),
                  // if ((tl.toUser ?? '').isNotEmpty)
                  //    Text('To : ${tl.toUser}',
                  //        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  //            fontWeight: FontWeight.bold)),
                  if ((tl.remarks ).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tl.remarks,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                             fontSize: 11),
                      ),
                    ),
                  ],
                  if ((tl.workStatusCode  == "NOTINSCOPE"))...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: new4,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tl.workStatusName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Compact task-log row (used inside the Tasks summary card) ─────────────

  Widget _buildCompactTaskLogRow(
      BuildContext context,
      TicketLogModel tl, {
        required bool isLast,
      }) {
    final statusColor = _getTaskStatusColor(tl.statusCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                child: Icon(_getTaskStatusIcon(tl.statusCode),
                    color: _getTaskStatusTextColor(tl.statusCode), size: 16),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: statusColor.withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(top: 4),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tl.status,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 13)),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(DateTime.parse(tl.statusdate)),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                      child: Text('By ',
                          style: Theme.of(context).textTheme.labelMedium),
                    ),
                    Text(': ${tl.fromUser}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600
                        )),
                  ],
                ),
                if ((tl.toUser ).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Text('To ',
                            style: Theme.of(context).textTheme.labelMedium),
                      ),
                      Text(': ${tl.toUser}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600
                          )),
                    ],
                  ),
                ],
                if ((tl.remarks ).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tl.remarks,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 11),
                    ),
                  ),
                ],if ((tl.description ).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tl.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 11),
                    ),
                  ),
                ],
                if ((tl.workStatusCode  == "NOTINSCOPE"))...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: new4,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tl.workStatusName ,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Comment bubble (unchanged) ────────────────────────────────────────────

  Widget _buildCommentBucketItem(
      BuildContext context,
      TicketCommentModel comment, {
        required bool showConnector,
      }) {
    final formattedDate = comment.lastmoddate != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(comment.lastmoddate!))
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.comment, color: Theme.of(context).primaryColor.withValues(alpha: 0.5), size: 20),
              ),
              if (showConnector)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.only(top: 8),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            (comment.user ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue[700], fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.user ?? '',
                                 style: Theme.of(context).textTheme.titleMedium?.copyWith(

                                      fontWeight: FontWeight.bold)),
                             Text('Commented',
                                 style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ),
                      Text(formattedDate,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  if ((comment.comment ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showCommentDialog(context, comment.comment ?? ''),
                      child: Text(
                        comment.comment ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                         style: Theme.of(context).textTheme.labelMedium?.copyWith(
                             height: 1.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.blue[100]!]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comment',
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             color: Colors.black)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100, maxHeight: 400),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Text(text,
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                             height: 1.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PARTICIPANTS CARD
  // ============================================================================

  Widget _buildParticipantsCard(BuildContext context, List<MembersListModel> members) {
    final participants = members;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
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

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Participants (${participants.length})',
                 style: Theme.of(context)
                     .textTheme
                     .titleLarge,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: participants.map((member) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => ProfileImageDialog.show(
                              context: context, imageUrl: "", userName: member.name),
                           child: CachedNetworkImageWidget(
                               imageUrl: member.profileUrl ?? "", size: 32, iconSize: 18, userName: member.name ?? ""),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            member.name ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // COMMENT INPUT
  // ============================================================================

  Widget _buildCommentInput(BuildContext context, U provider, GlobalKey<FormState> formKey ) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 12,
          right: 12,
          top: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Form(
            key: formKey,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // aligns items to top when error text appears
            children: [
              Expanded(
                  child: TextFormField(
                  controller: provider.commentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                     hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                   ),
                    minLines: 1,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please add a comment';
                      }
                      return null;
                    },
                ),
              ),
              const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        provider.sendCommentServiceTicket();
                      }
                    },
                child: const Icon(Icons.send),
              ),
                )
            ],
          ),
        ),
      ),
    ));
  }

// ── Background color (circle fill) ──────────────────────────────────────────

  Color _getStatusColor(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'CLOSED':
      case 'COMPLETED':   return const Color(0xFF10B981);
      case 'IN_PROGRESS': return const Color(0xFFF97316);
      case 'ASSIGNED':    return const Color(0xFF3B82F6);
      case 'PENDING':     return const Color(0xFF6B7280);
      case 'SUBMITTED':   return const Color(0xFFFBBF24);
      case 'REVIEWD':     return const Color(0xFF8B5CF6);
      case 'SEND_BACK':
      case 'REJECTED':    return const Color(0xFFEF4444);
      case 'CANCELLED':   return const Color(0xFF6B7280);
      default:            return const Color(0xFF6B7280);
    }
  }

  Color _getTaskStatusColor(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'ASSIGNMENT_PENDING':
      case 'PENDING':     return const Color(0xFFE2E8F0);
      case 'ASSIGNED':    return const Color(0xFFE0F2FE);
      case 'ACCEPTED':
      case 'IN_PROGRESS': return const Color(0xFFD8FCD8);
      case 'SUBMITTED':   return const Color(0xFFDBEAFE);
      case 'REVIEWD':
      case 'REVIEWED':    return const Color(0xFFEDE9FE);
      case 'SEND_BACK':
      case 'REJECTED':    return const Color(0xFFFEE2E2);
      case 'CLOSED':
      case 'COMPLETED':   return const Color(0xFF1C811C);
      case 'REOPENED':    return const Color(0xFFFAD4FA);
      case 'CANCELLED':   return const Color(0xFFDC2626);
      default:            return bayaInfraGreyColor;
    }
  }

  Color getTaskStatusColor(String statusCode) => _getTaskStatusColor(statusCode);

// ── Text/icon color (use ON TOP of the background circle) ───────────────────

  Color _getStatusTextColor(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'ASSIGNMENT_PENDING':
      case 'PENDING':     return const Color(0xFF475569);
      case 'ASSIGNED':    return const Color(0xFF0369A1);
      case 'ACCEPTED':
      case 'IN_PROGRESS': return const Color(0xFF1C811C);
      case 'SUBMITTED':   return const Color(0xFF1D4ED8);
      case 'REVIEWD':
      case 'REVIEWED':    return const Color(0xFF6D28D9);
      case 'SEND_BACK':
      case 'REJECTED':    return const Color(0xFFDC2626);
      case 'CLOSED':
      case 'COMPLETED':   return Colors.white;
      case 'REOPENED':    return const Color(0xFFC5219C);
      case 'CANCELLED':   return Colors.white;
      default:            return Colors.white;
    }
  }

  Color _getTaskStatusTextColor(String statusCode) => _getStatusTextColor(statusCode);

// ── Icons (unchanged) ────────────────────────────────────────────────────────

  IconData _getStatusIcon(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'CLOSED':
      case 'COMPLETED':   return Icons.task_alt;
      case 'IN_PROGRESS': return Icons.hourglass_bottom;
      case 'ASSIGNED':    return Icons.assignment_ind;
      case 'PENDING':     return Icons.schedule;
      case 'SUBMITTED':   return Icons.upload_file;
      case 'REVIEWD':     return Icons.check_circle;
      case 'SEND_BACK':   return Icons.undo;
      case 'CANCELLED':   return Icons.cancel;
      default:            return Icons.info_outline;
    }

  }

  IconData _getTaskStatusIcon(String statusCode) => _getStatusIcon(statusCode);
}


class _TaskDescriptionWithPopup extends StatefulWidget {
  final String description;
  final TextStyle? style;

  const _TaskDescriptionWithPopup({
    required this.description,
    this.style,
  });

  @override
  State<_TaskDescriptionWithPopup> createState() => _TaskDescriptionWithPopupState();
}

class _TaskDescriptionWithPopupState extends State<_TaskDescriptionWithPopup>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _showPopup(BuildContext context) {
    // Check if text actually overflows before showing popup
    final textPainter = TextPainter(
      text: TextSpan(text: widget.description, style: widget.style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    );

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    textPainter.layout(maxWidth: renderBox.size.width);

    if (!textPainter.didExceedMaxLines) return; // No overflow, skip popup

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TaskDescriptionOverlay(
        description: widget.description,
        style: widget.style,
        anchorOffset: offset,
        anchorSize: size,
        fadeAnim: _fadeAnim,
        scaleAnim: _scaleAnim,
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), _removeOverlay);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _animController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showPopup(context),
      child: Text(
        widget.description,
        style: widget.style,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class _TaskDescriptionOverlay extends StatelessWidget {
  final String description;
  final TextStyle? style;
  final Offset anchorOffset;
  final Size anchorSize;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final VoidCallback onDismiss;

  const _TaskDescriptionOverlay({
    required this.description,
    required this.style,
    required this.anchorOffset,
    required this.anchorSize,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = anchorSize.width.clamp(200.0, screenSize.width - 32.0);

    // Position above or below anchor based on available space
    const popupMaxHeight = 120.0;
    const verticalPadding = 8.0;
    final showAbove = anchorOffset.dy + anchorSize.height + popupMaxHeight + verticalPadding > screenSize.height - 50;

    double topPosition = showAbove
        ? anchorOffset.dy - popupMaxHeight - verticalPadding
        : anchorOffset.dy + anchorSize.height + verticalPadding;

    double leftPosition = anchorOffset.dx.clamp(16.0, screenSize.width - popupWidth - 16.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: Stack(
        children: [
          Positioned(
            top: topPosition,
            left: leftPosition,
            width: popupWidth,
            child: FadeTransition(
              opacity: fadeAnim,
              child: ScaleTransition(
                scale: scaleAnim,
                alignment: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          description,
                          style: style?.copyWith(fontSize: 13),
                          softWrap: true,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Tap to dismiss',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}