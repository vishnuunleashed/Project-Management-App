import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/project_dash_board/project_dash_board.dart';
import 'package:interior_design/utils/routes.dart';
import '_schedule_project_tile.dart';
import '_schedule_sub_dashboard.dart';

class ScheduleCard extends ConsumerStatefulWidget {
  final List<ScheduleProject> projects;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const ScheduleCard(
      {super.key, required this.projects, required this.scaffoldKeyHome});

  @override
  ConsumerState<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends ConsumerState<ScheduleCard> {
  late PageController _pageController;
  late ScrollController _countScrollController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(projectDashboardProvider).scheduleCurrentPage;
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
      centeredOffset.clamp(0.0, _countScrollController.position.maxScrollExtent),
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
            onTap: widget.projects.isEmpty
                ? null
                : () {
              provider.toggleSchedule();
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
                      Icons.calendar_today_outlined,
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
                          'Scheduled Project Tasks',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${provider.scheduleTaskCount?.totalCount ?? "0"}",
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
                      provider.isExpandedSchedule
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
                          'BY TASKS',
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
                  Builder(
                    builder: (context) {
                      final project = widget.projects[_currentPage];

                      double heightFactor =  0.25;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: MediaQuery.of(context).size.height * heightFactor,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.projects.length,
                      onPageChanged: (index) {
                        provider.updateSchedulePage(index);
                        _scrollCountIndicatorIntoView(index);
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ScheduleProjectTile(
                          project: widget.projects[index],
                          scaffoldKeyHome: widget.scaffoldKeyHome,
                          onTapDelayedTasks: () {
                            GoRouter.of(context)
                                .go(AppRoutes.projectSchedule, extra: {
                              "projectId": widget.projects[index].projectId,
                              "status": "DELAYED",
                              "userId": provider.userId,
                              "scopeFlag": provider.scopeFlag,
                              "isReporteeUser": provider.selectedUser != null && provider.selectedUser?.userName != provider.loggedInUserName ,
                              "reporteesTasksFlag":true

                            });
                          },
                          onTapTotalPending: () {

                            GoRouter.of(context)
                                .go(AppRoutes.projectSchedule, extra: {
                              "projectId": widget.projects[index].projectId,
                              "status": "PENDING",
                              "userId": provider.userId,
                              "scopeFlag": provider.scopeFlag,
                              "isReporteeUser": provider.selectedUser != null && provider.selectedUser?.userName != provider.loggedInUserName ,
                              "reporteesTasksFlag":true

                            });
                          },
                          onTapTrackTasks: () {
                            GoRouter.of(context)
                                .go(AppRoutes.projectSchedule, extra: {
                              "projectId": widget.projects[index].projectId,
                              "status": "ON_TRACK",
                              "userId": provider.userId,
                              "scopeFlag": provider.scopeFlag,
                              "isReporteeUser": provider.selectedUser != null && provider.selectedUser?.userName != provider.loggedInUserName ,
                              "reporteesTasksFlag":true

                                });
                          },
                          onTapAllTasks: () {
                            GoRouter.of(context).pushNamed(
                                "projectScheduleAllTaskDirect",
                                extra: {
                                  "projectId": widget.projects[index].projectId,
                                  "status": "None",
                                  "userId": provider.userId
                                });
                          },
                        );
                      },
                    ),
                  );
                },
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
                            itemBuilder: (context, index) {
                              final totalActiveTask = widget.projects[index].totalTasksOpen + widget.projects[index].delayedTasks;
                              return GestureDetector(
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
                                    '$totalActiveTask',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Theme.of(context).textTheme.labelLarge?.color,
                                    ),
                                  ),
                                ),
                              ),
                            );
                            },
                          ),
                        ),
                      ),
                    ),

              ],
            ),
            crossFadeState: provider.isExpandedSchedule
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
