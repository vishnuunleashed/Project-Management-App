import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/project_details/graph_lists.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

import 'my_obs_and_support_menu.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconTheme = Theme.of(context).iconTheme;



    return BaseConsumer<ProjectDetailsProvider>(
      provider: projectDetailsProvider,
        builder: (context, provider, ref) {
          int totalDays = provider.projectTotalDays;
          double remainingDays = 20; // Days left
          double completedDays = totalDays - remainingDays;



          return RefreshIndicator(
            color:Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).highlightColor,



            onRefresh: ()async{
              provider.fetchProjectDetails(projectId: provider.projectId);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child:
              (provider.projectDetailList.isEmpty)
                  ? Center() :
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Client Info Card
                  projectDetailCard(context,provider),
                  GraphLists(),
                  MyObsAndSupport(),

                  // Observation Section
                  Card(
                    elevation: 0.5,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Observations", style: textTheme.titleMedium?.copyWith(fontSize: 18)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                    context, "Opened", (provider.projectDetailList.first.openObsCount != null)  ? provider.projectDetailList.first.openObsCount.toString() : "0",
                                    Icons.folder_open,
                                    bayaInfraAmber,
                                    onTap: (){
                                      GoRouter.of(context).pushNamed(AppRoutes.allObservationListScreen,
                                          extra:
                                            {
                                              'bottomBarStatus' : AllObservationAndSupportStatus.opened,
                                              'projectId' : provider.projectId,
                                              'userId' : null,
                                              'raisedUser' : ""
                                            },
                                      );
                                    }
                                ),
                              ),

                              Expanded(
                                child: _buildStatCard(
                                    context, "Delayed",(provider.projectDetailList.first.delayObsCount != null)  ? provider.projectDetailList.first.delayObsCount.toString() : "0",
                                    Icons.access_time,
                                    bayaInfraRed,
                                    onTap: (){
                                      GoRouter.of(context).pushNamed(AppRoutes.allObservationListScreen,
                                          extra:
                                          {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.delayed,
                                            'projectId' : provider.projectId,
                                            'userId' : null,
                                            'raisedUser' : ""
                                          },
                                      );
                                    }
                                ),
                              ),

                              Expanded(
                                child: _buildStatCard(
                                    context, "Closed",(provider.projectDetailList.first.closeObsCount != null)  ? provider.projectDetailList.first.closeObsCount.toString() : "0",
                                    Icons.check_circle,
                                    bayaInfraPaleGreen,
                                    onTap: (){
                                      GoRouter.of(context).pushNamed(AppRoutes.allObservationListScreen,
                                          extra:
                                          {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.closed,
                                            'projectId' : provider.projectId,
                                            'userId' : null,
                                            'raisedUser' : ""
                                          },
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),


                          // Support Request Section
                          Text("Support Requests", style: textTheme.titleMedium?.copyWith(fontSize: 18),),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                    context, "Opened",(provider.projectDetailList.first.openSupCount != null) ? provider.projectDetailList.first.openSupCount.toString() : "0",
                                    Icons.folder_open,
                                    bayaInfraAmber,
                                    onTap: (){
                                      GoRouter.of(context).goNamed(AppRoutes.allSupportRequestScreen,
                                          extra: {
                                              'bottomBarStatus' : AllObservationAndSupportStatus.opened,
                                              'projectId' : provider.projectId,
                                              'userId' : null,
                                              'raisedUser' : ""
                                          },
                                      );
                                    }
                                ),
                              ),
                              Expanded(
                                child: _buildStatCard(
                                    context, "Delayed",(provider.projectDetailList.first.delaySupCount != null) ? provider.projectDetailList.first.delaySupCount.toString() : "0",
                                    Icons.access_time,
                                    bayaInfraRed,
                                    onTap: (){
                                      GoRouter.of(context).goNamed(AppRoutes.allSupportRequestScreen,
                                          extra: {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.delayed,
                                            'projectId' : provider.projectId,
                                            'userId' : null,
                                            'raisedUser' : ""},
                                      );
                                    }
                                ),
                              ),
                              Expanded(
                                child: _buildStatCard(
                                    context, "Closed",(provider.projectDetailList.first.closeSupCount != null) ? provider.projectDetailList.first.closeSupCount.toString() : "0",
                                    Icons.check_circle,
                                    bayaInfraPaleGreen,
                                    onTap: (){
                                      GoRouter.of(context).goNamed(AppRoutes.allSupportRequestScreen,
                                          extra: {
                                            'bottomBarStatus' : AllObservationAndSupportStatus.closed,
                                            'projectId' : provider.projectId,
                                            'userId' : null,
                                            'raisedUser' : ""},
                                      );
                                    }
                                ),
                              ),

                            ],
                          ),
                          SizedBox(height: 50,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },

      );
  }



  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,{required Function() onTap}) {
    final textTheme = Theme.of(context).textTheme;
    final iconTheme = Theme.of(context).iconTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: iconTheme.size ?? 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget projectDetailCard(BuildContext context, provider) {
    final textTheme = Theme.of(context).textTheme;
    const bayaInfraGrey = Color(0xFFB0B0B0);


    return BaseConsumer(
      provider: projectDetailsProvider ,
      builder: (context, provider,ref) {
        return Card(
          elevation: 0.5,
          color: Theme.of(context).cardColor,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // removes the bottom border line
            ),
            child: ExpansionTile(
              initiallyExpanded: provider.isExpandedClient,
              childrenPadding:  EdgeInsets.zero,

              onExpansionChanged: (value) {
               provider.expansionTileCollapseClient(value);
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                "Client",
                style: textTheme.titleSmall,
              ),
              subtitle: Text(
                provider.projectDetailList.first.clientName ?? "",
                style: textTheme.titleMedium,
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Icon(
                      provider.isExpandedClient ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
              children: [
                Divider(thickness: 0.2,),
                Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Dates section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start Date",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "${provider.projectTotalDays} days",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "End Date",
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                            color: bayaInfraGrey,
                            indent: 18,
                            endIndent: 18,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  provider.projectDetailList.first.startDate ??
                                      DateTime.now(),
                                ),
                                style: textTheme.titleSmall,
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  provider.projectDetailList.first.endDate ??
                                      DateTime.now(),
                                ),
                                style: textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Circular Graph
                      (provider.projectRemainingDays != 0 && provider.projectDetailList.first.startDate!.isBefore(DateTime.now()))?
                      Padding(
                        padding: const EdgeInsets.only(top: 8,bottom: 12),
                        child: Center(
                          child: SizedBox(
                            height: 200,
                            width: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(250, 250),
                                ),
                                PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 0,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(
                                        value: provider.projectTotalDays.toDouble(),
                                        color: bayaInfraGraphBlueSecondary,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        value: provider.projectRemainingDays.toDouble(),
                                        color: bayaInfraGraphBluePrimary,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${provider.projectRemainingDays} days left",
                                  style: textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) :
                      (provider.projectDetailList.first.startDate!.isBefore(DateTime.now())) ?
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                                color: bayaInfraRed,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 4, left: 8, right: 8),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme.of(context).iconTheme.color,
                                  ),

                                  Text(
                                    'Project delayed',
                                    style:
                                    Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) :
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            decoration: BoxDecoration(
                                color: bayaInfraGreen,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 4, left: 8, right: 8),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme.of(context).iconTheme.color,
                                  ),

                                  Text(
                                    'Scheduled to start',
                                    style:
                                    Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
  required this.title});
  final String title;



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BaseConsumer(
      provider: projectDetailsProvider,
      builder:(context,provider,ref) {
        final viewSupportDashBoard =
            ref.read(homeProvider.notifier).viewSupportDashBoard;
        final viewObservationDashBoard =
            ref.read(homeProvider.notifier).viewObservationDashBoard;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Visibility(
            visible: viewObservationDashBoard || viewSupportDashBoard,
            child: ElevatedButton.icon(
            onPressed: () {
              // GoRouter.of(context).pushNamed(AppRoutes.scheduleStatusScreen);
            },
            icon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
                  width: 3,
                ),
              ),
            ),
            label:  Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceVariant, // adaptive background
              foregroundColor: colorScheme.onSurface,      // adaptive text/icon color
              shape: const StadiumBorder(), // Rounded pill shape
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0, // Flat style
            ),
                  ),
          ),
        );
      },
    );
  }
}
