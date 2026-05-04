/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class GeneralInfoScreen extends StatelessWidget {
  const GeneralInfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseConsumer(
      provider: projectDetailsProvider,
      builder: (context,provider,ref){
        final provider = ref.watch(projectDetailsProvider);
        final viewSupportDashBoard =
            ref.read(homeProvider.notifier).viewSupportDashBoard;
        final viewObservationDashBoard =
            ref.read(homeProvider.notifier).viewObservationDashBoard;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: BoxBorder.all(color: bayaInfraDisabledColor, width: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: (provider.projectDetailList.isEmpty)
              ? Center()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _headerSection(context: context,viewObservationDashBoard: viewObservationDashBoard,viewSupportDashBoard: viewSupportDashBoard),
              _divider(),
              _detailSection(context: context,provider: provider)

            ],
          ),
        );
      },
    );
  }

  Widget _headerSection(
      {required BuildContext context, required bool viewObservationDashBoard, required bool viewSupportDashBoard}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "General Info",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          // Visibility(visible: viewObservationDashBoard || viewSupportDashBoard,
          //   child: Container(
          //       decoration: BoxDecoration(
          //           color: Theme.of(context).colorScheme.secondary,
          //           borderRadius: BorderRadius.circular(16),
          //           border: BoxBorder.all(
          //               color: bayaInfraDisabledColor, width: 0.5)),
          //       child: IconButton(
          //           onPressed: () {
          //             GoRouter.of(context).go(AppRoutes.dashBoard);
          //           },
          //           icon: Icon(Icons.insert_chart_outlined_outlined,
          //               color: Theme.of(context).colorScheme.primary))),
          // )
        ],
      ),
    );
  }
  Widget _divider(){
    return Divider(
      indent: 0,
      endIndent: 0,
      thickness:0.5,
      color: bayaInfraDisabledColor,
    );

  }

  Widget _detailSection({required BuildContext context, required ProjectDetailsProvider provider}){
    return Flexible(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
          child: Column(
            spacing: 8,
            children: [
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Project name",
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.ad_units,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            provider.projectDetailList.isEmpty?"":provider.projectDetailList.first.projectName?? "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16,fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Client Name",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_outline,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                              '${provider.projectDetailList.first.clientName}',
                              overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16,fontWeight: FontWeight.w500)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start date",
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                            DateFormat('MMM dd, yyyy').format(provider.projectDetailList.first.startDate??DateTime.now()),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16,fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("End date",
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                            DateFormat('MMM dd, yyyy').format(provider.projectDetailList.first.endDate??DateTime.now()),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16,fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
