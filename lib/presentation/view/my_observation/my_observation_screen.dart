import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/my_observation/my_observation_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/pending_closed_icons.dart';
import 'package:interior_design/presentation/view/common/tab_bar.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class MyObservationPage extends ConsumerStatefulWidget {
  const MyObservationPage({super.key});

  @override
  ConsumerState<MyObservationPage> createState() =>
      _MyObservationPageState();
}

class _MyObservationPageState
    extends ConsumerState<MyObservationPage> with RouteAware {

  @override
  void didPopNext() {
    Future.microtask(() async {
      var provider = ref.watch(myObservationProvider);
      provider.fetchObservationList(changeStart: true);
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
    final textTheme = Theme.of(context).textTheme;

    return BaseView<MyObservationProvider>(
        initState: (context, provider, ref) {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.initValues();
          provider.setNavigationParameter(extra);
          provider.setProjectId(projectId: extra!["projectId"] ?? 0);
          provider.fetchObservationList();
          provider.getUserDetails();
          provider.fetchOwners();


          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.pageController.hasClients) {
              provider.pageController.jumpToPage(provider.currentTabIndex);
            }
          });
        },
        virtualFloatingActionButton: BaseStatelessConsumer(
          provider: myObservationProvider,
          builder: (context, provider, ref) {
            return ExpandableFab(
              bottomPadding: (provider.currentTabIndex == 0) ? 0 : 65,
              distance: 70,
            );
          },
        ),



        bottomNavigationBar:(context,provider,ref) {
          return BaseConsumer<MyObservationProvider>(
              provider: myObservationProvider,
              builder: (context, provider, ref){
                return Visibility(
                  visible: provider.currentTabIndex == 0,
                  child: EnumBottomBar<CreatedObservationStatus>(
                    items: CreatedObservationStatus.values,
                    titles: ["Pending", "Submitted", "Closed" ],
                    icons: [Icons.schedule, Icons.check_circle,Icons.download_done],
                    initialIndex: provider.bottomBarStatus == CreatedObservationStatus.pending
                        ? 0
                        : provider.bottomBarStatus == CreatedObservationStatus.closed ? 2 : 1,
                    onTabSelected: (status) {
                      provider.onTapBottomSelected(status);
                    },
                  ),
                );
              }) ;
        },

      provider: myObservationProvider,
      appBar: CustomAppBar(
        title: Text(
          "Observations",
        ),

        action: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color:
                      Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                      border: BoxBorder.all(
                          color: bayaInfraDisabledColor,
                          width: 0.5)),
                  child: IconButton(
                    onPressed: () {
                      BaseBottomSheet.show(
                        context: context,
                        child: bottomFilterForm(context: context),

                      );
                    },
                    icon: Icon(Icons.sort_outlined,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                SizedBox(width: 8,),
                Container(
                  decoration: BoxDecoration(
                      color:
                      Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                      border: BoxBorder.all(
                          color: bayaInfraDisabledColor,
                          width: 0.5)),
                  child: IconButton(
                    onPressed: () {
                      BaseBottomSheet.show(
                        showSlideLine: false,
                        context: context,
                        barrierDismissible: false,
                        enableDrag: false,
                        child: filterFormWidget(),
                      );
                    },
                    icon: Icon(Icons.filter_alt_outlined,
                        color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],

      ),
      builder:(context,provider,ref) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children:
            [Column(
              children: [

                ThemedTabBar(
                  initialIndex: provider.currentTabIndex,
                  onTabSelected: (index) {
                    provider.onTapSelected(index);
                  },
                  icons: [
                    Icons.add_circle_outline, // Created
                    Icons.task_alt, // Action Taken
                  ],
                  labels: [
                    "Created",
                    "Action Taken",
                  ],
                ),
                Expanded(
                  child: PageView(
                    controller: provider.pageController,
                    onPageChanged: (index) => provider.onTapSelected(index),
                    children: [
                      Column(
                        children: [
                          if (provider.observationFetched)
                            Expanded(
                              child: (provider.observationList.isEmpty)
                                  ? RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                onRefresh: () async {
                                  await provider.fetchObservationList();
                                },
                                child: Center(
                                  child: EmptyListView(
                                    emptyText: "There is no created observations",

                                  ),
                                ),
                              )
                                  : RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                onRefresh: () async {
                                  await provider.fetchObservationList();
                                },
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: provider.obsScrollController,
                                  itemCount: provider.observationList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        GoRouter.of(context).pushNamed(
                                          AppRoutes.viewClosedObservationScreen,
                                          extra: {
                                            'observationId':
                                            provider.observationList[index].id,
                                            "isFromProjectDetails": false,
                                            "status" : provider.bottomBarStatus
                                          },
                                        );
                                      },
                                      child: observationCard(context, textTheme, index),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(),
                        ],
                      ),

                      // Same for the second page
                      Column(
                        children: [
                          if (provider.observationFetched)
                            Expanded(
                              child: (provider.observationList.isEmpty)
                                  ? RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                onRefresh: () async {
                                  await provider.fetchObservationList();
                                },
                                child: Center(
                                  child: EmptyListView(
                                    emptyText: "There is no action taken observations",

                                  ),
                                ),
                              )
                                  : RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                onRefresh: () async {
                                  await provider.fetchObservationList();
                                },
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: provider.obsScrollController,
                                  itemCount: provider.observationList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        GoRouter.of(context).pushNamed(
                                          AppRoutes.viewClosedObservationScreen,
                                          extra: {
                                            'observationId':
                                            provider.observationList[index].id,
                                            "isFromProjectDetails": false
                                          },
                                        );
                                      },
                                      child: observationCard(context, textTheme, index),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(),
                        ],
                      ),
                    ],
                  )

                ),

              ],
            ),

        ]
          ),
        );
      }
    );
  }


  Widget observationCard(
      BuildContext context,
      TextTheme textTheme,
      int index) {
    return BaseStatelessConsumer<MyObservationProvider>(
        provider: myObservationProvider,
        builder: (context, provider, ref) {
          int imageCount = provider.observationList[index].attachmentJson?.length ?? 0;
          return Padding(
            padding: (index + 1 == provider.observationList.length) ?  const EdgeInsets.only(bottom: 50.0) : EdgeInsets.zero,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: !provider.isFromProjectDetails,
                                  child: Row(
                                    children: [
                                      Card(
                                        color: Theme
                                            .of(context)
                                            .cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16),
                                          side: BorderSide(
                                              color: bayaInfraDisabledColorDark,
                                              width: 0.5),
                                        ),
                                        elevation: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            'assets/svgs/project_icon.svg',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              provider.observationList[index].projectName ?? "",
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.6,
                                              child: Text(provider.observationList[index].logstatuscode == "ASSIGNED"
                                                  ? (provider.observationList[index].assignedto == provider.userName)
                                                  ?"Assigned to You"
                                                  :'Assigned to ${provider.observationList[index].assignedto}'
                                                  : provider.observationList[index].logstatuscode == "SUBMIT"
                                                  ? provider.observationList[index].assignedto == provider.userName
                                                  ?"Submitted to You"
                                                  :'Submitted to ${provider.observationList[index].assignedto}'
                                                  : provider.observationList[index].logstatuscode == "REJECTED"
                                                  ? 'Rejected and reassigned to '
                                                  '${provider.observationList[index].assignedto == provider.userName
                                                  ?"You"
                                                  :provider.observationList[index].assignedto??""}'

                                                  : provider.observationList[index].logstatuscode == "CLOSED"
                                                  ? (provider.observationList[index].closedby == provider.userName)
                                                  ?"Closed by You"
                                                  :'Closed by ${provider.observationList[index].closedby}'
                                                   : provider.observationList[index].logstatuscode == "UNASSIGNED"
                                                      ? "Unassigned"
                                                   : "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                    fontWeight: FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12,),
                                Row(
                                  children: [
                                    Text(
                                      'Trans no :',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(

                                          fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      provider.observationList[index].transNo ??
                                          "",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall,
                                      overflow: TextOverflow.ellipsis,

                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4,),// Date and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        provider.formatDate(
                          provider.observationList[index].createdDateTime ?? DateTime.now(),
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),


                    ],
                  )

                  ],
                            ),
                          if(provider.observationList[index].observationStatusCode == "CLOSED" || provider.observationList[index].observationStatusCode == "NO_ACTION")
                            Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Closed date : ",
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(provider.observationList[index].observationStatusDate ?? DateTime.now()),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ]
                              ),


                            //Activity Group Section
                            if(provider.observationList[index].activitygroupid != null)
                            Row(
                                children: [
                                  Text('Activity Group: ',
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
                                  Text('Source of Error: ',
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
                                      .titleMedium
                                      ?.copyWith(
                                      fontWeight: FontWeight.w700),),
                                Expanded(
                                  child: Text(provider.observationList[index]
                                      .points ?? "",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall,maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: -10,
                            right: 26,
                            child: Visibility(
                          visible: (provider.observationList[index].attachmentJson ?? []).isNotEmpty,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).cardColor,
                              ),
                              elevation: WidgetStatePropertyAll(0),
                              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                            ),
                            onPressed: () async {
                              await provider.fetchAttachmentsDetail(
                                attachmentList: provider.observationList[index].attachmentJson ?? [],
                              );
                              if (provider.attachmentUrl.isNotEmpty) {
                                final urls = provider.attachmentUrl.map((e) => e.url).toList().reversed.toList();
                                GoRouter.of(context).pushNamed(
                                  'imageViewer',
                                  extra: {'images': urls, 'initialIndex': 0},
                                );
                              } else {
                                BaseSnackBar().show(message: "No images found");
                              }
                            },
                            label: Text(
                              "($imageCount)",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            icon: Icon(
                              Icons.attach_file,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )),

                        provider.observationList[index].logstatuscode== "REJECTED"
                            ? Positioned(
                              top: 53,
                              right: 12.5,
                              child: RejectedBadge(size: BadgeSize.compact),
                              )
                            :badgeWidget(context,index,provider),



                      ]
                  ),
                )
            ),
          );
        }
    );
  }

  Widget badgeWidget(BuildContext context, int index, provider) {
    final item = provider.observationList[index];
    // For Created tab → show delayed only
    if (provider.currentTabIndex == 0 &&
        item.remainingTime == null &&
        item.observationStatusCode == "PENDING" &&
        item.observerName == provider.userName) {
      return Positioned(
        top: 55,
        right: 12.5,
        child: DelayedBadge(size: BadgeSize.compact),
      );
    }

    switch (item.observationStatusCode) {
        case "PENDING":
          return Positioned(
            top: 53,
            right: 12.5,
            child: OpenBadge(size: BadgeSize.compact),
          );
        case "NO_ACTION":
          return Positioned(
            top: 53,
            right: 12.5,
            child: NoActionBadge(size: BadgeSize.compact),
          );
        default:
          return Positioned(
            top: 53,
            right: 12.5,
            child: ClosedBadge(size: BadgeSize.compact),
          );

    }


  }

}


bottomFilterForm({required BuildContext context}){
  return BaseConsumer(
      provider: myObservationProvider,
      builder: (context, provider, ref){
        return SingleChildScrollView(
          child: Column(
            children: [
              DateRangeTile(
                label: "Last Week",
                selectedRange: provider.selectedObsRangeLabel,
                onTap: () {
                  provider.clearObservationFilter(isFromClearButton: true);
                  if(provider.selectedObsRangeLabel == "Last Week"){
                    provider.setObsRangeFilterApplied(false);
                    provider.fetchObservationList(changeStart: true);
                    GoRouter.of(context).pop();
                  }
                  else {
                    provider.setLastWeek();
                    GoRouter.of(context).pop(context);
                  }
                },
              ),
              DateRangeTile(
                label: "This Week",
                selectedRange: provider.selectedObsRangeLabel,
                onTap: () {
                  provider.clearObservationFilter(isFromClearButton: true);
                  if(provider.selectedObsRangeLabel == "This Week") {
                    provider.setObsRangeFilterApplied(false);
                    provider.fetchObservationList(changeStart: true);
                    GoRouter.of(context).pop();
                  }
                  else{
                    provider.setThisWeek();
                    GoRouter.of(context).pop(context);
                  }
                },
              ),
              DateRangeTile(
                label: "Last Month",
                selectedRange: provider.selectedObsRangeLabel,
                onTap: () {
                  provider.clearObservationFilter(isFromClearButton: true);
                  if(provider.selectedObsRangeLabel == "Last Month"){
                    provider.setObsRangeFilterApplied(false);
                    provider.fetchObservationList(changeStart: true);
                    GoRouter.of(context).pop();
                  }
                  else {
                    provider.setLastMonth();
                    GoRouter.of(context).pop(context);
                  }
                },
              ),
              DateRangeTile(
                label: "This Month",
                selectedRange: provider.selectedObsRangeLabel,
                onTap: () {
                  provider.clearObservationFilter(isFromClearButton: true);
                  if(provider.selectedObsRangeLabel == "This Month"){
                    provider.setObsRangeFilterApplied(false);
                    provider.fetchObservationList(changeStart: true);
                    GoRouter.of(context).pop();
                  }
                  else{
                    provider.setThisMonth();
                    GoRouter.of(context).pop(context);
                  }

                },
              ),
            ],
          ),
        );

  });

}

filterFormWidget() {
  final DateTime now = DateTime.now();
  final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
  return BaseStatelessConsumer(
      provider: myObservationProvider,
      builder: (context, provider, ref){
        return SingleChildScrollView(
          child: Form(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8),
                child: Column(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Center(
                              child: Text(
                                "Filter",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          onPressed: () {
                            GoRouter.of(context).pop();
                            provider.clearObservationFilter(isFromClearButton: false);
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    GestureDetector(
                      onTap: (){
                        showUserListDialog(
                            title: "Observer",
                            context,
                            userList: provider.owners,
                            // names: provider.namesFromOwnerModel,
                            onForward: (value){
                              provider.setSelectedOwner(value);
                              GoRouter.of(context).pop();
                            });
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          validator: (val){
                            return (provider.selectedOwner == null) ? "Please select observer" : null;
                          },
                          controller: provider.obsOwnerController,
                          style: Theme.of(context).textTheme.titleSmall,
                          decoration:  InputDecoration(
                            suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                            // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                            hintText: "Observer",
                            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontWeight: FontWeight.w400,
                            ),
                            labelStyle: Theme.of(context).textTheme.titleMedium,
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.54,),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.54,
                                    color: Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(10)),
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 0.54, color: bayaInfraRedColor),
                                borderRadius: BorderRadius.circular(10)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 0.54, color: bayaInfraRedColor),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.54,
                                    color: provider.owners.isEmpty
                                        ? Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.5)
                                        : Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(10)),
                          ),

                          onTap: (){
                          },

                        ),
                      ),
                    ),
                    BaseTextField(
                      controller: provider.filterPointsController,
                      displayTitle: "Points",
                    ),
                    BaseTextField(
                      controller: provider.filterTransNoController,
                      displayTitle: "Trans no.",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text("Show all observations",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                        Switch(
                          activeColor: Theme.of(context).primaryColor,
                          value: (provider.tempIsShowAllObs) ??  provider.isShowAllObs,
                          onChanged: (val) {
                            provider.changeIsShowAllObs(val);
                          },
                        ),
                      ],
                    ),
                    Visibility(
                        visible: (provider.tempIsShowAllObs != null) ? !provider.tempIsShowAllObs! : !provider.isShowAllObs,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Created date",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500,
                                    color: Theme.of(context).textTheme.titleLarge?.color),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: BaseDatesPicker(
                                    onChange: (date) {
                                      provider.changeObsDateFrom(date);
                                    },
                                    lastDate: provider.tempObsDateTo ?? provider.obsDateTo,
                                    initialDate: provider.tempObsDateFrom ?? provider.obsDateFrom,
                                    subtitle: 'Date from',
                                  ),
                                ),
                                Expanded(
                                  child: BaseDatesPicker(
                                    onChange: (date) {
                                      provider.changeObsDateTo(date);
                                    },
                                    firstDate: provider.tempObsDateFrom ?? provider.obsDateFrom,
                                    initialDate: provider.tempObsDateTo ?? provider.obsDateTo,
                                    subtitle: 'Date to',
                                    lastDate: twoYearsLater,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: BaseElevatedButton(
                                onPressed: () {
                                  provider.clearObservationFilter(isFromClearButton: true);
                                },
                                text: 'Clear',
                                height: 40,
                                backgroundColor: bayaInfraDisabledColor,
                              )),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                              child: BaseElevatedButton(
                                height: 40,
                                onPressed: () {
                                  provider.setIsShowAllObs();
                                  provider.setObsRangeFilterApplied(false);
                                  provider.setObsFilterDateField();
                                  GoRouter.of(context).pop();
                                  provider.fetchObservationList(changeStart: true);

                                },
                                text: 'Apply',
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        );
      }
  );
}

class DelayIcon extends StatelessWidget {
  const DelayIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.block_flipped,
      color: bayaInfraRed,
      size: 25,
    );
  }
}
