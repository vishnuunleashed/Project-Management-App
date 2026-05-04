
import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/side_bar_provider.dart';
import 'package:interior_design/utils/routes.dart';

class EdgeSwipeMenu extends ConsumerStatefulWidget {
  const EdgeSwipeMenu({super.key});

  @override
  ConsumerState<EdgeSwipeMenu> createState() => _EdgeSwipeMenuState();
}

class _EdgeSwipeMenuState extends ConsumerState<EdgeSwipeMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final _homeProvider = ref.watch(homeProvider.notifier);
    final _sideBarProvider = ref.watch(sideBarProvider.notifier);
    List<MenuItem> menuItems = [

      // if(_homeProvider.addObservationRight)
      MenuItem(
          icon: Icons.content_paste_search,
          title: 'Add observation',
          color: Colors.lightBlueAccent),
      // if(_homeProvider.addSupportRight)
      MenuItem(
          icon: Icons.support_agent,
          title: 'Add Support',
          color: Colors.green),
      // if(_homeProvider.isSuperUser
      //     || _homeProvider.projectListWithFilter[_sideBarProvider.projectIndex]
      //     .projectscheduleyn)
      //   MenuItem(
      //     icon: Icons.calendar_today_outlined,
      //     title: 'View Schedule',
      //     color: Colors.orange),
      // MenuItem(
      //     icon: Icons.dashboard,
      //     title: 'Project Details',
      //     color: Colors.purple),
      // if(_homeProvider.isSuperUser
      //     || _homeProvider.projectListWithFilter[_sideBarProvider.projectIndex]
      //         .materialchartyn)

      // MenuItem(
      //     icon: Icons.table_chart,
      //     title: 'Material chart',
      //     color: Colors.lightBlue),

      if(/*_homeProvider.addAdditionalMaterial &&*/ _homeProvider.isSuperUser || _homeProvider.isProjectDepartment)
      MenuItem(
          icon: Icons.add_chart,
          title: "Addn'l Material Indent",
          color: Colors.teal),
      if(!_homeProvider.isProcurementDepartment)
      MenuItem(
          icon: Icons.category_rounded,
          title: 'Material Chart',
          color: Colors.cyan),
    ];

    // Calculate height based on content
    final itemHeight = 120.0; // Height per item
    final titleHeight = 60.0;
    final padding = 16.0;

    final dynamicHeight = (menuItems.length * itemHeight) + titleHeight + padding;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    final finalHeight = dynamicHeight < maxHeight ? dynamicHeight : maxHeight;

    return SizedBox(
      height: finalHeight,
      child: Drawer(
        width: MediaQuery.of(context).size.width/3,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: BaseConsumer<SideBarProvider>(
          provider: sideBarProvider,
          builder: (context,provider,ref) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      provider.drawerTitle,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: null,
                          fontSize: 17
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 1,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return MenuIconTile(
                          icon: item.icon,
                          title: item.title,
                          color: item.color,
                          onTap: () {
                            if(item.title == "Add observation"){


                              GoRouter.of(context)
                                  .pushNamed(AppRoutes.addObservation, extra: {"projectId": provider.projectId});
                            }else if(item.title == "Add Support"){
                              //support
                              _homeProvider.searchFocusNode.unfocus();

                              GoRouter.of(context).pushNamed(
                                  AppRoutes.addSupportRequest,extra: {"projectId":provider.projectId});
                            }/*else if(item.title == "View Schedule"){
                              //view schedule

                              GoRouter.of(context).go(AppRoutes.projectSchedule,
                                  extra: {"projectId": _homeProvider.projectListWithFilter[provider.projectIndex]
                                      .projectId ??
                                      0});
                            }else if(item.title == "Project Details"){
                              //project details


                              if(( (!_homeProvider.addObservationRight &&
                                  !_homeProvider.addSupportRight &&
                                  !_homeProvider.closeObservationRight &&
                                  !_homeProvider.closeSupportRight) ||
                                  _homeProvider.expandedIndex == provider.projectIndex)){
                                ref.watch(homeProvider.notifier).searchFocusNode.unfocus();
                                GoRouter.of(context).go(AppRoutes.projectDetails,
                                    extra: {"projectId":_homeProvider.projectListWithFilter[provider.projectIndex]
                                        .projectId ??
                                        0}
                                );
                                }

                            }else if(item.title == 'Material chart'){
                              GoRouter.of(context)
                                  .pushNamed(AppRoutes.materialChartScreen, extra: {
                                    "projectId": _homeProvider.projectListWithFilter[provider.projectIndex].projectId
                              });
                            }*/else if(item.title == "Addn'l Material Indent"){
                              GoRouter.of(context)
                                  .pushNamed(AppRoutes.addAdditionalMaterialScreen, extra: {
                                "projectId": provider.projectId
                              });
                            }else if(item.title == "Material Chart"){
                              GoRouter.of(context)
                                  .pushNamed(AppRoutes.additionMaterialMainScreen, extra: {
                                "projectId": provider.projectId,
                                "viewAll":true,
                                "selectedOptionIndex":0
                              });
                            }
                            Navigator.pop(context);

                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final Color color;

  MenuItem({required this.icon, required this.title, required this.color});
}

class MenuIconTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const MenuIconTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Card(
                  color: Theme.of(context).colorScheme.onTertiary,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: null,
                  fontSize: 12
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}