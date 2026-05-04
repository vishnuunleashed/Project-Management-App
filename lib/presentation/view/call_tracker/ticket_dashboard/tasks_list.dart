import 'package:base/presentation/base/base_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/ticket_dashboard/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/ticket_dashboard/service_tasks_list_screen.dart';

class ServiceTaskLists extends StatelessWidget {
  const ServiceTaskLists({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ServiceTasksListProvider>(
      provider: serviceTasksListProvider,
      initState: (context,provider,ref){
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        final filter = ref.read(dashboardFilterProvider);
        provider.initValues(extra,filter);

      },
      builder: (context,provider,ref){
        return ServiceTasksListScreen();
      },
    );
  }
}
