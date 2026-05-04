
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/time_progress_widget.dart';
import 'package:interior_design/utils/routes.dart';

class ObservationCard extends StatelessWidget {
  const ObservationCard({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<ProjectDetailsProvider>(
        provider: projectDetailsProvider,
        builder: (context, provider, ref) {
          int imageCount = provider.observationList[index].attachmentJson?.length ?? 0;
          return Card(
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
                    spacing: 4,
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
                          maxWidth: MediaQuery.of(context).size.width*0.6
                        ),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                            userName: userName);
                                      },
                                      child: CachedNetworkImageWidget(
                                        size: 45,
                                      imageUrl:  imageUrl,
                                      userName: (userName == "You") ? (provider.observationList[index].assignedfrom ?? "") : userName,),
                                    );
                                  }
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(provider.observationList[index].assignedfrom == provider.userName
                                          ?"You"
                                          :provider.observationList[index].assignedfrom??'',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold),),

                                      Text(provider.observationList[index].logstatuscode == "ASSIGNED"
                                          ? (provider.observationList[index].assignedto == provider.userName)
                                            ?"Assigned to You"
                                            :'Assigned to ${provider.observationList[index].assignedto}'
                                          : provider.observationList[index].logstatuscode == "SUBMIT"
                                            ? provider.observationList[index].assignedto == provider.userName
                                              ?"Submitted to You"
                                              :'Submitted to ${provider.observationList[index].assignedto}'
                                            : provider.observationList[index].logstatuscode == "REJECTED"
                                          ?'Rejected and reassigned to '
                                            '${provider.observationList[index].assignedto == provider.userName
                                            ?"You"
                                          :provider.observationList[index].assignedto??""}'
                                          : provider.observationList[index].logstatuscode == "CLOSED"
                                            ? (provider.observationList[index].closedby == provider.userName)
                                              ?"Closed by You"
                                              :'Closed by ${provider.observationList[index].closedby}'
                                            :provider.observationList[index].logstatuscode == "UNASSIGNED"
                                              ? "Unassigned"
                                              : "",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w400),)
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Text(
                                  'Trans no :',
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

                            // Date and time
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                 provider.formatDate(provider.observationList[index].createdDateTime??DateTime.now()),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700),),
                          Expanded(
                            child: Text('${provider.observationList[index].points}',
                                style: Theme.of(context).textTheme.titleSmall,

                            softWrap: true,
                            overflow: TextOverflow.ellipsis,),
                          ),
                        ],
                      ),

                      // Bottom row with time and attachments
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time indicator
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: provider.observationList[index].remainingTime != null
                                        ? bayaInfraGreen
                                        : bayaInfraRed,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 4, left: 8, right: 8),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled_outlined,
                                        size: 16,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                                      Text(
                                        '${provider.observationList[index].delayTime}',
                                        style:
                                            Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                      // Attachments
                      Visibility(
                        visible: provider.observationList[index].attachmentJson!.isNotEmpty ? true : false,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).cardColor),
                              elevation: WidgetStatePropertyAll(0)),
                          onPressed: ()  async {
                              if((provider.observationList[index].attachmentJson ?? []).isNotEmpty) {
                                await provider.fetchAttachmentsDetail(
                                  attachmentList: provider.observationList[index]
                                      .attachmentJson ?? [],
                                );

                              if (provider.attachmentUrl.isNotEmpty) {
                                final urls = provider.attachmentUrl.map((e) => e.url).toList().reversed.toList();

                                GoRouter.of(context).pushNamed(
                                  'imageViewer',
                                  extra: {
                                    'images': urls,
                                    'initialIndex': 0,
                                  },
                                );
                              } else {
                                BaseSnackBar().show(message: "No images found");
                              }
                              }
                              else{
                                BaseSnackBar().show(message: "No images found");
                              }
                          },
                          label: Text(
                            "View images ${"($imageCount)"}",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          icon: Icon(
                            Icons.attach_file,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
                  provider.observationList[index].remainingTime == null
                      ? Positioned(
                      top: 16,
                      right: 28,
                           child: BlockIcon())
                      : Positioned(
                          top: 16,
                          right: 28,
                          child: TimeProgressWidget(
                            remainingTime: provider.observationList[index].remainingTime,
                            delayedTime: provider.observationList[index].delayTime,
                          ),

                      ),

                  Positioned(
                      top: -10,
                      right: 0,
                      child: Visibility(
                        visible: false??provider.observationList[index].closingauthorityyn == "Y"
                            && provider.observationList[index].logstatuscode == "UNASSIGNED",
                        child: PopupMenuButton<String>(
                          color: Theme.of(context).cardColor,
                          elevation: 2.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),

                          onSelected: (value) {
                            if(value == "Assign"){

                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Assign',
                              child: Text('Assign',style: Theme.of(context).textTheme.labelLarge,),
                            ),

                          ],
                        ),
                      ),
                  )
              ]
            ),
            )
          );

        });
  }
}
