import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';

class SelectionTab extends StatelessWidget {
  const SelectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<ProjectDetailsProvider>(
      provider: projectDetailsProvider,
      builder: (context, provider, ref) {
        final tabs = provider.tabs;
        if (tabs.length < 2) return const SizedBox();

        return Row(
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = provider.selectedTab == tab['value'];

            return Expanded(
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
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          tab['label'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.color
                                ?.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

          }),
        );
      },
    );
  }
}
