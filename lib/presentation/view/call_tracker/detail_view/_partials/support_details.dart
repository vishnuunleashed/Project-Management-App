import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/utils/routes.dart';

class ServiceSupportScreen extends StatelessWidget {
  const ServiceSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return BaseView<ServiceRequestDashboardProvider>(
      initState: (context,provider,ref){
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initState(extra: extra);
      },
      appBar: CustomAppBar(
        title: Text("Support Requests"),
      ),
      provider: serviceRequestDashboardProvider,
      builder: (context,provider,ref) {
        if(provider.dashboardSupport.isEmpty){
          return SizedBox.shrink();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Column(
            children: [
              // Support Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.onTertiary),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {

                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service Details',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Service Ticket based Support Requests',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: colorScheme.onTertiary),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 16),
                            _buildStatusCard(
                              onTap: (){
                                GoRouter.of(context).pushNamed(AppRoutes.serviceCallTrackerDetailSupportRequestScreen,
                                  extra: {
                                    'bottomBarStatus' : AllObservationAndSupportStatus.opened,
                                    'refDataId' : provider.dashboardSupport.first.id,
                                    'userId' : null,
                                    'raisedUser' : ""
                                  },
                                );
                              },
                              context: context,
                              label: 'Opened',
                              count: provider.dashboardSupport.first.summaryjson.first.pendingcount.toString(),
                              icon: Icons.folder_open,
                              color: bayaInfraAmber,
                              bgColor: bayaInfraAmber.withValues(
                                  alpha: 0.1
                              ),
                              borderColor:bayaInfraAmber,

                            ),
                            const SizedBox(height: 12),
                            _buildStatusCard(
                              onTap: (){
                                GoRouter.of(context).pushNamed(AppRoutes.serviceCallTrackerDetailSupportRequestScreen,
                                  extra: {
                                    'bottomBarStatus' : AllObservationAndSupportStatus.delayed,
                                    'refDataId' : provider.dashboardSupport.first.id,
                                    'userId' : null,
                                    'raisedUser' : ""
                                  },
                                );
                              },
                              context: context,
                              label: 'Delayed',
                              count: provider.dashboardSupport.first.summaryjson.first.delayedcount.toString(),
                              icon: Icons.access_time,
                              color: bayaInfraRed,
                              borderColor: bayaInfraRed,
                              bgColor: bayaInfraRed.withValues(
                                  alpha: 0.1
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusCard(
                                onTap: (){
                                  GoRouter.of(context).pushNamed(AppRoutes.serviceCallTrackerDetailSupportRequestScreen,
                                    extra: {
                                      'bottomBarStatus' : AllObservationAndSupportStatus.closed,
                                      'refDataId' : provider.dashboardSupport.first.id,
                                      'userId' : null,
                                      'raisedUser' : ""
                                    },
                                  );
                                },
                                context: context,
                                label:  'Closed',
                                count:  provider.dashboardSupport.first.summaryjson.first.closedcount.toString(),
                                icon: Icons.check_circle,
                                borderColor: bayaInfraPaleGreen,
                                bgColor: bayaInfraPaleGreen.withValues(
                                    alpha: 0.1
                                ),
                                color: bayaInfraPaleGreen
                            ),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required void Function()? onTap,
  }) {
    final iconTheme = Theme.of(context).iconTheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [


            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color, size: iconTheme.size ?? 24),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            Text(
              count,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
