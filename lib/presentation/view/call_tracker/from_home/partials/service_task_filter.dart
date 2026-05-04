/*-------------------------------------------------------------------------------
AUTHOR          : Shamnas Abdulla
CREATED DATE    : 22-01-2026
PURPOSE         :
MODULE/TOPIC    :
REMARKS         : EI0097-26
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#    DATE        MODIFIED BY     TICKET#         DESCRIPTION
--------------------------------------------------------------------------------
01    05/02/2026     Shamnas        EI0112-26       Design correction
02    10/03/2026     Shamnas        EI0097-26       Added count badge per tab
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/call_tracker/from_home/tasks_wise_ticket_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';

class ServiceTaskDashboardFilterTab extends StatelessWidget {
  final ProviderListenable<TasksWiseTicketProvider> providerRef;

  const ServiceTaskDashboardFilterTab({super.key, required this.providerRef});

  Color _tabColor(BuildContext context, TaskFilterDashboard filter, bool isSelected) {
    if (!isSelected) return const Color(0xFFB0BEC5);
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return BaseConsumer<TasksWiseTicketProvider>(
      provider: providerRef,
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabs = TaskFilterDashboard.values.map((filter) {
                  final isSelected = provider.selectedTaskFilter == filter;
                  final tabColor = _tabColor(context, filter, isSelected);
                  final count = provider.getCountForFilter(filter);

                  String label;
                  if (filter == TaskFilterDashboard.assignment_pending) {
                    label = "PENDING";
                  } else if (filter == TaskFilterDashboard.send_back) {
                    label = "REVIEWER REJECTED";
                  } else if (filter == TaskFilterDashboard.reviewed) {
                    label = "REVIEWED";
                  } else if (filter == TaskFilterDashboard.rejected) {
                    label = "PC. REJECTED";
                  } else {
                    label = filter.name.replaceAll('_', ' ').toUpperCase();
                  }


                  return GestureDetector(
                    onTap: () => provider.changeFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tabColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? tabColor : Colors.grey.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? tabColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? tabColor : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: tabs,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum TaskFilterDashboard {
  all,
  assignment_pending,
  assigned,
  accepted,
  submitted,
  reviewed,
  send_back,
  closed,
  rejected,
  reopened,
  cancelled,
}