
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_support_request/view_service_support_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/service_based_support_from_home/pages/service_support_site_wise_widget.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/support/support_progress_screen.dart';

class ViewServiceSupportRequestScreen extends StatelessWidget {
  const ViewServiceSupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ViewServiceSupportRequestProvider>(
      provider: viewServiceSupportRequestProvider,
      initState: (context, provider, ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        final supportRequestId = extra?['supportRequestId'] ??
            extra?["transid"];
        final status = extra?['status'];
        provider.setStatus(status: status);
        provider.fromNotification(extra?["transid"] != null);
        final parsedSupportRequestId = supportRequestId is int
            ? supportRequestId
            : int.tryParse(supportRequestId?.toString() ?? '');

        if (parsedSupportRequestId != null) {
          provider.setSupportRequestId(parsedSupportRequestId);
        }

      




        provider.initValues();
        provider.getUserForCallTracker();
        provider.getUserDetails();
      },
      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: viewSupportRequestProvider,
        builder: (context, provider, ref) {
          return ExpandableFab(
            bottomPadding: 60,
            distance: 70,

          );
        },
      ),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,

      builder: (context, provider, ref) {
        return GestureDetector(
          onHorizontalDragEnd: provider.onHorizontalDrag,
          child: PageView(
            controller: provider.pageController,
            children: [
              ServiceSupportMainWidget(),
              SupportProgressScreen<ViewServiceSupportRequestProvider>(
                provider: viewServiceSupportRequestProvider,
                onBack: (context)async{
                  provider.changePage(0);
                  return false;
                },
              )
            ],
          ),
        );
      },
    );
  }
}
