import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/material_chart_provider.dart';
import 'package:interior_design/presentation/view/material_chart/add_additional_material/add_additional_material.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/additional_material_chart_widget.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';
import 'generalized_tabs.dart';


class MenuItems {
  int index;
  String menuName;
  MenuItems({
    required this.index,
    required this.menuName,
  });
}

// Main Screen
class MaterialChartScreen extends ConsumerWidget {
  const MaterialChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseView<MaterialChartProvider>(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.setParameter(extra);
      },
      provider: materialChartProvider,
      appBar: CustomAppBar(
        shadowNeeded: true,
        title: const Text(
          'Material Chart',
        ),

      ),
      builder: (context, provider, ref) => MaterialDetailScreen(),
    );
  }
}

class MaterialDetailScreen extends ConsumerStatefulWidget {
  const MaterialDetailScreen({super.key});

  @override
  ConsumerState<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen> with RouteAware{
  @override
  void didPopNext()  {
    Future.microtask(() async {
      final provider = ref.watch(materialChartProvider);



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
    final provider = ref.watch(materialChartProvider);
    return DefaultTabController(
      length: 4,
      child: Builder(
          builder: (BuildContext context) {
            final variant = ref.watch(
              settingsProvider.select((s) => s.currentVariant),
            );
            final TabController tabController = DefaultTabController.of(context);
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                ref.read(materialChartProvider).setSelectedTabIndex(tabController.index);
              }
            });

            return  provider.materialItem.isEmpty
                ? provider.loadingStatus.loader == Loader.loading
                ? SizedBox(height: 0)
                : EmptyListView(
                emptyText: "No material chart uploaded for this project yet.",
            )
                : Scaffold(
              body: Column(
                children: [
                  Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor:
                      Theme.of(context).textTheme.labelLarge?.color,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .labelLarge,
                      unselectedLabelStyle: Theme.of(context)
                          .textTheme
                          .labelLarge,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      tabs: [
                        ...provider.menuCategory.map((category) {
                          return Tab(text: category.menuName);
                        }).toList(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Initial Materials
                        const MaterialItemCard(
                          materialType: MaterialChartType.initial,
                        ),
                        // Special Materials
                        const MaterialItemCard(
                          materialType: MaterialChartType.special,
                        ),
                        // Standard Materials
                        const MaterialItemCard(
                          materialType: MaterialChartType.standard,
                        ),
                        // Additional Materials

                      ],
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}