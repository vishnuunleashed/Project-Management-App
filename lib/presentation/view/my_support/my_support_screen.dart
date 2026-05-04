import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/my_observation/my_observation_provider.dart';
import 'package:interior_design/presentation/provider/my_support/my_support_provider.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/follow_button.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/pending_closed_icons.dart';
import 'package:interior_design/presentation/view/common/tab_bar.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_details/partials/time_progress_widget.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';


class MySupportRequestScreen extends ConsumerStatefulWidget {
  const MySupportRequestScreen({super.key});

  @override
  ConsumerState<MySupportRequestScreen> createState() => _MySupportRequestScreenState();
}

class _MySupportRequestScreenState extends ConsumerState<MySupportRequestScreen> with RouteAware {

  @override
  void didPopNext()  {
    Future.microtask(() async {
      // final provider = ref.watch(mySupportProvider);
      // provider.fetchSupportRequestList();
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

    return BaseView<MySupportProvider>(
      initState: (context,provider,ref){
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValue();

        provider.setProjectId(projectId: extra!["projectId"] ?? 0,);
        provider.fetchSupportRequestList();
        provider.getUserDetails();
        provider.fetchOwners();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.pageController.hasClients) {
            provider.pageController.jumpToPage(provider.currentTabIndex);
          }
        });
      },
      bottomNavigationBar:(context,provider,ref)=> Visibility(
        visible: provider.currentTabIndex == 0,
        child: EnumBottomBar<Status>(
          items: Status.values,
          titles: ["Pending", "Ready to Close", "Closed"],
          icons: [Icons.schedule, Icons.assignment_turned_in, Icons.check_circle],
          initialIndex: provider.bottomBarStatus == Status.pending
              ? 0
              : provider.bottomBarStatus == Status.readyToClose
              ? 1
              : 2,
          onTabSelected: (status) {
            provider.onTapBottomSelected(status);
          },
        ),
      ),
      virtualFloatingActionButton: BaseStatelessConsumer(
        provider: mySupportProvider,
        builder: (context, provider, ref) {
          final _homeProvider = ref.watch(homeProvider);
          return ExpandableFab(
            bottomPadding: provider.currentTabIndex == 0 ? 0 : 65,
            distance: 70,
          );
        },
      ),
      provider: mySupportProvider,
      appBar: CustomAppBar(
        title: Text(
          "Support Requests",

        ),
        action: [
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
                    child: bottomFilterForm(context: context )
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
                    child: filterFormWidget()
                );
              },
              icon: Icon(Icons.filter_alt_outlined,
                  color: Theme.of(context).colorScheme.primary
              ),
            ),
          ),
        ],

      ),
      builder:(context,provider,ref){
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
              children:[ Column(
                children: [

                  ThemedTabBar(
                    initialIndex: provider.currentTabIndex,
                    onTabSelected: (index){
                      provider.onTapSelected(index);
                    },
                    icons: [
                      Icons.add_circle_outline, // Created
                      Icons.task_alt,           // Action Taken
                    ],
                    labels: [
                      "Created",
                      "Responded",
                    ],
                  ),

                  // Observation Items
                  Expanded(
                    child: PageView(
                      controller: provider.pageController,
                      onPageChanged: (index) => provider.onTapSelected(index),
                      children: [
                        Column(
                          children: [
                            (provider.supRequestFetched) ?
                            Expanded(
                              child: (provider.supportRequestList.isEmpty) ?
                              RefreshIndicator(
                                  color:Theme.of(context).primaryColor,
                                  backgroundColor: Theme.of(context).highlightColor,
                                  child: Center(

                                    child: EmptyListView(
                                        emptyText: "There is no created support requests",
                                    ),
                                  ), onRefresh: () async {
                                await provider.fetchSupportRequestList();
                              }) :
                              RefreshIndicator(
                                color:Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                onRefresh: () async {
                                  await provider.fetchSupportRequestList();
                                },
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: provider.supScrollController,
                                  itemCount: provider.supportRequestList.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            int supportRequestId = provider.supportRequestList[index].id ?? 0;
                                            Status status = provider.bottomBarStatus;
                                            GoRouter.of(context).pushNamed(AppRoutes.viewSupportRequestScreen,
                                                extra: {'supportRequestId': supportRequestId ,'status' : status});
                                          },
                                          child: supportCard(context,provider,textTheme,index),
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
                                            isCC:  (provider
                                                .supportRequestList[index].notifyuseryn == "Y"
                                                &&  provider.supportRequestList[index].addedbycreatoryn == "Y"),
                                            onFollow: () {
                                              int supportRequestId = provider
                                                  .supportRequestList[index].id ??
                                                  0;
                                              provider.followSupportRequest(
                                                  supportId: supportRequestId,
                                                  onRequestSuccess: (){
                                                    provider.updateSupportListForFollow(index);
                                                  }
                                              );

                                            },
                                            onUnfollow: (){
                                              int supportRequestId = provider
                                                  .supportRequestList[index].id ??
                                                  0;
                                              provider.unFollowSupportRequest(
                                                  supportId: supportRequestId,
                                                  onRequestSuccess: (){
                                                    provider.updateSupportListForUnFollow(index);
                                                  });

                                            },

                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),) :
                            Container()

                          ],
                        ),

                        Column(
                          children: [
                            (provider.supRequestFetched) ?
                            Expanded(child: (provider.supportRequestList.isEmpty) ?
                            RefreshIndicator(
                                color:Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).highlightColor,
                                child: Center(

                                  child: EmptyListView(
                                      emptyText: "There is no action taken support requests",
                                  ),
                                ), onRefresh: () async {
                              await provider.fetchSupportRequestList();
                            }) :

                            RefreshIndicator(
                              color:Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context).highlightColor,
                              onRefresh: () async {
                                await provider.fetchSupportRequestList();
                              },
                              child: ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: provider.supportRequestList.length,
                                controller: provider.supScrollController,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          int supportRequestId = provider.supportRequestList[index].id ?? 0;
                                          Status status = Status.closed;
                                          GoRouter.of(context).pushNamed(AppRoutes.viewSupportRequestScreen, extra: {'supportRequestId': supportRequestId, 'status' : status});
                                        },
                                        child: supportCard(context,provider,textTheme,index),
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
                                          isCC:  (provider
                                              .supportRequestList[index].notifyuseryn == "Y"
                                              &&  provider.supportRequestList[index].addedbycreatoryn == "Y"),
                                          onFollow: () {
                                            int supportRequestId = provider
                                                .supportRequestList[index].id ??
                                                0;
                                            provider.followSupportRequest(supportId: supportRequestId,
                                                onRequestSuccess: (){
                                                  provider.updateSupportListForFollow(index);
                                                }
                                            );

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
                              ),
                            ),) :
                            Container(),




                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),



              ]
          ),
        );
      }
    );
  }

  Widget supportCard(
      BuildContext context,
      MySupportProvider provider,
      TextTheme textTheme,
      int index) {
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
    return Padding(
      padding: (index + 1 == provider.supportRequestList.length) ? const EdgeInsets.only(bottom: 50.0) : EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: bayaInfraDisabledColor, width: 0.5),
        ),
        elevation: 0,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 8.0, bottom: 8.0, left: 0, right: 4),
          child: Stack(
              children: [Column(
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

                  Visibility(
                    visible: !provider.isFromProjectDetails,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              bool isCircleEnabled = provider.supportRequestList[index].iscriticalyn == "Y";
                              return Card(
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isCircleEnabled ? bayaInfraLightRedColor : bayaInfraDisabledColorDark,
                                    width: isCircleEnabled ? 2.0 : 0.5,
                                  ),
                                ),
                                elevation: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(isCircleEnabled ? 10.0 : 8.0),
                                  child: SvgPicture.asset(
                                    'assets/svgs/project_icon.svg',
                                  ),
                                ),
                              );
                            }
                          ),
                          SizedBox(width: 4,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.42,
                                child: Text(
                                  provider.supportRequestList[index].projectName ?? "",
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                               SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child:
                                  Text(
                                    (provider.supportRequestList[index].logStatusCode == "SUBMIT" && provider.currentTabIndex != 1)
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
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),



                  Padding(
                    padding: const EdgeInsets.only(left: 8.0,top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Trans No : ",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Text(
                            provider.supportRequestList[index].transNo ?? "",
                            overflow: TextOverflow.ellipsis,
                            style:  Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escalation Date',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(provider.supportRequestList[index].createdTime),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        provider.supportRequestList[index].requestStatusCode == "CLOSED" ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Closed Date',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(provider.supportRequestList[index].closedDate ?? DateTime.now()),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        )
                         : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Expected Closure Date',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(provider.supportRequestList[index].expectedClosureDate ?? DateTime.now()),
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Expanded(
                            child: Text(
                              provider.supportRequestList[index].points ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

                provider.supportRequestList[index].remainingTime == null
                    && provider.supportRequestList[index].requestStatusCode == "PENDING"
                    && provider.supportRequestList[index].escalatedBy == provider.userName &&  provider.currentTabIndex == 0
                    ? Positioned(
                    top: 53,
                    right: 12.5,
                    child: DelayedBadge(
                      size: BadgeSize.compact,
                    ))
                    : provider.supportRequestList[index].requestStatusCode != "CLOSED"  && provider.currentTabIndex == 0 ?
                Positioned(
                    top: 53,
                    right: 12.5,
                    child: OpenBadge(
                      size: BadgeSize.compact,
                    )) : provider.supportRequestList[index].requestStatusCode == "CLOSED"  && provider.currentTabIndex == 0 ?
                    Positioned(
                        top: 53,
                        right: 12.5,
                        child: ClosedBadge(
                          size: BadgeSize.compact,
                        )) :
                Container(),
                provider.currentTabIndex == 1 ?
                provider.supportRequestList[index].requestStatusCode == 'PENDING' && provider.currentTabIndex == 1
                    ? Positioned(
                    top: 53,
                    right: 12.5,
                    child: WIPBadge(
                      size: BadgeSize.compact,))


                    :  provider.supportRequestList[index].requestStatusCode == 'CLOSED' ?
                Positioned(
                    top: 53,
                    right: 12.5,
                  child: ClosedBadge(size: BadgeSize.compact,)
                )
                    : provider.supportRequestList[index].requestStatusCode == 'CANCELLED' ?
                Positioned(
                    top: 53,
                    right: 12.5,
                    child: CancelledBadge(size: BadgeSize.compact,)
                ):
                Positioned(
                  top: 40,
                  right: 12.5,

                  child: ReadyToCloseBadge(
                    size: BadgeSize.compact,),
                ) :
                    Container(),
              ]
          ),
        ),
      ),
    );
  }
}

//Filter
Widget filterFormWidget() {
  final DateTime now = DateTime.now();
  final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
  return BaseStatelessConsumer<MySupportProvider>(
      provider: mySupportProvider,
      builder: (context, provider, ref) {
        return SingleChildScrollView(
            child: Form(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0,right: 8.0,left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ?.copyWith(),
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
                              provider.clearSupportReqFilter(isFromClearButton: false);
                            },
                          ),
                        ],
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          showUserListDialog(
                              title: "Escalated user",
                              context,
                              userList: provider.owners,
                              // names: provider.namesFromOwnerModel,
                              onForward: (value){
                                provider.setSelectedEscalated(value);
                                GoRouter.of(context).pop();
                              });
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            validator: (val){
                              return (provider.selectedEscalatedUser == null) ? "Please select user" : null;
                            },
                            controller: provider.supportOwnerController,
                            style: Theme.of(context).textTheme.titleSmall,
                            decoration:  InputDecoration(
                              suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                              // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                              hintText: "User",
                              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).disabledColor,
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
                        controller: provider.filterSupportPointsController,
                        displayTitle: "Points",
                      ),

                     BaseDropDownButtonFormField<DepartmentDropDownModel>(
                          iconEnabledColor: Theme.of(context).colorScheme.primary,
                          fillColorNeeded: false,
                          label: "Department",
                          labelColor: Theme.of(context).textTheme.titleLarge?.color,
                          hintText: "Select department",
                          initialValue: provider.tempSelectedDept ?? provider.selectedDept,
                          items: provider.departmentList,
                          onChanged: (value) {
                            provider.changeDepartment(value!);
                          },
                          builder: (value) {
                            return Text(value.deptName ?? "");
                          },
                        ),

                      SizedBox(
                        height: 8,
                      ),

                      BaseDropDownButtonFormField<DepartmentDropDownModel>(
                        iconEnabledColor: Theme.of(context).colorScheme.primary,
                        fillColorNeeded: false,
                        label: "Dependency Department",
                        labelColor: Theme.of(context).textTheme.titleLarge?.color,
                        hintText: "Select dependency department",
                        initialValue: provider.tempSelectedDependencyDept ?? provider.selectedDependencyDept,
                        items: provider.departmentList,
                        onChanged: (value) {
                          provider.changeDependencyDepartment(value!);
                        },
                        builder: (value) {
                          return Text(value.deptName ?? "");
                        },
                      ),

                      SizedBox(
                        height: 8,
                      ),
                      // Visibility(
                      //   visible: (provider.superUserYN) ? true : false,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 4.0,right: 4.0),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Text("Your support requests only",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      //             fontWeight: FontWeight.w500
                      //         ),),
                      //         Switch(
                      //           activeColor: bayaInfraAppPrimary,
                      //           value: provider.isSuperUserSupportOnly,
                      //           onChanged: (val) {
                      //             provider.changeIsSuperuserSupportOnly(val);
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0,right: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Show all support requests",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            ),),
                            Switch(
                              activeColor: Theme.of(context).primaryColor,
                              value: provider.tempIsShowAllSupport ?? provider.isShowAllSupport,
                              onChanged: (val) {
                                provider.changeIsShowAllSupport(val);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0,right: 4),
                        child: Visibility(
                          visible:(provider.tempIsShowAllSupport != null) ? !provider.tempIsShowAllSupport! : !provider.isShowAllSupport,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                (provider.bottomBarStatus == Status.closed && provider.currentTabIndex == 0) ? "Closed date" :"Expected closure date",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: BaseDatesPicker(
                                      onChange: (date) {
                                        provider.changeClosureDateFrom(date);
                                      },
                                      initialDate: provider.tempClosureDateFrom ?? provider.closureDateFrom,
                                      lastDate: provider.tempClosureDateTo ?? provider.closureDateTo,
                                      subtitle: "Date from",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: BaseDatesPicker(
                                      onChange: (date) {
                                        provider.changeClosureDateTo(date);
                                      },
                                      initialDate: provider.tempClosureDateTo ?? provider.closureDateTo,
                                      firstDate: provider.tempClosureDateFrom ?? provider.closureDateFrom ,
                                      lastDate: twoYearsLater,
                                      subtitle: "Date to",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: BaseElevatedButton(
                                  onPressed: () {
                                    provider.setSptRangeFilterApplied(false);
                                    provider.clearSupportReqFilter(isFromClearButton: true);
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
                                    GoRouter.of(context).pop();
                                    provider.setSptRangeFilterApplied(false);
                                    provider.setIsShowAllSupport();
                                    provider.setSelectedDepartment();
                                    provider.setSelectedDependencyDepartment();
                                    provider.setSptFilterDateField();
                                    provider.fetchSupportRequestList(changeStart: true);
                                  },
                                  text: 'Apply',
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ))
        );
      });
}

//Date range filter
Widget bottomFilterForm({required BuildContext context}){
  return BaseConsumer<MySupportProvider>(
    provider: mySupportProvider,
    builder: (context,provider,ref){
    return SingleChildScrollView(
      child: Column(
        children: [
          DateRangeTile(
            label: "Last Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Last Week"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setLastWeek(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "This Week"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setThisWeek();
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Next Week",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Next Week"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setNextWeek(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Last Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Last Month"){
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setLastMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "This Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "This Month"){
                print("If case worked");
                provider.clearSupportReqFilter(isFromClearButton: true);
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                print("Else case worked");
                provider.setThisMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),
          DateRangeTile(
            label: "Next Month",
            selectedRange: provider.selectedSptRangeLabel,
            onTap: () {
              provider.clearSupportReqFilter(isFromClearButton: true);
              if(provider.selectedSptRangeLabel == "Next Month"){
                provider.setSptRangeFilterApplied(false);
                provider.fetchSupportRequestList();
                GoRouter.of(context).pop();
              }
              else {
                provider.setNextMonth(isSupport: true);
                GoRouter.of(context).pop(context);
              }
            },
          ),

        ],
      ),
    );
  }, );

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
