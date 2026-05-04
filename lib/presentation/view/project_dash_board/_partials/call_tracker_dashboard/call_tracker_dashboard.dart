import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_dashboard/project_dashboard_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/utils/routes.dart';

class CallTrackCard extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const CallTrackCard({super.key, required this.scaffoldKeyHome});

  @override
  ConsumerState<CallTrackCard> createState() => _CallTrackCardState();
}

class _CallTrackCardState extends ConsumerState<CallTrackCard> {
  late PageController _pageController;
  late ScrollController _dotScrollController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(projectDashboardProvider).callTrackCurrentPage;
    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: _currentPage,
    );
    _dotScrollController = ScrollController();
    if (_currentPage > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dotScrollController.hasClients) {
          _scrollDotIntoView(_currentPage);
        }
      });
    }
  }

  void _scrollDotIntoView(int index) {
    if (!_dotScrollController.hasClients) return;
    const double itemWidth = 43;
    final double targetOffset = index * itemWidth;
    final double viewportWidth = _dotScrollController.position.viewportDimension;
    final double centeredOffset = targetOffset - (viewportWidth / 2) + (itemWidth / 2);

    _dotScrollController.animateTo(
      centeredOffset.clamp(
        0.0,
        _dotScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(projectDashboardProvider);
    final callTrackCount = provider.callTrackCount;
    final isCoordinator = callTrackCount?.isCoordinatorYN == "Y";
    final tickets = callTrackCount?.tickets ?? [];

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          InkWell(
            onTap: (){
              provider.toggleCallTrack();
              _pageController.jumpToPage(0);
              setState(() {
                _currentPage = 0;
              });
              _scrollDotIntoView(0);
              } ,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.track_changes,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Tracker',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Tap to expand',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${callTrackCount?.totalCount ?? 0}",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    provider.isExpandedCallTrack
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable Body ──────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                    height: 0.5, color: Theme.of(context).primaryColor),

                if (tickets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BY CLIENT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        Text(
                          '${_currentPage + 1} / ${tickets.length}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (tickets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _SummaryCountTile(callTrackCount: callTrackCount!),
                  )
                else
                  Column(
                    children: [
                      if ((callTrackCount?.assignmentPendingCount ?? 0) > 0 ||
                          (callTrackCount?.toCloseCount ?? 0) > 0)
                        _SummaryCountTile(callTrackCount: callTrackCount!),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.27,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: tickets.length,
                          onPageChanged: (index) {
                            provider.updateCallTrackPage(index);
                            setState(() => _currentPage = index);
                            _scrollDotIntoView(index);
                          },
                          itemBuilder: (context, index) {
                            return _CallTrackTicketTile(
                              ticket: tickets[index],
                              total: callTrackCount?.totalCount ?? 0,
                            );
                          },
                        ),
                      ),
                      // Page indicator dots
                      if (tickets.length > 1)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Scrollbar(
                                controller: _dotScrollController,
                                trackVisibility: true,
                                thumbVisibility: true,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _dotScrollController, // add this
                                    child: Row(
                                      children: List.generate(
                                        tickets.length,
                                            (index) => GestureDetector(
                                          onTap: () {
                                            _pageController.animateToPage(
                                              index,
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentPage == index
                                                  ? Theme.of(context).primaryColor
                                                  : null,
                                              border: _currentPage != index
                                                  ? Border.all(
                                                  color: Theme.of(context).primaryColor,
                                                  width: 0.5)
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${(tickets[index].submitted??0)
                                                    +(tickets[index].sendBack??0) + (tickets[index].assignPending??0)
                                                    + (tickets[index].rejected??0) + (tickets[index].reopened??0)
                                                    + (tickets[index].accepted??0) + (tickets[index].reviewed ?? 0)
                                                    + (tickets[index].assigned??0)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                    color: _currentPage == index
                                                        ? Colors.white
                                                        : Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.color,
                                                ),        
                                                  ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                    ],
                  ),
              ],
            ),
            crossFadeState: provider.isExpandedCallTrack
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// ── Summary Count Tile (Coordinator OR Engineer with no tickets) ──────────────
class _SummaryCountTile extends StatelessWidget {
  final CallTrackCount callTrackCount;
  const _SummaryCountTile({required this.callTrackCount});

  @override
  Widget build(BuildContext context) {
    final callTrackerProviderInstance =
    ProviderScope.containerOf(context).read(callTrackerProvider);

    // final hasPending = (callTrackCount.assignmentPendingCount ?? 0) > 0;
    // final hasToClose = (callTrackCount.toCloseCount ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if((callTrackCount.assignmentPendingCount ??0) > 0)
          Expanded(
            child: _StatItem(
              onTap: () {

                callTrackerProviderInstance.loadTicketsFromDashboard(
                    callTrackerProviderInstance.statusOptions
                        .firstWhere((item) => item.code == "ASGN_PENDING"));
                DefaultTabController.of(context).animateTo(2);
              },
              label: 'Assignment Pending',
              value: '${callTrackCount.assignmentPendingCount ?? 0}',
              valueColor: bayaInfraAmber,
              bgColor: bayaInfraAmber.withOpacity(0.1),
            ),
          ),
          if((callTrackCount.assignmentPendingCount??0) > 0 && (callTrackCount.toCloseCount ??0) > 0)
          const SizedBox(width: 8),
          if((callTrackCount.toCloseCount??0) > 0)
          Expanded(
            child: _StatItem(
              onTap: () {
                callTrackerProviderInstance.loadTicketsFromDashboard(
                    callTrackerProviderInstance.statusOptions
                        .firstWhere((item) => item.code == "IN_PROGRESS"));
                DefaultTabController.of(context).animateTo(2);
              },
              label: 'To Close',
              value: '${callTrackCount.toCloseCount ?? 0}',
              valueColor: bayaInfraRed,
              bgColor: bayaInfraRed.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
// ── Engineer Ticket Tile (one per page) ───────────────────────────────────────

class _CallTrackTicketTile extends StatelessWidget {
  final CallTrackTicket ticket;
  final int total;

  const _CallTrackTicketTile(
      {required this.ticket, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: InkWell(
                    onTap: (){

                      GoRouter.of(context).pushNamed(
                        AppRoutes.serviceTaskListsFromHome,
                        extra: {
                          "siteName": ticket.siteName,
                          "clientId": ticket.clientId,
                        },
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Ticket Count : ${ticket.totalTaskCount ?? 0}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500
                          ) ,
                        ),
                        Text(
                          ticket.clientName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          ticket.siteName ?? "",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 4),
          // Build the stat grid
          Builder(
            builder: (context) {
              final items = [
                if ((ticket.assignPending ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Pending',
                    value: '${ticket.assignPending ?? 0}',
                    valueColor: const Color(0xFF475569),
                    bgColor: const Color(0xFFE2E8F0),
                    status: 'Assignment pending',
                  ),
                if ((ticket.sendBack ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Rev. Rejected',
                    value: '${ticket.sendBack ?? 0}',
                    valueColor: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEE2E2),
                    status: 'Send Back',
                  ),
                if ((ticket.submitted ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Submitted',
                    value: '${ticket.submitted ?? 0}',
                    valueColor:  const Color(0xFF1D4ED8),
                    bgColor: const Color(0xFFDBEAFE),
                    status: 'Submitted',
                  ),
                if ((ticket.accepted ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Accepted',
                    value: '${ticket.accepted ?? 0}',
                    valueColor: const Color(0xFF1C811C),
                    bgColor: const Color(0xFFD8FCD8),
                    status: 'Accepted',
                  ),
                if ((ticket.assigned ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Assigned',
                    value: '${ticket.assigned ?? 0}',
                    valueColor: const Color(0xFF0369A1),
                    bgColor: const Color(0xFFE0F2FE),
                    status: 'Assigned',
                  ),
                if((ticket.reviewed ?? 0) > 0)
                // if(true)
                  _StatItemData(
                    label: 'Reviewed',
                    value: '${ticket.reviewed ?? 0}',
                    valueColor: const Color(0xFF6D28D9),
                    bgColor: const Color(0xFFEDE9FE),
                    status: 'Reviewed',
                  ),
                if ((ticket.rejected ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'PC. Rejected',
                    value: '${ticket.rejected ?? 0}',
                    valueColor: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEE2E2),
                    status: 'Rejected',
                  ),
                if ((ticket.reopened ?? 0) > 0)
                // if (true)
                  _StatItemData(
                    label: 'Reopened',
                    value: '${ticket.reopened ?? 0}',
                    valueColor: const Color(0xFFC5219C),
                    bgColor: const Color(0xFFFAD4FA),
                    status: 'Reopened',
                  ),
              ];

              final bool onePerRow = items.length <= 3;
              final bool twoPerRow = items.length > 3 && items.length <= 6;
              final int crossCount = onePerRow ? 1 : twoPerRow ? 2 : 3;
              final rows = <Widget>[];

              for (int i = 0; i < items.length; i += crossCount) {
                final rowItems = items.sublist(i, (i + crossCount).clamp(0, items.length));
                final bool isIncompleteRow = rowItems.length < crossCount;

                Widget rowWidget;

                if (isIncompleteRow) {
                  // Center the items without stretching to fill empty slots
                  rowWidget = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 0; j < rowItems.length; j++) ...[
                        if (j > 0) const SizedBox(width: 8),
                        SizedBox(
                          // Match the width a full-row item would have
                          width: (MediaQuery.of(context).size.width - 32 - (8 * (crossCount - 1))) / crossCount,
                          child: _StatItem(
                            onTap: () => GoRouter.of(context).pushNamed(
                              AppRoutes.serviceTaskListsFromHome,
                              extra: {
                                "siteName": ticket.siteName,
                                "clientId": ticket.clientId,
                                "status": rowItems[j].status,
                              },
                            ),
                            label: rowItems[j].label,
                            value: rowItems[j].value,
                            valueColor: rowItems[j].valueColor,
                            bgColor: rowItems[j].bgColor,
                          ),
                        ),
                      ],
                    ],
                  );
                } else {
                  // Full row — use Expanded as normal
                  rowWidget = Row(
                    children: [
                      for (int j = 0; j < rowItems.length; j++) ...[
                        if (j > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _StatItem(
                            onTap: () => GoRouter.of(context).pushNamed(
                              AppRoutes.serviceTaskListsFromHome,
                              extra: {
                                "siteName": ticket.siteName,
                                "clientId": ticket.clientId,
                                "status": rowItems[j].status,
                              },
                            ),
                            label: rowItems[j].label,
                            value: rowItems[j].value,
                            valueColor: rowItems[j].valueColor,
                            bgColor: rowItems[j].bgColor,
                          ),
                        ),
                      ],
                    ],
                  );
                }

                rows.add(rowWidget);
                if (i + crossCount < items.length) rows.add(const SizedBox(height: 8));
              }

              return Column(children: rows);
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared Stat Item ──────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final TextStyle? labelStyle;
  final String value;
  final Color? valueColor;
  final Color? bgColor;
  final void Function()? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.bgColor,
    this.onTap,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isZero = value == '0' || value.isEmpty;

    return GestureDetector(
      onTap: isZero ? null : onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor ?? (valueColor?.withOpacity(0.1) ?? Theme.of(context).primaryColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isZero
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : valueColor,
              ),

            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor
              ),

              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItemData {
  final String label;
  final String value;
  final Color valueColor;
  final Color bgColor;
  final String status;

  const _StatItemData({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bgColor,
    required this.status,
  });
}