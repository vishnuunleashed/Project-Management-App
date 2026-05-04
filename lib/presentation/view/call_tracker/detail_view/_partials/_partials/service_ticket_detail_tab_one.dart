import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/expansion_tile/expansion_tile_for_close_page.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:intl/intl.dart' as intl;

class ServiceTicketDetailTabOne extends StatelessWidget {
  const ServiceTicketDetailTabOne({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseConsumer(
      provider: serviceRequestDashboardProvider,
      builder: (context,provider,ref) {
        CallTicketModel? ticket = provider.currentTicket;
        final theme = Theme.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        if (ticket == null) {
          return SizedBox(height: 0);
        }else {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          child: Column(
            spacing: 8,
            children: [
              Card(
                elevation: 0.5,
                margin: EdgeInsets.zero,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ticket No : ',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  ticket.ticketNo ?? '',
                                  style: theme.textTheme.titleSmall,
                                ),


                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: provider
                                  .getPriorityColor(ticket.priority)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag,
                                    size: 16,
                                    color: provider.getPriorityColor(
                                        ticket.priority)),
                                const SizedBox(width: 6),
                                Text(
                                  ticket.priority ?? '',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: provider.getPriorityColor(
                                        ticket.priority),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // _buildDateProgressWidget(
                      //     context, ticket, theme, colorScheme),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: ticket.description != null &&
                    ticket.description!.isNotEmpty,
                child: CustomExpandableCard(
                  title: "Description",
                  content: ticket.description ?? "",
                  trimLength: 500,
                  minHeightFactor: 0.14,
                  showCopyButton: true,
                  contentStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Visibility(
                visible: ticket.reviewremarks != null &&
                    ticket.reviewremarks!.isNotEmpty &&
                    ticket.statusCode == "REJECTED",
                child: CustomExpandableCard(
                  title: "Review Remarks",
                  content: ticket.reviewremarks ?? "",
                  trimLength: 500,
                  minHeightFactor: 0.14,
                  showCopyButton: true,
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                elevation: 0.5,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: provider.isExpandedAssignment,
                    minTileHeight:
                    MediaQuery.of(context).size.height * .06,
                    onExpansionChanged: (value) =>
                        provider.toggleAssignmentExpansion(value),
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    title: Text('Assignment',
                        style: theme.textTheme.titleLarge),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        provider.isExpandedAssignment
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    children: [
                      Divider(
                          height: 1,
                          thickness: 0.3,
                          color: Theme.of(context).colorScheme.primary),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 12),
                        child: Column(
                          children: [
                            _buildAssignmentItem(
                                context: context,
                                label: 'Coordinator',
                                name: ticket.coordinateuser ?? "Unassigned",
                                initial: _getInitials(ticket.coordinateuser),
                                color: const Color(0xFF10B981),
                                theme: theme,
                                colorScheme: colorScheme,
                                imageUrl:
                                ticket.coordinateuserprofileurl ?? ""),
                            const SizedBox(height: 8),

                            _buildAssignmentItem(
                                context: context,
                                label: 'Reviewer',
                                name: ticket.serviceReportUser ?? "Unassigned",
                                initial:
                                _getInitials(ticket.serviceReportUser),
                                color: const Color(0xFF10B981),
                                theme: theme,
                                colorScheme: colorScheme,
                                imageUrl:
                                ticket.servicereportuserprofileurl ?? ""),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildExpandableSection(
                context: context,
                provider: provider,
                theme: theme,
                colorScheme: colorScheme,
                title: 'Location Details',
                isExpanded: provider.isExpandedLocation,
                onExpansionChanged: (value) =>
                    provider.toggleLocationExpansion(value),
                content: Column(
                  children: [
                    Row(children: [
                      Expanded(child: _buildInfoItem(
                          'Client', ticket.client ?? '', theme, colorScheme)),
                    ]),
                    Row(children: [
                      Expanded(child: _buildInfoItem(
                          'Site', ticket.site ?? '', theme, colorScheme)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(child: _buildInfoItem(
                          'Building', ticket.building ?? '', theme, colorScheme)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(child: _buildInfoItem(
                          'Floor', ticket.floor ?? '', theme, colorScheme)),
                    ]),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: _buildInfoItem(
                            'Address', ticket.address ?? '', theme, colorScheme)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildExpandableSection(
                context: context,
                provider: provider,
                theme: theme,
                colorScheme: colorScheme,
                title: 'Other Service Information',
                isExpanded: provider.isExpandedServiceInfo,
                onExpansionChanged: (value) =>
                    provider.toggleServiceInfoExpansion(value),
                content: Column(
                  children: [
                    Row(children: [
                      Expanded(child: _buildInfoItem(
                          'Category', ticket.category ?? '', theme, colorScheme)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoItem('Created Date',
                          _formatDate(ticket.ticketDate ?? ''), theme, colorScheme)),
                    ]),
                    const SizedBox(height: 8),
                    // Row(children: [
                    //   Expanded(child: _buildInfoItem('Target Closure Date',
                    //       _formatDate(ticket.targetClosureDate ?? ''), theme, colorScheme)),
                    //   const SizedBox(width: 8),
                    //   Expanded(
                    //     child: Visibility(
                    //       visible: ticket.actualClosureDate != null &&
                    //           ticket.actualClosureDate!.isNotEmpty,
                    //       child: _buildInfoItem('Actual Closure date',
                    //           _formatDate(ticket.actualClosureDate ?? ''),
                    //           theme, colorScheme),
                    //     ),
                    //   ),
                    // ]),
                  ],
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        );
        }
      }
    );
  }

  // Helper method to format DateTime
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return "";

    final now = DateTime.now();
    if (parsedDate.year == now.year) {
      // Same year → don't show year
      return intl.DateFormat.MMMd().format(parsedDate); // e.g. Oct 14
    } else {
      // Different year → show year
      return intl.DateFormat.yMMMd().format(parsedDate); // e.g. Oct 14, 2024
    }
  }

  // Helper method to get initials from name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0].substring(0, 1).toUpperCase() : '';
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  Widget _buildExpandableSection({
    required BuildContext context,
    required dynamic provider,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required Widget content,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          minTileHeight: MediaQuery.of(context).size.height * .06,
          childrenPadding: EdgeInsets.zero,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          title: Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: theme.iconTheme.color,
            ),
          ),
          children: [
            Divider(
              height: 1,
              thickness: 0.3,
              color: Theme.of(context).colorScheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentItem({
    required BuildContext context,
    required String label,
    required String name,
    required String imageUrl,
    required String initial,
    required Color color,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ProfileImageDialog.show(
                context: context,
                imageUrl: imageUrl ,
                userName: name,
              );
            },
            child: CachedNetworkImageWidget(
              padding: EdgeInsets.zero,
              imageUrl: imageUrl ?? "",
              size: 48,
              userName: name,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label,
      String value,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget _buildDateProgressWidget(BuildContext context, CallTicketModel ticket,
  //     ThemeData theme, ColorScheme colorScheme) {
  //   const bayaInfraGrey = Color(0xFFB0B0B0);
  //
  //   final now = DateTime.now();
  //
  //   DateTime? createdDate = DateTime.tryParse(ticket.ticketDate ?? '');
  //
  //   // DateTime? endDate = DateTime.tryParse(ticket.targetClosureDate ?? '');
  //   DateTime statusDate =
  //       DateTime.tryParse(ticket.statusDate ?? '') ?? DateTime.now();
  //
  //   // DateTime targetClosureDate = DateTime.tryParse(
  //   //     ticket.targetClosureDate ?? DateTime.now().toString()) ??
  //   //     DateTime.now();
  //
  //   int overdueDays = 0;
  //   int totalDays = 0;
  //   int remainingDays = 0;
  //   int delayedDays = 0;
  //   int closedDays = 0;
  //   bool isSameDay = false;
  //
  //   if (createdDate != null && endDate != null) {
  //     totalDays = endDate.difference(createdDate).inDays;
  //     final normalizedNow = DateTime(now.year, now.month, now.day);
  //     remainingDays = endDate.difference(normalizedNow).inDays;
  //
  //     isSameDay = totalDays == 0;
  //
  //     if (remainingDays < 0) {
  //       overdueDays = remainingDays.abs();
  //       remainingDays = 0;
  //     }
  //
  //     if (remainingDays < 0) remainingDays = 0;
  //
  //     if (targetClosureDate.isBefore(now)) {
  //       delayedDays = targetClosureDate.difference(now).inDays.abs();
  //     }
  //   }
  //   if (ticket.status == "Closed") {
  //     closedDays = statusDate.difference(targetClosureDate).inDays;
  //   }
  //   if (closedDays < 0) {
  //     closedDays = 0;
  //   }
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             ticket.status == "Closed" ? "Tgt Closure Date" : "Created Date",
  //             style: theme.textTheme.labelMedium
  //
  //             ,
  //           ),
  //           ticket.status == "Closed"
  //               ? statusDate.isAfter(targetClosureDate)
  //               ? Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 0.0),
  //             child: Center(
  //               child: Container(
  //                 width: MediaQuery.of(context).size.width * 0.4,
  //                 decoration: BoxDecoration(
  //                   color: bayaInfraRed,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 4.0, bottom: 4, left: 8, right: 8),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.access_time_filled_outlined,
  //                         size: 16,
  //                         color: theme.iconTheme.color,
  //                       ),
  //                       const SizedBox(width: 10),
  //                       Text(
  //                         closedDays == 1 || closedDays == 0
  //                             ? "$closedDays day delayed"
  //                             : "$closedDays days delayed",
  //                         style: theme.textTheme.labelMedium,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           )
  //               : Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 0.0),
  //             child: Center(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: bayaInfraGreen,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 4.0, bottom: 4, left: 8, right: 8),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.check_circle,
  //                         size: 16,
  //                         color: theme.iconTheme.color,
  //                       ),
  //                       const SizedBox(width: 10),
  //                       Text(
  //                         'On Time',
  //                         style: theme.textTheme.labelMedium,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           )
  //               : (remainingDays >= 0 && delayedDays == 0)
  //               ? Padding(
  //             padding: const EdgeInsets.only(top: 0, bottom: 0),
  //             child: Center(
  //               child: Stack(
  //                 alignment: Alignment.center,
  //                 children: [
  //                   Text(
  //                     isSameDay
  //                         ? "Due today"
  //                         : remainingDays == 1 || remainingDays == 0
  //                         ? "$remainingDays day left"
  //                         : "$remainingDays days left",
  //                     style: theme.textTheme.labelMedium,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           )
  //               : (delayedDays > 0)
  //               ? Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 0.0),
  //             child: Center(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: bayaInfraRed,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 4.0, bottom: 4, left: 8, right: 8),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.access_time_filled_outlined,
  //                         size: 16,
  //                         color: theme.iconTheme.color,
  //                       ),
  //                       const SizedBox(width: 10),
  //                       Text(
  //                         delayedDays == 1 || delayedDays == 0
  //                             ? "$delayedDays day delayed"
  //                             : "$delayedDays days delayed",
  //                         style: theme.textTheme.labelMedium,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           )
  //               : Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 0.0),
  //             child: Center(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: bayaInfraGreen,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 4.0, bottom: 4, left: 8, right: 8),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.access_time_filled_outlined,
  //                         size: 16,
  //                         color: theme.iconTheme.color,
  //                       ),
  //                       const SizedBox(width: 10),
  //                       Text(
  //                         'Scheduled to start',
  //                         style: theme.textTheme.labelMedium,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Text(
  //             ticket.status == "Closed" ? "Closed Date" : "Tgt Closure Date",
  //             style: theme.textTheme.labelMedium,
  //           ),
  //         ],
  //       ),
  //       const Divider(
  //         thickness: 2,
  //         color: bayaInfraGrey,
  //         indent: 18,
  //         endIndent: 18,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Text(
  //           //   ticket.status == "Closed"
  //           //       ? intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(
  //           //       ticket.targetClosureDate ?? DateTime.now().toString()))
  //           //       : createdDate != null
  //           //       ? intl.DateFormat('MMM dd, yyyy').format(createdDate)
  //           //       : '',
  //           //   style: theme.textTheme.labelLarge,
  //           // ),
  //           // Text(
  //           //   ticket.status == "Closed"
  //           //       ? intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(
  //           //       ticket.statusDate ?? DateTime.now().toString()))
  //           //       : endDate != null
  //           //       ? intl.DateFormat('MMM dd, yyyy').format(endDate)
  //           //       : '',
  //           //   style: theme.textTheme.labelLarge,
  //           // ),
  //         ],
  //       ),
  //     ],
  //   );
  // }


}
