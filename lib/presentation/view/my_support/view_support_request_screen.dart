
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
import 'package:interior_design/presentation/provider/view_support_request/view_support_request_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/settings.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/presentation/rich_readmore.dart';
import 'package:interior_design/presentation/view/common/support/support_progress_screen.dart';
import 'package:interior_design/presentation/view/my_support/pages/my_support_main.dart';
import 'package:interior_design/utils/routes.dart';

class ViewSupportRequestScreen extends StatelessWidget {
  const ViewSupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ViewSupportRequestProvider>(
      provider: viewSupportRequestProvider,
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
        provider.getUserDetails();
      },
      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: viewSupportRequestProvider,
        builder: (context, provider, ref) {
          final _homeProvider = ref.watch(homeProvider);
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
              MySupportMainWidget(),
              SupportProgressScreen<ViewSupportRequestProvider>(
                provider: viewSupportRequestProvider,
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
