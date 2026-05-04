
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
import 'package:interior_design/presentation/view/close_support_request/pages/close_support_widget.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/support/support_progress_screen.dart';

class CloseSupportRequestScreen extends StatelessWidget {
  const CloseSupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return BaseView<CloseSupportRequestProvider>(
    provider: closeSupportRequestProvider,
    initState: (context,provider,ref) async {

      //To set Support request Id
      final state = GoRouterState.of(context);
      final extra = state.extra as Map<String, dynamic>?;
      provider.setParameter(extra);
      final supportRequestId = extra?['supportRequestId']??extra?["transid"];
      provider.setFromProjectScheduleFlag(extra != null && extra['supportRequestId'] != null);
      provider.getUserForCallTracker();
      provider.fromNotification(extra?["transid"] != null);
      final parsedSupportRequestId = supportRequestId is int
          ? supportRequestId
          : int.tryParse(supportRequestId?.toString() ?? '');

      if (parsedSupportRequestId != null) {
        provider.setSupportRequestId(parsedSupportRequestId);
      }
    

   
      //Init
      provider.initValues();
      provider.getUserDetails();

      if(extra!["notificationid"] != null){
        provider.setNotificationId(extra["notificationid"]);
      }else if(extra["notificationId"] != null){
        provider.setNotificationId(extra["notificationId"]);
      }
    },

      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: closeSupportRequestProvider ,
        builder: (context, provider, ref) {
          return ExpandableFab(
             bottomPadding: 60,
            distance: 70,
          );
        },
      ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

    builder:(context,provider,ref) {
      return PageView(
        physics: AlwaysScrollableScrollPhysics(),
        controller: provider.pageController,
        children: [
          CloseSupportMainWidget(),
          SupportProgressScreen<CloseSupportRequestProvider>(
            provider: closeSupportRequestProvider,
            onBack: (context)async{
              provider.changePage(0);
              return false;
            },
          )

        ],
      );
    },
        );


  }

  void onSaveDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String message,
    required VoidCallback onClick,
  }) {
    showDialogBox(
        context: context,
        title: title,
        titleIcon: icon,
        message: message,
        action: onClick,
        buttonType: DialogButtonType.okOnly);
  }
}


