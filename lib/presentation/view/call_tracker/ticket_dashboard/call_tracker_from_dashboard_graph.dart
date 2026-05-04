import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/call_tracker_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/call_tracker_page.dart';

class ServiceTrackerBaseHolder extends ConsumerWidget {
  const ServiceTrackerBaseHolder({super.key});

  @override
  Widget build(BuildContext context,ref) {
    return BaseView<CallTrackerProvider>(

      initState: (context,provider,ref){
        //  Pass filterProvider FIRST before getParameter
        final filter = ref.read(dashboardFilterProvider);
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;

        provider.getParameter(extra, filter);
      },
       appBar: CustomAppBar(
         title: Row(
           children: [
             Text("Service Task Status ",),
             Text((ref.watch(callTrackerProvider).statusFromGraph.isNotEmpty) ? ("(${(ref.watch(callTrackerProvider).statusFromGraph == "TARGET_ISSUE") ? "ASSIGN MISSING" :ref.watch(callTrackerProvider).statusFromGraph})") : "",
              style: Theme.of(context).textTheme.labelLarge,
             ),
           ],
         )
       ) ,
      provider: callTrackerProvider,
      builder: (context,provider,ref) {
        return CallTrackerPage(isFromDashboard: true);
      }
    );
  }
}
