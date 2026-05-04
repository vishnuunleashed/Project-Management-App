/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    : Selection Tab section
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/time_progress_widget.dart';
import 'package:intl/intl.dart';

class SupportRequestCard extends StatelessWidget {
  const SupportRequestCard({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
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
    return BaseStatelessConsumer<ProjectDetailsProvider>(
      provider: projectDetailsProvider,
      builder: (context, provider, ref) {
        // print("Index $index -> ${provider.supportRequestList[index].profileUrl}");

        int calculateTotalDays({
          required DateTime escalationDate,
          required DateTime expectedClosureDate,
        }) {
          return expectedClosureDate.difference(escalationDate).inDays;
        }


        String capitalizeFirstLetter(String text) {
          if (text.isEmpty) return "";
          if(text == "FORWARD") {
            return text[0].toUpperCase() + text.substring(1).toLowerCase() + 'ed';
          }
          else if(text == "SUBMIT") {
            return text[0].toUpperCase() + text.substring(1).toLowerCase() + 'ted';
          }
          else {
            return text[0].toUpperCase() + text.substring(1).toLowerCase();
          }

        }

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
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 4, right: 4),
            child: Column(
              children:
                  [
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
                    Visibility(
                      visible: provider.supportRequestList[index].logStatusCode == "FORWARD" || provider.supportRequestList[index].logStatusCode == "REASSIGNED",
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child:
                        Container(
                          decoration: BoxDecoration(
                          ),
                          child:
                          provider.supportRequestList[index].logStatusCode == "FORWARD" ?Row(
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
                                    imageUrl:provider.supportRequestList[index].logFromUserProfileUrl ?? "",
                                    userName:  provider.supportRequestList[index].logFromUser ?? "User",);

                          },
                          child: CachedNetworkImageWidget(
                                     imageUrl: provider.supportRequestList[index].logFromUserProfileUrl ?? "",
                            isCircleEnabled: provider
                                .supportRequestList[index].iscriticalyn == "Y",
                            circleColor: Colors.red,
                            size: 45,
                            userName: provider.supportRequestList[index].logFromUser ?? "",
                          ),),
                          SizedBox(width: 4,),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  '${provider.supportRequestList[index].logFromUser}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                     (provider.supportRequestList[index].logStatusCode == "SUBMIT")
                                                ? "Request for closure"
                                                : (provider.supportRequestList[index].requestStatusCode != "CLOSED")
                                                ? (provider.supportRequestList[index].logToUser == provider.userName)
                                                ? provider.supportRequestList[index].logStatusCode == "ASSIGNED"
                                                ? "Assigned to you"
                                                : provider.supportRequestList[index].logStatusCode == "SUBMIT"
                                                ? "Submitted to you"
                                                : (provider.supportRequestList[index].logStatusCode == "FORWARD")
                                                ? "Forwarded to you"
                                                : "Reassigned to you"
                                                : provider.supportRequestList[index].logStatusCode == "CANCELLED"
                                                ? 'Cancelled by ${provider.supportRequestList[index].logFromUser}'
                                                :provider.supportRequestList[index].logStatusCode == "ASSIGNED"
                                                ? 'Assigned to ${provider.supportRequestList[index].logToUser}'
                                                : (provider.supportRequestList[index].logStatusCode == "SUBMIT")
                                                ? "Submitted to ${provider.supportRequestList[index].logToUser}"
                                                : (provider.supportRequestList[index].logStatusCode == "FORWARD")
                                                ? "Forwarded to ${provider.supportRequestList[index].logToUser}"
                                                :"Reassigned to ${provider.supportRequestList[index].logToUser}"
                                                : "Closed by ${(provider.supportRequestList[index].closedBy == provider.userName) ? 'You'
                                                : "${provider.supportRequestList[index].closedBy}"}",
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
                              "${provider.supportRequestList[index].transNo}",
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
                              formatDate(provider.supportRequestList[index].createdTime),
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
                              DateFormat('MMM dd, yyyy').format(provider
                                  .supportRequestList[index]
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
                                '${provider.supportRequestList[index].points}',
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
                  provider.supportRequestList[index].remainingTime == null
                      ? Positioned(
                      top: 4,
                      right: 32,
                          child: BlockIcon())
                      : Positioned(
                        top: 4,
                        right: 32,
                          child: TimeProgressWidget(
                          remainingTime: provider.supportRequestList[index].remainingTime,
                          delayedTime: '30 days',
                            totalDays: calculateTotalDays(escalationDate: provider.supportRequestList[index].transDate ?? DateTime.now(),
                                expectedClosureDate: provider.supportRequestList[index].expectedClosureDate ?? DateTime.now()),
                        ),

                  )
              ]
              ),
          ]
            ),
          ),
        );
      },
    );
  }
}
