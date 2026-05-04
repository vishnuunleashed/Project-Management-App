import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/presentation/provider/MOM/add_mom_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

import 'mom_sheet_shared_widgets.dart';

class MOMSupportRequestBottomSheet extends StatelessWidget {
  final String? actionItem;
  final String? ownerName;
  final int? projectId;
  final int? actionItemId;

  const MOMSupportRequestBottomSheet({
    super.key,
    required this.actionItem,
    required this.ownerName,
    required this.projectId,
    required this.actionItemId,
  });

  static void show(
      BuildContext context, {
        required String? actionItem,
        required String? ownerName,
        required int? projectId,
        required int? actionItemId,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MOMSupportRequestBottomSheet(
        actionItem: actionItem,
        ownerName: ownerName,
        projectId: projectId,
        actionItemId: actionItemId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return BaseConsumer<AddMOMProvider>(
      provider: addMOMProvider,
      builder: (context, provider, ref) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  DragHandle(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Support Request',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:() => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
                  ActionItemBanner(actionItem: actionItem, ownerName: ownerName,),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          'Support Requests',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        CountBadge(
                          count: (provider.supportRequestList.isNotEmpty) ? (provider.supportRequestList.first.totalRecords ?? 0) : 0,
                          bg: Theme.of(context).primaryColor.withOpacity(0.1),
                          fg: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: provider.supportRequestList.isEmpty
                        ? const Center(
                      child: Text(
                        'No support requests yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.separated(
                      controller: provider.supScrollController,
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                      itemCount: provider.supportRequestList.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final req = provider.supportRequestList[i];
                        // TODO: replace with your actual SupportRequestModel fields
                        return GestureDetector(
                          onTap: (){
                            GoRouter.of(context).pushNamed(AppRoutes.closeAllSupportRequest, extra: {'supportRequestId': req.id});
                          },
                          child: supportRequestCard(
                            context: context,
                            supportRequests: req,
                            index: i,
                            provider: provider
                          ),
                        );
                      },
                    ),
                  ),

                  StickyBottomBar(
                    mq: mq,
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Add New Support',
                    onCancel: () => GoRouter.of(context).pop(),
                    onConfirm: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).pushNamed(
                        AppRoutes.addSupportRequest,
                        extra: {
                          'projectId': projectId ?? 0,
                          'supportRequestPoints': actionItem,
                          'owner': ownerName,
                          'isFromMOM': true,
                          'actionItemId' : actionItemId
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }
}



Widget supportRequestCard({required int index ,
  required SupportRequestDtlModel supportRequests, required BuildContext context,required AddMOMProvider provider}) {
  String formatDate(DateTime? date) {
    final now = DateTime.now();
    final target = date ?? now;

    if (target.year == now.year &&
        target.month == now.month &&
        target.day == now.day) {
      return "Today | ${DateFormat("hh:mm a").format(target)}";
    }

    return DateFormat('MMM dd, yyyy | hh:mm a').format(target);
  }
  return  Card(
    elevation: 0.5,
    color: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        width: 0.5,
        color: Theme.of(context).cardColor,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(
          top: 8.0, bottom: 8.0, left: 4, right: 4),
      child: Column(
          children:
          [
            Visibility(
              visible: supportRequests.refoptionname != null
                  && supportRequests.refoptionname!.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child:
                Container(
                    decoration: BoxDecoration(
                    ),
                    child:
                    Row(
                      spacing: 4,
                      children: [
                        Icon(CupertinoIcons.link,size: 16, color: Theme.of(context).textTheme.bodyMedium?.color,),
                        Text("Against ${supportRequests.refoptionname}",style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic
                        ),)

                      ],
                    )
                ),
              ),
            ),
            Visibility(
              visible: supportRequests.logStatusCode == "FORWARD" || supportRequests.logStatusCode == "REASSIGNED",
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child:
                Container(
                  decoration: BoxDecoration(
                  ),
                  child:
                  supportRequests.logStatusCode == "FORWARD" ?Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.forward, color: Theme.of(context).textTheme.bodyMedium?.color,),
                      Text("Forwarded",style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic
                      ),)

                    ],
                  ) :
                  Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.compare_arrows, color: Theme.of(context).textTheme.bodyMedium?.color,),
                      Text("Reassigned",style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle:FontStyle.italic
                      ),)

                    ],
                  ),
                ),
              ),
            ),
            Stack(
                children: [Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0,top: 4),
                      child: Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              ProfileImageDialog.show(context: context,
                                imageUrl:supportRequests.logFromUserProfileUrl ?? "",
                                userName:  supportRequests.logFromUser ?? "User",);

                            },
                            child: CachedNetworkImageWidget(
                              imageUrl: supportRequests.logFromUserProfileUrl ?? "",
                              isCircleEnabled: supportRequests.iscriticalyn == "Y",
                              circleColor: Colors.red,
                              size: 45,
                              userName: supportRequests.logFromUser ?? "",
                            ),),
                          SizedBox(width: 4,),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  '${supportRequests.logFromUser}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  (supportRequests.logStatusCode == "SUBMIT")
                                      ? "Request for closure"
                                      : (supportRequests.requestStatusCode != "CLOSED")
                                      ? (supportRequests.logToUser == provider.userName)
                                      ? supportRequests.logStatusCode == "ASSIGNED"
                                      ? "Assigned to you"
                                      : supportRequests.logStatusCode == "SUBMIT"
                                      ? "Submitted to you"
                                      : (supportRequests.logStatusCode == "FORWARD")
                                      ? "Forwarded to you"
                                      : "Reassigned to you"
                                      : supportRequests.logStatusCode == "CANCELLED"
                                      ? 'Cancelled by ${supportRequests.logFromUser}'
                                      :supportRequests.logStatusCode == "ASSIGNED"
                                      ? 'Assigned to ${supportRequests.logToUser}'
                                      : (supportRequests.logStatusCode == "SUBMIT")
                                      ? "Submitted to ${supportRequests.logToUser}"
                                      : (supportRequests.logStatusCode == "FORWARD")
                                      ? "Forwarded to ${supportRequests.logToUser}"
                                      :"Reassigned to ${supportRequests.logToUser}"
                                      : "Closed by ${(supportRequests.closedBy == provider.userName) ? 'You'
                                      : "${supportRequests.closedBy}"}",
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w400),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Trans No : ",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              "${supportRequests.transNo}",
                              overflow: TextOverflow.ellipsis,
                              style:  Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 12,right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Escalation Date',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(supportRequests.createdTime),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Expected Closure Date',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(supportRequests
                                    .expectedClosureDate ??
                                    DateTime.now()),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),


                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Points     : ',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                            Expanded(
                              child: Text(
                                '${supportRequests.points}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                  Visibility(
                    visible: supportRequests.requestStatusCode == "CLOSED" ,
                    child: Positioned(
                      top: 70,
                      right: 12.5,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: bayaInfraGreen,
                                borderRadius: BorderRadius.circular(
                                    12)),
                            child:
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0,
                                  bottom: 4,
                                  left: 8,
                                  right: 8),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme
                                        .of(context)
                                        .iconTheme
                                        .color,
                                  ),
                                  Text(
                                    'Closed',
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible:  supportRequests.requestStatusCode != "CLOSED" ,
                    child: Positioned(
                      top: 70,
                      right: 12.5,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: provider.supportRequestList[index]
                                    .remainingTime != null
                                    ? bayaInfraGreen
                                    : bayaInfraRed,
                                borderRadius: BorderRadius.circular(
                                    12)),
                            child:
                            provider.supportRequestList[index]
                                .remainingTime != null ?
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0,
                                  bottom: 4,
                                  left: 8,
                                  right: 8),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme
                                        .of(context)
                                        .iconTheme
                                        .color,
                                  ),
                                  Text(
                                    '${provider.supportRequestList[index]
                                        .delayedTime}',
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ],
                              ),
                            ) : Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0,
                                  bottom: 4,
                                  left: 8,
                                  right: 8),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    size: 16,
                                    color: Theme
                                        .of(context)
                                        .iconTheme
                                        .color,
                                  ),
                                  Text(
                                    '${provider.supportRequestList[index]
                                        .delayedTime}',
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ],
                              ),
                            )
                            ,
                          ),
                        ],
                      ),
                    ),
                  )
                ]
            ),
          ]
      ),
    ),
  );

}
