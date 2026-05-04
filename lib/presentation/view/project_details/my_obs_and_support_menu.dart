import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/utils/routes.dart';


class MyObsAndSupport extends StatelessWidget {
  const MyObsAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BaseConsumer(
      provider: projectDetailsProvider,
      builder: (context, provider, ref) {
        return Card(
          color: Theme.of(context).cardColor,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: provider.isExpandedObsAndSupport,
              childrenPadding: EdgeInsets.zero,
              onExpansionChanged: (value) {
                provider.expansionTileCollapseObsAndSupport(value);
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                "Support and Observation",
                style: textTheme.titleSmall,
              ),
              subtitle: Text(
                "My Support and Observation",
                style: textTheme.titleMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Icon(
                      provider.isExpandedObsAndSupport
                          ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                  child: Column(
                    children: [

                      AnalyticSection(
                        title: "Observation",
                        icon: Icons.content_paste_search,
                        level: 0,
                        onTap: (){
                          GoRouter.of(context).pushNamed(AppRoutes.myObservationPage,
                              extra: {"isFromProjectDetails": false, "tag": "CREATED","projectId":provider.projectId});
                        },
                        children: [],
                      ),
                      AnalyticSection(
                        title: "Support Requests",
                        icon: Icons.support_agent,
                        level: 0,
                        onTap: (){
                          GoRouter.of(context).pushNamed(AppRoutes.mySupportRequestScreen,
                              extra: {"isFromProjectDetails": false, "tag": "CREATED",
                                "projectId":provider.projectId,});
                        },
                        children: [],
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


// Model class for child items
class AnalyticChild {
  final String title;
  final Widget? widget;
  final VoidCallback? onTap;

  AnalyticChild({
    required this.title,
    this.widget,
    this.onTap
  });
}

class AnalyticSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<AnalyticChild> children;
  final int level;
  final VoidCallback? onTap;

  const AnalyticSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
    required this.level,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnalyticSection> createState() => _AnalyticSectionState();
}

class _AnalyticSectionState extends State<AnalyticSection> {
  bool isExpandedObsAndSupport = false;

  bool get hasChildren => widget.children.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: widget.onTap ??
              (hasChildren
                  ? () {
                setState(() {
                  isExpandedObsAndSupport = !isExpandedObsAndSupport;
                });
              }
                  : null),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: Card(
              color: Theme.of(context).colorScheme.onTertiary,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(width: widget.level * 20.0),
                    if (hasChildren)
                      Icon(
                        isExpandedObsAndSupport
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 20,
                        color: theme.iconTheme.color,
                      )
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Icon(
                      widget.icon,
                      size: 20,
                      color: theme.iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (hasChildren && isExpandedObsAndSupport)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: widget.children.map((child) {
                return AnalyticChildItem(
                  onTap: child.onTap,
                  title: child.title,
                  contentWidget: child.widget,
                  level: widget.level + 1,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


class AnalyticChildItem extends StatefulWidget {
  final String title;
  final Widget? contentWidget;
  final int level;
  final void Function()? onTap;

  const AnalyticChildItem({
    Key? key,
    required this.title,
    this.contentWidget,
    required this.level,
    this.onTap
  }) : super(key: key);

  @override
  State<AnalyticChildItem> createState() => _AnalyticChildItemState();
}

class _AnalyticChildItemState extends State<AnalyticChildItem> {
  bool isExpandedObsAndSupport = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            child: Card(
              color: Theme.of(context).colorScheme.onTertiary,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),

              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric( vertical: 12),
                child: Row(
                  children: [
                    SizedBox(width: widget.level * 28.0),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.insert_chart_outlined,
                      size: 20,
                      color: theme.iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpandedObsAndSupport)
            Padding(
              padding: EdgeInsets.only(
                top: 8,
                right: 8,
                bottom: 8,
              ),
              child: widget.contentWidget,
            ),
        ],
      ),
    );
  }
}

// Example widget builders for each child
Widget _buildObservationChild1Widget() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Observation Chart 1",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            color: Colors.blue.shade50,
            child: Center(
              child: Text("Chart/Graph Widget Here"),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSupportRequestChild1Widget() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Support Request Analytics",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.purple.shade300],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text("Support Request Chart"),
            ),
          ),
        ],
      ),
    ),
  );
}

