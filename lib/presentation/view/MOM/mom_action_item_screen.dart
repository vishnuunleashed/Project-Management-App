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
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/base_elevated_icon_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:dcc_module/presentation/widgets/empty_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/presentation/provider/MOM/add_mom_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/MOM/partials/mom_support_bottom_sheet.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class MOMActionItemsScreen extends ConsumerStatefulWidget {
  const MOMActionItemsScreen({super.key});

  @override
  ConsumerState<MOMActionItemsScreen> createState() =>
      _MOMActionItemsScreenState();
}

class _MOMActionItemsScreenState extends ConsumerState<MOMActionItemsScreen>
    with RouteAware {
  @override
  void didPopNext() {
    Future.microtask(() async {
      var provider = ref.watch(addMOMProvider);
      provider.fetchEditModeMOMData(
          momId: provider.momId ?? 0, isFromActionItem: true);
    });
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
    return BaseView<AddMOMProvider>(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValues();
        provider.setNavigationParameter(extra);
      },
      appBar: CustomAppBar(title: Text("Action Items")),
      provider: addMOMProvider,
      builder: (context, provider, ref) {
        final mom = provider.selectedMOM;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MOMHeader(mom: mom),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _CountPill(
                count: mom?.moMDtls.length ?? 0,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            // ── List ────────────────────────────────────────────────
            Expanded(
              child: (mom?.moMDtls.isEmpty ?? true)
                  ? const Center(
                      child: EmptyListView(emptyText: 'No action items found'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: mom?.moMDtls.length ?? 0,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _ActionItemCard(
                          detail: mom!.moMDtls[index],
                          index: index,
                          momId: mom.id,
                          provider: provider,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MOMHeader extends StatelessWidget {
  final MOMListModel? mom;
  const _MOMHeader({required this.mom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      elevation: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + Type ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          mom?.meetingTitle ?? 'No Title',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (mom?.meetingTypeName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mom!.meetingTypeName!,
                            style: TextStyle(
                              fontSize: 10,
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Date (left)
                      Icon(Icons.calendar_month_outlined,
                          size: 18, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(mom?.dateTime),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),

                      const Spacer(),

                      // Location (tight to right)
                      if (mom?.location?.isNotEmpty == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 18,
                                color: theme.textTheme.bodySmall?.color),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                mom!.location!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          Text('$count action item${count == 1 ? '' : 's'}',
              style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ActionItemCard extends StatelessWidget {
  final MOMDetailModel detail;
  final int index;
  final int? momId;
  final AddMOMProvider provider;

  const _ActionItemCard({
    required this.detail,
    required this.index,
    required this.momId,
    required this.provider,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.length >= 2) {
      // First + Last → 2 initials
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      // Single word → only 1 letter
      return parts.first[0].toUpperCase();
    }

    return '';
  }

  static const List<Color> _avatarBg = [
    Color(0xFFCECBF6),
    Color(0xFF9FE1CB),
    Color(0xFFF5C4B3),
    Color(0xFFB5D4F4),
    Color(0xFFD3D1C7),
  ];

  static const List<Color> _avatarFg = [
    Color(0xFF3C3489),
    Color(0xFF085041),
    Color(0xFF712B13),
    Color(0xFF0C447C),
    Color(0xFF444441),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIdx = index % _avatarBg.length;
    final ownerName = detail.ownerName;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card body ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Index + owner in one row ─────────────────────────
                Row(
                  children: [
                    // Index bubble
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE6F1FB),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0C447C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Owner avatar + name (compact inline)
                    if (ownerName != null)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _avatarBg[colorIdx],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(ownerName),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: _avatarFg[colorIdx],
                          ),
                        ),
                      ),
                    const SizedBox(width: 5),
                    Text(ownerName ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Action item text ─────────────────────────────────
                Text(
                  detail.actionItem ?? "",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),

          // ── Action buttons ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: BaseElevatedIconButton(
                      onPressed: () {
                        if (detail.observationDetails.isEmpty) {
                          GoRouter.of(context).pushNamed(
                            AppRoutes.addObservation,
                            extra: {
                              'projectId': provider.projectId,
                              'observationPoint': detail.actionItem,
                              'owner': detail.ownerName,
                              'isFromMOM': true,
                              'actionItemId': detail.id,
                            },
                          );
                        } else {
                          GoRouter.of(context).push(
                            AppRoutes.closeObservation,
                            extra: {
                              'observationId':
                                  detail.observationDetails.first.id,
                              'projectId': provider.projectId,
                            },
                          );
                        }
                      },
                      fontSize: 12,
                      icon: detail.observationDetails.isEmpty
                          ? Icons.add
                          : Icons.visibility,
                      text: detail.observationDetails.isEmpty
                          ? "Add Observation"
                          : "View Observation",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: BaseElevatedIconButton(
                      onPressed: () {
                        provider.fetchSupportRequestBasedOnMOM(
                          actionItemId: detail.id ?? 0,
                          onSuccess: () {
                            if(provider.supportRequestList.isNotEmpty) {
                              provider.initPaginationController(detail.id ?? 0);
                              MOMSupportRequestBottomSheet.show(
                                context,
                                actionItem: detail.actionItem,
                                ownerName: detail.ownerName,
                                projectId: provider.projectId,
                                actionItemId: detail.id,
                              );
                            }
                            else{
                              GoRouter.of(context).pushNamed(AppRoutes.addSupportRequest,
                                extra: {
                                  'projectId': provider.projectId ?? 0,
                                  'supportRequestPoints': detail.actionItem,
                                  'owner': detail.ownerName,
                                  'isFromMOM': true,
                                  'actionItemId': detail.id
                                },
                              );
                            }
                          },
                        );
                      },
                      icon: Icons.add,
                      text: "Add Support",
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
