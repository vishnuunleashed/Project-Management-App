import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_chart_main_provider.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/additional_material_chart_widget.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';

class AdditionMaterialMainScreen extends ConsumerStatefulWidget {
  const AdditionMaterialMainScreen({super.key});

  @override
  ConsumerState<AdditionMaterialMainScreen> createState() => _AdditionMaterialMainScreenState();
}

class _AdditionMaterialMainScreenState extends ConsumerState<AdditionMaterialMainScreen> with RouteAware{

  @override
  void didPopNext()  {
    Future.microtask(() async {
      final provider = ref.watch(additionalMaterialMainProvider);
      provider.fetchAdditionalMaterialChart();
      provider.fetchAllAdditionalMaterialChart();
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
    final provider = ref.watch(additionalMaterialMainProvider);

    return DefaultTabController(
      length: provider.viewAll ? 1 : 2, // Conditionally set tab count
      child: BaseView<AdditionalMaterialMainProvider>(
        initState: (context,provider,ref){
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.setParams(extra: extra);

          DefaultTabController.of(context).animateTo(extra!['selectedOptionIndex']??0);

        },
        provider: additionalMaterialMainProvider,
        appBar: CustomAppBar(
          shadowNeeded: true,
          title: Text("Additional Material"),

        ),

        floatingActionButton: Visibility(
          visible: (ref.watch(additionalMaterialMainProvider).isSuperUser
              || ref.watch(additionalMaterialMainProvider).isProjectDepartment),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 1.5,
              onPressed: (){
                GoRouter.of(context)
                    .pushNamed(AppRoutes.addAdditionalMaterialScreenFromChart, extra: {
                  "projectId": ref.watch(additionalMaterialMainProvider).projectId
                });
              },

              child: Icon(Icons.add,color: Colors.white,),),
          ),
        ),
        builder: (context,provider,ref) {
          final variant = ref.watch(
            settingsProvider.select((s) => s.currentVariant),
          );
          final tabBarController = DefaultTabController.of(context);
          tabBarController.addListener((){
            provider.onPageChanged(tabBarController.index);
          });
          return Column(
            children: [
              TabBar(
                isScrollable: false,
                splashBorderRadius: BorderRadius.circular(12),
                indicator:  provider.viewAll?BoxDecoration(): BoxDecoration(
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                tabAlignment: TabAlignment.fill,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                dividerHeight: 0,
                unselectedLabelColor:
                Theme.of(context).textTheme.labelLarge?.color,
                labelStyle: Theme.of(context).textTheme.labelLarge,
                unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 8),
                tabs: [
                  provider.viewAll
                      ? Text("All Additional Materials",style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.5))
                      : Tab(
                    iconMargin: EdgeInsets.zero,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "All Materials",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  // Only show second tab if viewAll is false
                  if (!provider.viewAll)
                    Tab(
                      iconMargin: EdgeInsets.zero,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          provider.tabName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Force rebuild by using Consumer or watching the provider
                    Consumer(
                      builder: (context, ref, child) {
                        final provider = ref.watch(additionalMaterialMainProvider);

                        if (provider.additionalMaterial.isEmpty) {
                          return EmptyListView(
                              emptyText: "No additional materials requested yet.",

                          );
                        }

                        return AdditionalMaterialCard(
                          list: provider.additionalMaterial,
                          onRefresh: () {
                            provider.fetchAdditionalMaterialChart();
                            provider.fetchAllAdditionalMaterialChart();
                          },
                        );
                      },
                    ),
                    // Only show second tab view if viewAll is false
                    if (!provider.viewAll)
                      Consumer(
                        builder: (context, ref, child) {
                          final provider = ref.watch(additionalMaterialMainProvider.notifier);

                          if (provider.additionalMaterialWithPurchaseOrder.isEmpty) {
                            return EmptyListView(
                                emptyText: "No additional materials with PO.",

                            );
                          }

                          return AdditionalMaterialCard(
                            list: provider.additionalMaterialWithPurchaseOrder,
                            onRefresh: () {
                              provider.fetchAdditionalMaterialChart();
                              provider.fetchAllAdditionalMaterialChart();
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
