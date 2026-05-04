import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/dashboard/partials/dashboard_shared_widgets.dart';
import 'package:interior_design/utils/routes.dart';

class SupportDashboardScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;
  final String? forcedTitle;
  final int? projectId;


  const SupportDashboardScreen({
    super.key,
    this.hideAppBar = false,
    this.forcedTitle,
    this.projectId,

  });

  @override
  ConsumerState<SupportDashboardScreen> createState() => _SupportDashboardScreenState();
}

class _SupportDashboardScreenState extends ConsumerState<SupportDashboardScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, RouteAware {

  @override
  void didPopNext()  {
    Future.microtask(() async {
      var provider = ref.watch(dashBoardProvider);
      provider.fetchDashBoardData();
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseView<DashBoardProvider>(
      appBar: widget.hideAppBar ? null : CustomAppBar(
        title: Text(
          widget.forcedTitle ?? "Support Dashboard",
        ),
      ),
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        final effectiveProjectId = widget.projectId ?? extra?["projectId"] ?? 0;
        provider.initValues(
            effectiveProjectId,false,extra);

        provider.setInitialPage();
      },
      // virtualFloatingActionButton: ExpandableFab(
      //     distance: 70, bottomPadding: 10),
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              DashboardCharts(provider: provider)

            ],
          ),
        );
      },
      provider: dashBoardProvider,
    );
  }
}
