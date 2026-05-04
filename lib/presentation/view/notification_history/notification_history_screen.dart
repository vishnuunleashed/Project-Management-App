import 'dart:async';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/notification_history/notification_history_provider.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/routes.dart';

/// ─── Main Screen ───────────────────────────────────

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen>
    with RouteAware {


  @override
  void didPopNext()  {
    Future.microtask(() async {
      ref.read(notificationHistoryProvider).refreshReadStatuses();
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

  @override
  Widget build(BuildContext context) {
    return BaseView<NotificationHistoryProvider>(
      initState: (context, provider, _){
        provider.initValues();

        onMessageNotificationList(onListenerInvoke: (){
          provider.initValues();
        });
      },
      provider: notificationHistoryProvider,
      appBar: const CustomAppBar(
        title: Text("Notification History"),
        shadowNeeded: true,
      ),
      dispose: (context){
        if(notificationList != null){
          notificationList?.cancel();
        }

      },
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).highlightColor,
          onRefresh: ()async{
            provider.fetchNotificationHistoryList(start: 0);
          },
          child: _NotificationListView(
            notifications: provider.notificationList,
          ),
        );
      },
    );
  }
}

/// ─── List View ─────────────────────────────────────

class _NotificationListView extends ConsumerWidget {
  final List<NotificationList> notifications;

  const _NotificationListView({
    required this.notifications,
  });

  Map<String, List<NotificationList>> _groupByDate(
      List<NotificationList> items) {

    // Sort newest first
    final sorted = List<NotificationList>.from(items)
      ..sort((a, b) => (b.createdDate ?? "").compareTo((a.createdDate ?? "")));

    final Map<String, List<NotificationList>> grouped = {};

    for (final item in sorted) {
      final label = _dateLabel(DateTime.parse(item.createdDate ?? ""));
      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  static String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) {
      return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dt.weekday - 1];
    }

    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(notificationHistoryProvider);
    final grouped = _groupByDate(notifications);

    return CustomScrollView(
      controller: provider.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        ...grouped.entries.map((entry) {
          return SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: _DateDivider(label: entry.key),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                      _NotificationTile(item: entry.value[index]),
                  childCount: entry.value.length,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// ─── Date Divider ──────────────────────────────────

class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
            ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return false;
  }
}

/// ─── Notification Tile (No Animation) ─────────────

class _NotificationTile extends ConsumerWidget {
  final NotificationList item;

  const _NotificationTile({
    required this.item,
  });


  IconData get _typeIcon {
    switch (item.viewOptionCode) {
      case "ADD_OBSERVATION":
        return Icons.content_paste_search;
      case "ADD_SUPPORT_REQUEST":
        return Icons.support_agent_outlined;
      case "SCHEDULE":
        return Icons.calendar_today_outlined;
      case "TEMP_LOCATION":
        return Icons.location_on_outlined;
      case "ADDT_MAT_CHART":
        return Icons.category;
      case "CALL_TRACKER":
        return Icons.track_changes;
      default:
        return Icons.track_changes;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark =  SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final accent = Color(0xFF0298DB);

    return InkWell(
      onTap: () {
        if(item.viewOptionCode == "SCHEDULE"){
          ref.read(notificationHistoryProvider).updateReadStatus( notificationId: item.notificationId);
        }

        final routes = item.orderedRoutes;
        if (routes.isNotEmpty && routes[0].isNotEmpty) {
          GoRouter.of(context).pushNamed(
            routes[0],
            extra: item.toMap(),
          );
        }

        if (routes.length > 1 && routes[1].isNotEmpty) {
          GoRouter.of(context).pushNamed(
            routes[1],
            extra: item.toMap(),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2,horizontal: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_typeIcon, color: accent, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? "",
                            textAlign: TextAlign.left,
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.message ?? "",
                            textAlign: TextAlign.left,
                            style: textTheme.labelMedium?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -14,
                      child: ReadStatusBadge(
                        isRead: item.readStatusYN == "Y",
                        accent: accent,
                        isDark: isDark,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadStatusBadge extends StatelessWidget {
  final bool isRead;
  final Color accent;
  final bool isDark;

  const ReadStatusBadge({
    super.key,

    required this.isRead,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {

    if (isRead) {
      print("entered___");
      return Chip(
          color: WidgetStateProperty.resolveWith<Color?>((states) {
            return bayaInfraLightRedColor.withValues(alpha: 0.2);
          }),
          padding: EdgeInsets.zero,
          label: Text("Read"));
    }
    return Chip(
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          return bayaInfraPaleGreen.withValues(alpha: 0.2);
        }),
        padding: EdgeInsets.zero,
        label: Text("Unread"));

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       gradient: LinearGradient(
  //         colors: [
  //           accent.withOpacity(isDark ? 0.30 : 0.18),
  //           accent.withOpacity(isDark ? 0.15 : 0.08),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       border: Border.all(
  //         color: accent.withValues(alpha: 0.2),
  //         width: 0.9,
  //       ),
  //
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Pulsing dot
  //       Container(
  //       width: 7,
  //       height: 7,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: accent.withValues(alpha: 0.7),
  //       ),
  //     ),
  //         const SizedBox(width: 5),
  //         Text(
  //           "Unread",
  //           style: TextStyle(
  //             fontSize: 10,
  //             letterSpacing: 0.5,
  //             color: accent,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  }
}


