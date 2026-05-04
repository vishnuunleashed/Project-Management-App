// Observations Card
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/side_bar_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/project_dash_board/project_dash_board.dart';
import 'package:interior_design/utils/routes.dart';

import '_partials/_project_sub_dashboard.dart';
import '_partials/_project_tile.dart';

class ObservationsCard extends ConsumerStatefulWidget {
  final List<Project> projects;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;

  const ObservationsCard({
    super.key,
    required this.projects,
    required this.scaffoldKeyHome,
  });

  @override
  ConsumerState<ObservationsCard> createState() => _ObservationsCardState();
}

class _ObservationsCardState extends ConsumerState<ObservationsCard> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(projectDashboardProvider).obsCurrentPage;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );
    if (_currentPage > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_countScrollController.hasClients) {
          _scrollCountIndicatorIntoView(_currentPage);
        }
      });
    }
  }

  void _scrollCountIndicatorIntoView(int index) {
    const double itemWidth = 43; // 35 width + 4+4 margin
    final double targetOffset = index * itemWidth;
    if (!_countScrollController.hasClients) return;
    final double viewportWidth = _countScrollController.position.viewportDimension;
    final double centeredOffset = targetOffset - (viewportWidth / 2) + (itemWidth / 2);

    _countScrollController.animateTo(
      centeredOffset.clamp(
        0.0,
        _countScrollController.position.maxScrollExtent,
      ),
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
  final ScrollController _countScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(projectDashboardProvider);
    return Card(
      elevation: 1,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: widget.projects.isEmpty
                ? null
                : () {
                    provider.toggleObs();
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
                      Icons.content_paste_search,
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
                          'Observations',
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
                      "${provider.observationCount?.totalCount ?? "0"}",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Visibility(
                    visible: widget.projects.isNotEmpty,
                    child: Icon(
                      provider.isExpandedObs
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
                Divider(height: 0.5, color: Theme.of(context).primaryColor),
                if (widget.projects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BY PROJECT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        Text(
                          '${_currentPage + 1} / ${widget.projects.length}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (widget.projects.isEmpty)
                  const SizedBox(height: 0)
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: widget.projects.any((p) => p.isExpandedOpen || p.isExpandedDelayed)
                        ? MediaQuery.of(context).size.height * 0.36
                        : MediaQuery.of(context).size.height * 0.21,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.projects.length,

                      onPageChanged: (index) {
                        provider.closeExpansionFlag();
                        provider.updateObsPage(index);
                        _scrollCountIndicatorIntoView(index);
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ProjectTile(
                          toolTipAdd: "Add Observations",
                          toolTipAll: "All Observation",
                          onLongPress: () {
                            final _sideBarProvider = ref.watch(sideBarProvider);
                            _sideBarProvider.setParameter(
                              DrawerParams(
                                  projectName: widget.projects[index].name,
                                  projectId: widget.projects[index].id),
                            );
                            widget.scaffoldKeyHome.currentState
                                ?.openEndDrawer();
                          },
                          index: index,
                          onPressedAdd: () {
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.addObservation, extra: {
                              "projectId": widget.projects[index].id
                            });
                          },
                          onAllTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.assignedObsScreen, extra: {
                              "projectId": widget.projects[index].id,
                              "isFromObservation": true,
                              "scopeFlag": provider.scopeFlag,
                              "flagObs": "ALL_OBSERVATION",
                              "subStatus":"PENDING",
                              "userId": provider.userId
                            });
                          },
                          onDelayedTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.assignedObsScreen, extra: {
                              "projectId": widget.projects[index].id,
                              "isFromObservation": true,
                              "DelayedYN": "Y",
                              "scopeFlag": provider.scopeFlag,
                              "flagObs": provider.categoryFlag.name,
                              "userId": provider.userId
                            });
                          },
                          onOpenTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.assignedObsScreen, extra: {
                              "projectId": widget.projects[index].id,
                              "isFromObservation": true,
                              "DelayedYN": "N",
                              "scopeFlag": provider.scopeFlag,
                              "flagObs": provider.categoryFlag.name,
                              "userId": provider.userId
                            });
                          },
                          onSubCountTap: (statusTitle, isDelayed) {
                            GoRouter.of(context)
                                .pushNamed(AppRoutes.assignedObsScreen, extra: {
                              "projectId": widget.projects[index].id,
                              "isFromObservation": true,
                              "DelayedYN": isDelayed ? "Y" : "N",
                              "scopeFlag": provider.scopeFlag,
                              "flagObs": provider.categoryFlag.name,
                              "subStatus":
                                  statusTitle,
                              "userId": provider.userId
                            });
                          },
                          project: widget.projects[index],
                        );
                      },
                    ),
                  ),
                if (widget.projects.length > 1)
                  if (widget.projects.length > 1)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width/2,
                      child: Center(
                        child: Scrollbar(
                          controller: _countScrollController,
                          thumbVisibility: true,

                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _countScrollController,
                            shrinkWrap: true,
                            itemCount:  widget.projects.length,
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
                                    '${widget.projects[index].subtotal}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Theme.of(context).textTheme.labelLarge?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: 4,)

              ],
            ),
            crossFadeState: provider.isExpandedObs
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
