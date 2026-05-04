import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';

class ProjectScheduleSelectionTab extends StatelessWidget {
  const ProjectScheduleSelectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        final tabs = provider.tabs;


        final screenWidth = MediaQuery.of(context).size.width;
        // Each tab will take slightly more than 1/3 of screen width
        final tabWidth = (screenWidth / 3);
        // final tabWidth = (screenWidth / 2) ;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isSelected = provider.selectedTab == tab['value'];

              return SizedBox(
                width: tabWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => provider.goToPage(
                      index: index,
                      isFromButtonClick: true,
                    ),
                    child: AnimatedPhysicalModel(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      elevation: isSelected ? 1 : 0.5,
                      shape: BoxShape.rectangle,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0,),
                        child: Center(
                          child: Text(
                            tab['label'],
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontSize: 11,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}