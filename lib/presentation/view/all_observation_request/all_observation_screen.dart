import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/all_observation_support_request/all_observation_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:intl/intl.dart';

class AllObservationListWidget extends StatelessWidget {
  const AllObservationListWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<AllObservationRequestProvider>(
        provider: allObservationRequestProvider,
        builder: (context, provider, ref) {

          return Stack(
              fit: StackFit.expand,
            children:
            [
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: RefreshIndicator(
                    color:Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).highlightColor,
                    onRefresh: () async {
                      await provider.onRefreshObsAction();
                    },
                    child:(provider.observationFetched) ? (provider.observationList.isEmpty)
                        ? EmptyListView(
                      emptyText: "There are no ${provider.bottomBarStatus == AllObservationAndSupportStatus.opened ? "opened" : provider.bottomBarStatus == AllObservationAndSupportStatus.delayed ? "delayed" : "closed" } ${provider.isFromDashboard ? "observations for this user" : "observations in this project yet" } ",
                    )
                        : ListView.builder(
                      controller: provider.observationScrollController,
                      itemCount: provider.observationList.length,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            int observationId =
                                provider.observationList[index].id ?? 0;
                            GoRouter.of(context).pushNamed(
                              'closeObservation',
                              extra: {'observationId': observationId,
                                "projectId":provider.projectId},
                            );
                          },
                          child: observationCard(index: index),
                        );
                      },
                    ) : Container(),
                  ),
                ),


              ],
            ),

          ]
          );
        });
  }

  Widget observationCard ({required int index}) {
    return BaseStatelessConsumer<AllObservationRequestProvider>(
        provider: allObservationRequestProvider,
        builder: (context, provider, ref) {
          int imageCount = provider.observationList[index].attachmentJson
              ?.length ?? 0;
          return Padding(
            padding: (index + 1 == provider.observationList.length ) ? EdgeInsets.only(bottom: 50,right: 4,left: 4) : EdgeInsets.only(right: 4,left: 4) ,
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
                  padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8),
                  child: Stack(
                      children: [
                        Column(
                          spacing: 6,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: provider.observationList[index].refoptionname != null
                                  && provider.observationList[index].refoptionname!.isNotEmpty,
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
                                        Text("Against ${provider.observationList[index].refoptionname}",style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontStyle: FontStyle.italic
                                        ),)

                                      ],
                                    )
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.6
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 4,
                                    children: [

                                        Builder(
                                          builder: (context) {
                                            String userName = provider.observationList[index].assignedfrom == provider.userName
                                                ?"You"
                                                :provider.observationList[index].assignedfrom??'';

                                            String imageUrl = provider.observationList[index].assignedfromprofileurl??'';
                                            return GestureDetector(
                                              onTap: () {
                                                ProfileImageDialog.show(context: context,
                                                  imageUrl: imageUrl,
                                                  userName:   userName,);

                                              },
                                              child: CachedNetworkImageWidget(
                                                padding: EdgeInsets.zero,
                                              imageUrl: imageUrl,
                                                size: 45,
                                                userName: provider.observationList[index].assignedfrom ?? "",
                                              ),
                                            );
                                          }
                                        ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            provider.observationList[index].observationStatusCode == "CLOSED"
                                                ? Text(
                                                '${(provider.observationList[index]
                                                    .closedby == provider.userName) ? "You" :
                                                provider.observationList[index].closedby}',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold))
                                                : Text(provider.observationList[index].assignedfrom == provider.userName
                                                    ?"You"
                                                  :provider.observationList[index].assignedfrom??'',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold)),

                                            Text(provider.observationList[index].statusLabel ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w400)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12,),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Trans No :',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            ' ${provider.observationList[index].transNo}',
                                            style: Theme.of(context).textTheme.titleSmall,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4,),
                                  // Date and time
                                  Row(
                                    children: [
                                      Text(
                                        provider.formatDate(
                                            provider.observationList[index]
                                                .createdDateTime ?? DateTime.now()),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //Activity Group Section
                            if(provider.observationList[index].activitygroupid != null)
                            Row(
                                children: [
                                  Text('Activity Group  : ',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700),),
                                  Expanded(
                                    child: Text('${provider.observationList[index]
                                        .activitygroup}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall, maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,),
                                  ),
                                ],
                              ),


                            //Source of Error  Section
                            if(provider.observationList[index].sourceoferrorid != null)
                            Row(
                                children: [
                                  Text('Source of Error : ',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700),),
                                  Expanded(
                                    child: Text('${provider.observationList[index]
                                        .sourceoferror}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall, maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,),
                                  ),
                                ],
                              ),

                            // Points section
                            Row(
                              children: [
                                Text('Points     : ',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),),
                                Expanded(
                                  child: Text('${provider.observationList[index]
                                      .points}',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall, maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),

                          ],
                        ),

                        Visibility(
                          visible: provider.observationList[index]
                              .attachmentJson!.isNotEmpty ? true : false,
                          child: Positioned(
                            top: -10,
                            right: 26,
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Theme
                                          .of(context)
                                          .cardColor),
                                  elevation: WidgetStatePropertyAll(0)),
                              onPressed: () async {
                                if ((provider.observationList[index]
                                    .attachmentJson ?? []).isNotEmpty) {
                                  await provider.fetchAttachmentsDetail(
                                    attachmentList: provider
                                        .observationList[index]
                                        .attachmentJson ?? [],
                                  );

                                  if (provider.attachmentUrl.isNotEmpty) {
                                    final urls = provider.attachmentUrl
                                        .map((e) => e.url)
                                        .toList()
                                        .reversed
                                        .toList();

                                    GoRouter.of(context).pushNamed(
                                      'imageViewer',
                                      extra: {
                                        'images': urls,
                                        'initialIndex': 0,
                                      },
                                    );
                                  } else {
                                    BaseSnackBar().show(
                                        message: "No images found");
                                  }
                                }
                                else {
                                  BaseSnackBar().show(
                                      message: "No images found");
                                }
                              },
                              label: Text(
                                "($imageCount)",
                                overflow: TextOverflow.ellipsis,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .labelLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              icon: Icon(
                                Icons.attach_file,
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                              ),
                            ),
                          ),
                        ),

                        Visibility(
                          visible:provider.observationList[index].observationStatusCode == "CLOSED" || provider.observationList[index].observationStatusCode == "NO_ACTION",
                          child: Positioned(
                            top: 40,
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
                            visible: provider.observationList[index].observationStatusCode == "CLOSED" || provider.observationList[index].observationStatusCode == "NO_ACTION",
                            child: Positioned(
                              top: 82,
                              right: 12.5,
                              child: Column(
                                children: [
                                  Text("Closed Date",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700),),
                                  Text(DateFormat('MMM dd, yyyy').format(provider
                                      .observationList[index]
                                      .observationStatusDate ??
                                      DateTime.now()),
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall,)
                                ],
                              ),
                            )),

                        Visibility(
                          visible: provider.bottomBarStatus != AllObservationAndSupportStatus.closed,
                          child: Positioned(
                            top: 60,
                            right: 12.5,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: provider.observationList[index]
                                          .remainingTime != null
                                          ? bayaInfraGreen
                                          : bayaInfraRed,
                                      borderRadius: BorderRadius.circular(
                                          12)),
                                  child: Padding(
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
                                          '${provider.observationList[index]
                                              .delayTime}',
                                          style:
                                          Theme
                                              .of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      ]
                  ),
                )
            ),
          );
        });
  }

}
