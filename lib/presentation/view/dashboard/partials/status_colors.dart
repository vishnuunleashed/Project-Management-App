import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';

class StatusLegend extends StatelessWidget {
  final bool isSummary;
 const StatusLegend({super.key,this.isSummary = true});

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<DashBoardProvider>(
      provider: dashBoardProvider,
      builder: (context, provider, child) {
        return Center(
          child: Wrap(
            spacing: 12, // space between items
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(isSummary ?provider.chartLabels.length:provider.chartLabels.length-1, (index) {

              return (isSummary && provider.chartValues[index]<= 0)||(!isSummary && !provider.hasDetailOpenOrDelayData(provider.chartLabels[index]))?SizedBox.shrink():Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Icon( isSummary?Icons.circle:Icons.square, color: provider.chartColors[index], size: 10),
                  const SizedBox(width: 4),
                  Text(
                    provider.chartLabels[index],
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
