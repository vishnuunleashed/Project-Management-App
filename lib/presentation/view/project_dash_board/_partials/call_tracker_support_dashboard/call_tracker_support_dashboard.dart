
// Call Track Support Card
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/utils/routes.dart';

import '../call_tracker_dashboard/_partials/call_tracker_tile.dart';

class CallTrackSupportCard extends ConsumerStatefulWidget {
  final List<CallTrackSupportTicket> tickets;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const CallTrackSupportCard(
      {super.key, required this.tickets, required this.scaffoldKeyHome});

  @override
  ConsumerState<CallTrackSupportCard> createState() =>
      _CallTrackSupportCardState();
}

class _CallTrackSupportCardState extends ConsumerState<CallTrackSupportCard> {
  late PageController _pageController;
  late ScrollController _countScrollController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage =
        ref.read(projectDashboardProvider).callTrackSupportCurrentPage;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );
    _countScrollController = ScrollController();
    if (_currentPage > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_countScrollController.hasClients) {
          _scrollCountIndicatorIntoView(_currentPage);
        }
      });
    }
  }

  void _scrollCountIndicatorIntoView(int index) {
    if (!_countScrollController.hasClients) return;
    const double itemWidth = 43;
    final double targetOffset = index * itemWidth;
    final double viewportWidth =
        _countScrollController.position.viewportDimension;
    final double centeredOffset =
        targetOffset - (viewportWidth / 2) + (itemWidth / 2);

    _countScrollController.animateTo(
      centeredOffset.clamp(
          0.0, _countScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(projectDashboardProvider);
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: widget.tickets.isEmpty
                ? null
                : () {
              provider.toggleCallTrackSupport();
              _pageController.jumpToPage(0);
              setState(() {
                _currentPage = 0;
              });
              _scrollCountIndicatorIntoView(0);
            },
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
                      Icons.support_agent,
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
                          'Service Support Requests',
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
                      "${provider.callTrackSupportCount?.totalCount ?? "0"}",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Visibility(
                    visible: widget.tickets.isNotEmpty,
                    child: Icon(
                      provider.isExpandedCallTrackSupport
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                if (widget.tickets.isNotEmpty)
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
                          '${_currentPage + 1} / ${widget.tickets.length}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (widget.tickets.isEmpty)
                  const SizedBox(height: 0)
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    height: widget.tickets.any((item){return item.isExpandedOpen == true ||item.isExpandedDelayed == true;})
                        ? MediaQuery.of(context).size.height * 0.32
                        : MediaQuery.of(context).size.height * 0.21,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.tickets.length,
                      onPageChanged: (index) {
                        provider.updateCallTrackSupportPage(index);
                        _scrollCountIndicatorIntoView(index);
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final callTrackerProviderInstance =
                        ProviderScope.containerOf(context).read(callTrackerProvider);
                        return CallTrackSupportTile(
                          index:index,
                          ticket: widget.tickets[index],
                          scaffoldKeyHome: widget.scaffoldKeyHome,
                          onAllTap: (){
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.serviceSupportRequestSiteWiseScreen, extra: {
                              "flagSupport":"ALL_SUPPORT",
                              "status": "DELAYED",
                              "siteName":  widget.tickets[index].siteName,
                              "clientId":  widget.tickets[index].clientid,
                            });
                          },
                          onTapClientName: (){
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.serviceSupportRequestSiteWiseScreen, extra: {
                              "siteName":  widget.tickets[index].siteName,
                              "clientId":  widget.tickets[index].clientid,
                              "status": "DELAYED",
                            });
                          },
                          onAllOpenTap: (){
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.serviceSupportRequestSiteWiseScreen, extra: {
                              "scopeFlag": provider.scopeFlag,
                              "delayedYNSupport": "N",
                              "userId": provider.userId,
                              "flagSupport":  provider.categoryFlag.name,
                              "status": "OPEN",
                              "subStatus": "ALL",
                              "siteName":   widget.tickets[index].siteName,
                              "clientId":  widget.tickets[index].clientid,
                            });
                          },
                          onAllDelayedTap: (){
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.serviceSupportRequestSiteWiseScreen, extra: {
                              "scopeFlag": provider.scopeFlag,
                              "delayedYNSupport": "Y",
                              "userId": provider.userId,
                              "flagSupport":  provider.categoryFlag.name,
                              "status": "DELAYED",
                              "subStatus": "ALL",
                              "siteName":   widget.tickets[index].siteName,
                              "clientId":  widget.tickets[index].clientid,

                            });
                          },
                          onSubCountTap: (status,subStatus, isDelayed,ticket){
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.serviceSupportRequestSiteWiseScreen, extra: {
                              "delayedYNSupport": isDelayed?"Y":"N",
                              "userId": provider.userId,
                              "scopeFlag": provider.scopeFlag,
                              "flagSupport": provider.categoryFlag.name,
                              "status": status,
                              "subStatus": subStatus,
                              "siteName":  ticket.siteName,
                              "clientId":  widget.tickets[index].clientid,
                            });
                          },
                        );
                      },
                    ),
                  ),
                if (widget.tickets.length > 1)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: Scrollbar(
                        controller: _countScrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _countScrollController,
                          shrinkWrap: true,
                          itemCount: widget.tickets.length,
                          itemBuilder: (context, index) => GestureDetector(
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
                                        width: 0.5,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.tickets[index].subtotal}',
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
                const SizedBox(height: 4),

              ],
            ),
            crossFadeState: provider.isExpandedCallTrackSupport
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
