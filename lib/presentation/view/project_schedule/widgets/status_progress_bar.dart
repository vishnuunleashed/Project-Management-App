import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';

class ProgressBarWidgetStatus extends StatelessWidget {
  final bool enabled;
  final bool showDualProgress;
  const ProgressBarWidgetStatus({
    super.key,
    this.enabled = true,
    this.showDualProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        if (showDualProgress) {
          // Show both actual and planned progress bars
          return _buildDualProgressBar(context, provider);
        } else {
          // Show single interactive progress bar
          return _buildSingleProgressBar(context, provider);
        }
      },
    );
  }

  Widget _buildDualProgressBar(BuildContext context, ProjectScheduleProvider provider) {
    final actualProgress = provider.summaryData.isNotEmpty
        ? provider.summaryData.first.percentComplete / 100
        : 0.0;
    final plannedProgress = provider.summaryData.isNotEmpty
        ? provider.summaryData.first.plannedProgress / 100
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          // Actual Progress Bar
          _buildProgressBarWithLabel(
            context,
            'Actual',
            actualProgress,
            Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          // Planned Progress Bar
          _buildProgressBarWithLabel(
            context,
            'Planned',
            plannedProgress,
            Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProgressBarWithLabel(
      BuildContext context,
      String label,
      double progress,
      Color color,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(progress * 100).toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 12,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final handleSize = 20.0;
              final handlePosition = (barWidth * progress) - (handleSize / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Progress bar
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.7),
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Handle indicator
                  Positioned(
                    left: handlePosition.clamp(0.0, barWidth - handleSize),
                    top: -4,
                    child: Container(
                      width: handleSize,
                      height: handleSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSingleProgressBar(BuildContext context, ProjectScheduleProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: enabled
                    ? null
                    : () {
                  final newValue = (provider.progressValue - 0.05).clamp(0.0, 1.0);
                  provider.updateProgress(newValue);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${(provider.progressValue * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: enabled
                    ? null
                    : () {
                  final newValue = (provider.progressValue + 0.05).clamp(0.0, 1.0);
                  provider.updateProgress(newValue);
                },
              ),
            ],
          ),
          GestureDetector(
            onTapDown: enabled
                ? null
                : (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = details.localPosition;
              final newValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              provider.updateProgress(newValue);
            },
            onHorizontalDragUpdate: enabled
                ? null
                : (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = details.localPosition;
              final newValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              provider.updateProgress(newValue);
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final handleSize = 24.0;
                  final handlePosition = (barWidth * provider.progressValue) - (handleSize / 2);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: provider.progressValue,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                Theme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !enabled,
                        child: Positioned(
                          left: handlePosition,
                          top: -6,
                          child: Container(
                            width: handleSize,
                            height: handleSize,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (index) {
              return GestureDetector(
                onTap: enabled
                    ? null
                    : () {
                  provider.updateProgress(index * 10 / 100.0);
                },
                child: SizedBox(
                  width: 25,
                  height: 20,
                  child: Text(
                    '${index * 10}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}