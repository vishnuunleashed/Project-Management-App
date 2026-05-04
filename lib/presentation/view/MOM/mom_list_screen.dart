/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:dcc_module/presentation/widgets/empty_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/presentation/provider/MOM/mom_list_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class MOMListScreen extends ConsumerStatefulWidget {
  const MOMListScreen({super.key});

  @override
  ConsumerState<MOMListScreen> createState() => _MOMListScreenState();
}

class _MOMListScreenState extends ConsumerState<MOMListScreen> with RouteAware {
  @override
  void didPopNext() {
    Future.microtask(
      () async {
        var provider = ref.watch(momListProvider);
        provider.fetchMOMList();
      },
    );
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MOMListProvider>(
      provider: momListProvider,
      appBar: CustomAppBar(title: const Text("Minutes of Meeting")),
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValues();
        provider.setNavigationParameter(extra);
      },
      builder: (context, provider, ref) {
        if (provider.momList.isEmpty) {
          return provider.loadingStatus.loader == Loader.loading
              ? SizedBox.shrink()
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).highlightColor,
                  onRefresh: () async {
                    provider.fetchMOMList();
                  },
                  child: Center(
                    child:
                        const EmptyListView(emptyText: "No meeting data found"),
                  ),
                );
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).highlightColor,
          onRefresh: () async {
            provider.fetchMOMList();
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: provider.momList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _MOMCard(
                item: provider.momList[index],
                projectId: provider.projectId ?? 0,
              );
            },
          ),
        );
      },
    );
  }
}

class _MOMCard extends StatelessWidget {
  final MOMListModel item;
  final int projectId;

  const _MOMCard({required this.item, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    final attendees = item.moMAttendeesDtls;
    const int maxVisible = 4;
    final visibleAttendees = attendees.take(maxVisible).toList();
    final extraCount = attendees.length - visibleAttendees.length;

    final avatarStackWidth = visibleAttendees.isNotEmpty
        ? ((visibleAttendees.length + (extraCount > 0 ? 1 : 0) - 1) * 20.0) +
            28.0
        : 0.0;

    return GestureDetector(
      onTap: () {
        GoRouter.of(context).pushNamed(AppRoutes.addMOMScreen, extra: {
          "projectId": projectId,
          "momId": item.id,
          "editMode": true
        });
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          // side: BorderSide(
          //   color: theme.dividerColor.withOpacity(0.6),
          //   width: 0.8,
          // ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.meetingTitle ?? "",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(item.dateTime),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (item.createdByUser != null && item.createdByUser!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.createdByUser!,
                                style:  theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Date chip top-right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.meetingTypeName ?? "",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 8,
                      ),
                      // Location row
                      if (item.location != null && item.location != "")
                        _MetaChip(
                          icon: item.location != null
                              ? Icons.location_on_outlined
                              : Icons.videocam_outlined,
                          label: item.location ?? "",
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.6, color: theme.dividerColor),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Discussion Point
                  if (item.discussionPoint != null) ...[
                    const SizedBox(height: 10),
                    _SectionBlock(
                      icon: Icons.forum_outlined,
                      label: 'Discussion',
                      value: item.discussionPoint!,
                      primary: primary,
                      theme: theme,
                    ),
                  ],

                  /// Decision Taken
                  if (item.decisionTaken != null && item.decisionTaken!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionBlock(
                      icon: Icons.gavel_outlined,
                      label: 'Decision',
                      value: item.decisionTaken!,
                      primary: primary,
                      theme: theme,
                    ),
                  ],

                  const SizedBox(height: 14),
                  Divider(height: 1, thickness: 0.6, color: theme.dividerColor),
                  const SizedBox(height: 12),

                  ///  Attendees + Show Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Attendee avatars
                      Visibility(
                        visible: attendees.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendees',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 28,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: avatarStackWidth,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Visible attendees (max 4)
                                      ...List.generate(visibleAttendees.length,
                                          (i) {
                                        final attendee = visibleAttendees[i];

                                        return Positioned(
                                          left: i * 20.0,
                                          child: _AvatarCircle(
                                            name: attendee.userName ??
                                                "NA", // adjust if needed
                                            index: i,
                                          ),
                                        );
                                      }),

                                      if (extraCount > 0)
                                        Positioned(
                                          left: visibleAttendees.length * 20.0,
                                          child: _AvatarCircle(
                                            name: '+$extraCount',
                                            index: -1,
                                            isExtra: true,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Show Actions button
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                            AppRoutes.momActionItemListScreen,
                            extra: {
                              "momId": item.id,
                              "projectId": projectId,
                              "isFromActionItem": true
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.task_alt_outlined,
                                size: 14,
                                color: theme.colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.moMDtls.length} Action${item.moMDtls.length == 1 ? '' : 's'}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 15,
                                color: theme.colorScheme.onPrimary
                                    .withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final ThemeData theme;

  const _SectionBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: primary.withOpacity(0.7)),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: double.infinity),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  final int index;
  final bool isExtra;

  const _AvatarCircle({
    required this.name,
    required this.index,
    this.isExtra = false,
  });

  String get _initials {
    if (isExtra) return name;

    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.length >= 2) {
      // First + Last name → 2 initials
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      // Single word → only 1 letter
      return parts.first[0].toUpperCase();
    }

    return '';
  }

  static const _bgColors = [
    Color(0xFFCECBF6),
    Color(0xFF9FE1CB),
    Color(0xFFF5C4B3),
    Color(0xFFB5D4F4),
    Color(0xFFD3D1C7),
  ];

  static const _fgColors = [
    Color(0xFF3C3489),
    Color(0xFF085041),
    Color(0xFF712B13),
    Color(0xFF0C447C),
    Color(0xFF444441),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isExtra
        ? theme.colorScheme.surfaceContainerHighest
        : _bgColors[index % _bgColors.length];
    final fgColor = isExtra
        ? theme.colorScheme.primary
        : _fgColors[index % _fgColors.length];

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: theme.cardColor, width: 1.8),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}

String _formatDate(String? date) {
  if (date == null || date.isEmpty) return "";
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (e) {
    return date;
  }
}
