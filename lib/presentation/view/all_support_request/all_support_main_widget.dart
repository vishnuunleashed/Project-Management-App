import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/all_support_request_provider/all_support_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/follow_button.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';

import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AllSupportRequestMainWidget extends StatelessWidget {
  const AllSupportRequestMainWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<AllSupportRequestProvider>(
        provider: allSupportRequestProvider,
        builder: (context, provider, ref) {

          return Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).highlightColor,
                    onRefresh: () {
                      return provider.onRefreshSptAction();
                    },
                    child: provider.supportRequestFetched
                        ? (provider.supportRequestList.isEmpty)
                        ? EmptyListView(
                      emptyText:
                      "There are no ${provider.bottomBarStatus == AllObservationAndSupportStatus.opened ? "opened"
                          : provider.bottomBarStatus == AllObservationAndSupportStatus.delayed
                          ? "delayed" : "closed"} ${provider.isFromDashboard ? "support requests for this user" : "support requests in this project yet" }",

                    )
                        : ListView.builder(
                      controller: provider.supScrollController,
                      itemCount: provider.supportRequestList.length,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            InkWell(
                                onTap: () {
                                  // TO pass Support request id
                                  int supportRequestId = provider
                                      .supportRequestList[index].id ??
                                      0;
                                  GoRouter.of(context).pushNamed(
                                      AppRoutes.closeAllSupportRequest,
                                      extra: {
                                        'supportRequestId': supportRequestId
                                      });
                                },
                                child: supportRequestCard(
                                  index: index,
                                ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: FollowButton(
                                  isCritical: provider
                                      .supportRequestList[index].iscriticalyn == "Y",
                                  isFollowed:  (provider
                                    .supportRequestList[index].notifyuseryn == "Y"
                                       &&  provider.supportRequestList[index].addedbycreatoryn == "N")
                                      && provider.supportRequestList[index].requestStatusCode == "PENDING",


                                  isBlocked: ((provider
                                      .supportRequestList[index].escalatedBy == provider.userName)
                                      && provider.supportRequestList[index].requestStatusCode == "PENDING")
                                  || provider.supportRequestList[index].requestStatusCode != "PENDING",
                                  isCC:  provider
                                      .supportRequestList[index].notifyuseryn == "Y"
                                      &&  provider.supportRequestList[index].addedbycreatoryn == "Y",
                                  onFollow: () {
                                    int supportRequestId = provider
                                        .supportRequestList[index].id ??
                                        0;
                                    provider.followSupportRequest(onRequestSuccess: (){
                                      provider.updateSupportListForFollow(index);
                                    },
                                    supportId: supportRequestId);

                                  },
                                  onUnfollow: (){
                                    int supportRequestId = provider
                                        .supportRequestList[index].id ??
                                        0;
                                    provider.unFollowSupportRequest(supportId: supportRequestId,
                                    onRequestSuccess: (){
                                      provider.updateSupportListForUnFollow(index);
                                    }
                                    );

                                  },

                                ),
                            ),
                          ],
                        );
                      },
                    )
                        : Container(),
                  ),
                ),
              ],
            ),

          ]);
        });
  }

  Widget supportRequestCard({required int index}) {
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
    return BaseStatelessConsumer<AllSupportRequestProvider>(
      provider: allSupportRequestProvider,
      builder: (context, provider, ref) {
        return Padding(
          padding: (index + 1 == provider.supportRequestList.length) ? const EdgeInsets.only(bottom: 50.0) : EdgeInsets.zero,
          child: Card(
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
              padding:
              const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4, right: 4),
              child: Column(children: [
                Stack(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Visibility(
                        visible: provider.supportRequestList[index].refoptionname != null
                            && provider.supportRequestList[index].refoptionname!.isNotEmpty,
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
                                  Text("Against ${provider.supportRequestList[index].refoptionname}",style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic
                                  ),)

                                ],
                              )
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, top: 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ProfileImageDialog.show(context: context,
                                  imageUrl:provider.supportRequestList[index].logFromUserProfileUrl ?? "",
                                  userName:  provider.supportRequestList[index].logFromUser ?? "User",);
                              },
                              child: CachedNetworkImageWidget(
                                size: 45,
                                imageUrl:  provider.supportRequestList[index].logFromUserProfileUrl ?? "",
                                isCircleEnabled: provider
                                    .supportRequestList[index].iscriticalyn == "Y",
                                circleColor: Colors.red,
                                userName: provider.supportRequestList[index].logFromUser ?? "",

                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    '${provider.supportRequestList[index].logFromUser}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Text(provider.supportRequestList[index].statusLabel ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style:  Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trans No : ",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Text(
                                "${provider.supportRequestList[index].transNo}",
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.only(left: 8.0, top: 12, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Escalation Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(provider
                                      .supportRequestList[index].createdTime ??
                                      DateTime.now()),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ],
                            ),
                            (provider.supportRequestList[index].requestStatusCode == "CLOSED") ?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Closed Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(provider
                                      .supportRequestList[index]
                                      .closedDate ??
                                      DateTime.now()),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ],
                            )
                            :Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Expected Closure Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(provider
                                      .supportRequestList[index]
                                      .expectedClosureDate ??
                                      DateTime.now()),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                              ),
                              Expanded(
                                child: Text(
                                  '${provider.supportRequestList[index].points}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),

                  Visibility(
                    visible: provider.bottomBarStatus == AllObservationAndSupportStatus.closed ,
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
                    visible: provider.bottomBarStatus != AllObservationAndSupportStatus.closed ,
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



                ]),
              ]),
            ),
          ),
        );
      },
    );
  }

}
