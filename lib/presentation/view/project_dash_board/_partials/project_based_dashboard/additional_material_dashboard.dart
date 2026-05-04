// Additional Material Card
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/utils/routes.dart';

import '_partials/additional_material_tile.dart';

class AdditionalMaterialCard extends ConsumerStatefulWidget {
  final List<MaterialProject> projects;
  final GlobalKey<ScaffoldState> scaffoldKeyHome;
  const AdditionalMaterialCard(
      {super.key, required this.projects, required this.scaffoldKeyHome});

  @override
  ConsumerState<AdditionalMaterialCard> createState() =>
      _AdditionalMaterialCardState();
}

class _AdditionalMaterialCardState
    extends ConsumerState<AdditionalMaterialCard> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(projectDashboardProvider).materialCurrentPage;
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
      color: Theme.of(context).cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // gradient: LinearGradient(
          //   colors: [
          //     Theme.of(context).primaryColor.withValues(alpha: 0.005),
          //     Theme.of(context).primaryColor.withValues(alpha: 0.001),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.projects.isEmpty
                  ? null
                  : () {
                      provider.toggleMaterial();
                      _pageController.jumpToPage(0);
                      setState(() {
                        _currentPage = 0;
                      });
                      _scrollCountIndicatorIntoView(0);
                    },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
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
                        Icons.category,
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
                            'Additional Material',
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
                        "${provider.additionalMaterialCount?.totalCount ?? 0}",
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
                        provider.isExpandedMaterial
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
                  Builder(
                    builder: (context) {
                      final project = widget.projects[_currentPage];
                      final hasMaterials = (project.approvalPending ?? 0) > 0 || (project.poUpdate ?? 0) > 0 || (project.received ?? 0) > 0 || (project.exceededReceived ?? 0) > 0 || (project.sendBackCount ?? 0) > 0;
                      final isExpanded = widget.projects.any((p) => p.isExpandedOpen || p.isExpandedDelayed);
                      double heightFactor = isExpanded ? 0.40 : (hasMaterials ? 0.22 : 0.16);
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: MediaQuery.of(context).size.height * heightFactor,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.projects.length,
                        onPageChanged: (index) {
                          provider.closeExpansionFlag();
                          provider.updateMaterialPage(index);
                          _scrollCountIndicatorIntoView(index);
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return MaterialProjectTile(
                            project: widget.projects[index],
                            toolTipAdd: "Additional Material Indent",
                            onTapPoPending: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "PO_UPDATE",
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 1
                                  });
                            },
                            onPressedAdd: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.addAdditionalMaterialScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId
                                  });
                            },
                            scaffoldKeyHome: widget.scaffoldKeyHome,
                            onTapApprovalPending: () {
                              // PEND_APPROVAL , EXCEED_REC_QTY, PO_UPDATE, RECEIVED_QTY
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "PEND_APPROVAL",
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 1
                                  });
                            },
                            onTapSendBack: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "SEND_BACK",
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 1
                                  });
                            },
                            onTapReceived: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "RECEIVED_QTY",
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 1
                                  });
                            },
                            onTapExceededReceived: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "EXCEED_REC_QTY",
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 1
                                  });
                            },
                            onTapAll: () {
                              GoRouter.of(context).pushNamed(
                                  AppRoutes.additionMaterialMainScreen,
                                  extra: {
                                    "projectId": widget.projects[index].projectId,
                                    "flag": "PEND_APPROVAL",
                                    "viewAll": true,
                                    "teamYn":
                                        provider.scopeFlag == "TEAM" ? "Y" : "N",
                                    "userId": provider.userId,
                                    "selectedOptionIndex": 0
                                  });
                            },

                        );
                      },
                    ),
                  );
                },
              ),
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

                ],
              ),
              crossFadeState: provider.isExpandedMaterial
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
