import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_bottom_sheet.dart';
import 'package:base/presentation/utility/base_date_picker.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/pending_closed_icons.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:intl/intl.dart';

class TaskAgainstSupportListPage extends ConsumerWidget {
  const TaskAgainstSupportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(projectScheduleProvider);
    return BaseView<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      initState: (context, provider, ref) {
        provider.taskAgainstSupportInitValues();
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.setTaskAgainstSupportParameter(extra);
        provider.getUserDetails();
      },
      dispose: (context) {},
      appBar: CustomAppBar(
        title: Text(provider.isFromAdditionalMaterial
            ? "Addn'l Based Support"
            : "Task Based Support"),
        action: [
          IconButton(
            onPressed: () {
              BaseBottomSheet.show(
                showSlideLine: false,
                barrierDismissible: false,
                enableDrag: false,
                context: context,
                child: filterFormWidget(),
              );
            },
            icon: Icon(
              Icons.filter_alt_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      builder: (context, provider, ref) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).highlightColor,
                  onRefresh: () async {
                    provider.fetchTaskAgainstSupportList(changeStart: true);
                  },
                  child: (provider.itemAgainstSupportRequestList.isEmpty &&
                          provider.taskSupportFetched)
                      ? EmptyListView(
                          emptyText: provider.isFromAdditionalMaterial
                              ? "There are no pending support requests against this additional material yet"
                              : "There are no pending support requests against this task yet",

                        )
                      : ListView.builder(
                          controller: provider.taskAgainstSupportController,
                          itemCount:
                              provider.itemAgainstSupportRequestList.length,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  // TO pass Support request id
                                  int taskAgainstSupportRequestId = provider
                                          .itemAgainstSupportRequestList[index]
                                          .id ??
                                      0;
                                  GoRouter.of(context).pushNamed(
                                      'closeSupportRequestDirect',
                                      extra: {
                                        'supportRequestId':
                                            taskAgainstSupportRequestId
                                      });
                                },
                                child: Column(
                                  children: [
                                    SupportRequestCard(
                                      index: index,
                                    ),
                                    // Visibility(
                                    //     visible: (provider.taskAgainstSupportRequestList.length - 1) == index ,
                                    //     child: SizedBox(height: 50, ))
                                  ],
                                ));
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

    return BaseStatelessConsumer<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        // print("Index $index -> ${provider.supportRequestList[index].profileUrl}");



        String capitalizeFirstLetter(String text) {
          if (text.isEmpty) return "";
          if (text == "FORWARD") {
            return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}ed';
          } else if (text == "SUBMIT") {
            return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}ted';
          } else {
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
            padding:
                const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 0, right: 4),
            child: Column(children: [
              Visibility(
                visible: provider.itemAgainstSupportRequestList[index]
                            .logStatusCode ==
                        "FORWARD" ||
                    provider.itemAgainstSupportRequestList[index]
                            .logStatusCode ==
                        "REASSIGNED",
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: provider.itemAgainstSupportRequestList[index]
                                .logStatusCode ==
                            "FORWARD"
                        ? Row(
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.forward,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                              Text(
                                "Forwarded",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              )
                            ],
                          )
                        : Row(
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.compare_arrows,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                              Text(
                                "Reassigned",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              Stack(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ProfileImageDialog.show(
                                  context: context,
                                  imageUrl: ((provider.itemAgainstSupportRequestList[index].requestStatusCode == "PENDING" ||
                                              provider.itemAgainstSupportRequestList[index].logStatusCode ==
                                                  "SUBMIT" ||
                                              (provider.itemAgainstSupportRequestList[index].requestStatusCode == "CLOSED" &&
                                                  provider.itemAgainstSupportRequestList[index].logFromUser ==
                                                      provider
                                                          .loggedUserName))) ||
                                          (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                              "Closed") ||
                                          (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                              "CLOSED")
                                      ? provider.itemAgainstSupportRequestList[index].logFromUserProfileUrl ??
                                          ""
                                      : (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                              "CANCELLED")
                                          ? provider.itemAgainstSupportRequestList[index].logFromUserProfileUrl ??
                                              ""
                                          : provider.itemAgainstSupportRequestList[index].logToUserProfileUrl ??
                                              "",
                                  userName: ((provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                                  "PENDING" ||
                                              provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                                  "SUBMIT" ||
                                              (provider.itemAgainstSupportRequestList[index].requestStatusCode == "CLOSED" &&
                                                  provider.itemAgainstSupportRequestList[index]
                                                          .logFromUser ==
                                                      provider.loggedUserName))) ||
                                          (provider.itemAgainstSupportRequestList[index].requestStatusCode == "Closed") ||
                                          (provider.itemAgainstSupportRequestList[index].logStatusCode == "CLOSED")
                                      ? provider.itemAgainstSupportRequestList[index].logFromUser ?? ""
                                      : (provider.itemAgainstSupportRequestList[index].logStatusCode == "CANCELLED")
                                          ? provider.itemAgainstSupportRequestList[index].logFromUser == provider.userName
                                              ? "You"
                                              : provider.itemAgainstSupportRequestList[index].logFromUser ?? ""
                                          : provider.itemAgainstSupportRequestList[index].logToUser ?? "");
                            },
                            child: CachedNetworkImageWidget(
                              imageUrl: ((provider
                                                  .itemAgainstSupportRequestList[
                                                      index]
                                                  .requestStatusCode ==
                                              "PENDING" ||
                                          provider.itemAgainstSupportRequestList[index].logStatusCode ==
                                              "SUBMIT" ||
                                          (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                                  "CLOSED" &&
                                              provider.itemAgainstSupportRequestList[index].logFromUser ==
                                                  provider.loggedUserName))) ||
                                      (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                          "Closed") ||
                                      (provider
                                              .itemAgainstSupportRequestList[
                                                  index]
                                              .requestStatusCode ==
                                          "CLOSED")
                                  ? provider
                                          .itemAgainstSupportRequestList[index]
                                          .logFromUserProfileUrl ??
                                      ""
                                  : (provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                          "CANCELLED")
                                      ? provider
                                              .itemAgainstSupportRequestList[
                                                  index]
                                              .logFromUserProfileUrl ??
                                          ""
                                      : provider
                                              .itemAgainstSupportRequestList[index]
                                              .logToUserProfileUrl ??
                                          "",
                                userName: ((provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                    "PENDING" ||
                                    provider.itemAgainstSupportRequestList[index].requestStatusCode ==
                                        "SUBMIT" ||
                                    (provider.itemAgainstSupportRequestList[index].requestStatusCode == "CLOSED" &&
                                        provider.itemAgainstSupportRequestList[index]
                                            .logFromUser ==
                                            provider.loggedUserName))) ||
                                    (provider.itemAgainstSupportRequestList[index].requestStatusCode == "Closed") ||
                                    (provider.itemAgainstSupportRequestList[index].logStatusCode == "CLOSED")
                                    ? provider.itemAgainstSupportRequestList[index].logFromUser ?? ""
                                    : (provider.itemAgainstSupportRequestList[index].logStatusCode == "CANCELLED")
                                    ? provider.itemAgainstSupportRequestList[index].logFromUser == provider.userName
                                    ? provider.userName
                                    : provider.itemAgainstSupportRequestList[index].logFromUser ?? ""
                                    : provider.itemAgainstSupportRequestList[index].logToUser ?? "",
                              size: 50,
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
                                  (provider.userName ==
                                          provider
                                              .itemAgainstSupportRequestList[
                                                  index]
                                              .logFromUser)
                                      ? 'You'
                                      : '${provider.itemAgainstSupportRequestList[index].logFromUser}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  (provider.itemAgainstSupportRequestList[index]
                                              .requestStatusCode ==
                                          "CLOSED")
                                      ? (provider
                                                  .itemAgainstSupportRequestList[
                                                      index]
                                                  .closedBy ==
                                              provider.userName)
                                          ? "${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].requestStatusCode ?? "")} by You"
                                          : '${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].requestStatusCode ?? "")} by ${provider.itemAgainstSupportRequestList[index].closedBy}'
                                      : (provider
                                                  .itemAgainstSupportRequestList[
                                                      index]
                                                  .logToUser ==
                                              provider.userName)
                                          ? "${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].logStatusCode ?? "")} to You"
                                          : (provider
                                                      .itemAgainstSupportRequestList[
                                                          index]
                                                      .requestStatusCode ==
                                                  "CANCELLED")
                                              ? (provider
                                                          .itemAgainstSupportRequestList[
                                                              index]
                                                          .logFromUser ==
                                                      provider.userName)
                                                  ? '${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].logStatusCode ?? "")} by You'
                                                  : '${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].logStatusCode ?? "")} by ${provider.itemAgainstSupportRequestList[index].logFromUser}'
                                              : '${capitalizeFirstLetter(provider.itemAgainstSupportRequestList[index].logStatusCode ?? "")} to ${provider.itemAgainstSupportRequestList[index].logToUser}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
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
                                .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              "${provider.itemAgainstSupportRequestList[index].transNo}",
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
                                    .itemAgainstSupportRequestList[index]
                                    .createdTime),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (provider.itemAgainstSupportRequestList[index]
                                            .requestStatusCode ==
                                        "CLOSED")
                                    ? 'Closed Date'
                                    : 'Expected Closure Date',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall?.copyWith(fontWeight: FontWeight.w700 ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (provider.itemAgainstSupportRequestList[index]
                                            .requestStatusCode ==
                                        "CLOSED")
                                    ? DateFormat('MMM dd, yyyy').format(provider
                                            .itemAgainstSupportRequestList[
                                                index]
                                            .closedDate ??
                                        DateTime.now())
                                    : DateFormat('MMM dd, yyyy').format(provider
                                            .itemAgainstSupportRequestList[
                                                index]
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
                                '${provider.itemAgainstSupportRequestList[index].points}',
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
                provider.itemAgainstSupportRequestList[index].remainingTime ==
                            null &&
                        provider.itemAgainstSupportRequestList[index]
                                .requestStatusCode ==
                            "PENDING"
                    ? Positioned(
                        top: 53,
                        right: 12.5,
                        child: DelayedBadge(
                          size: BadgeSize.compact,
                        ))
                    : provider.itemAgainstSupportRequestList[index]
                                .requestStatusCode !=
                            "CLOSED"
                        ? provider.itemAgainstSupportRequestList[index]
                                    .requestStatusCode ==
                                "CANCELLED"
                            ? Positioned(
                                top: 53,
                                right: 12.5,
                                child: CancelledBadge(
                                  size: BadgeSize.compact,
                                ))
                            : Positioned(
                                top: 53,
                                right: 12.5,
                                child: OpenBadge(
                                  size: BadgeSize.compact,
                                ))
                        : provider.itemAgainstSupportRequestList[index]
                                    .requestStatusCode ==
                                "CLOSED"
                            ? Positioned(
                                top: 53,
                                right: 12.5,
                                child: ClosedBadge(
                                  size: BadgeSize.compact,
                                ))
                            : Container(),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

Widget filterFormWidget() {
  final DateTime now = DateTime.now();
  final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
  return BaseStatelessConsumer<ProjectScheduleProvider>(
      provider: projectScheduleProvider,
      builder: (context, provider, ref) {
        return SingleChildScrollView(
            child: Form(
                child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
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
                              .titleLarge,
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
              BaseTextField(
                fillColor: Theme.of(context).colorScheme.secondary,
                fillColorNeeded: false,
                controller: provider.transNoController,
                displayTitle: "Trans No",
              ),
              SizedBox(
                height: 8,
              ),
              BaseDropDownButtonFormField<FilterStatusModel>(
                iconEnabledColor: Theme.of(context).colorScheme.primary,
                fillColorNeeded: false,
                label: "Status",
                labelColor: Theme.of(context).textTheme.titleLarge?.color,
                hintText: "Select status",
                initialValue: provider.filterSelectedStatus,
                items: provider.filterStatusList,
                onChanged: (value) {
                  provider.changeFilterStatus(value!);
                },
                builder: (value) {
                  return Text(value.statusName);
                },
              ),
              SizedBox(
                height: 8,
              ),
              // Visibility(
              //   visible: (provider.projectDetailList.first.reportingToYN == "Y" || provider.isSuperUser) ? true : false,
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 4.0,right: 4.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text("Show only my support requests",style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //             fontWeight: FontWeight.w500
              //         ),),
              //         Switch(
              //           activeColor: bayaInfraAppPrimary,
              //           value: provider.supViewOtherTransactionYN,
              //           onChanged: (val) {
              //             provider.changeSupViewOtherTransactionYN(val);
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Show all support requests",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(),
                    ),
                    Switch(
                      activeColor: Theme.of(context).primaryColor,
                      value: provider.tempIsShowAllTaskSupport ??
                          provider.isShowAllTaskSupport,
                      onChanged: (val) {
                        provider.changeIsShowAllSupport(val);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4),
                child: Visibility(
                  visible: (provider.tempIsShowAllTaskSupport != null)
                      ? !provider.tempIsShowAllTaskSupport!
                      : !provider.isShowAllTaskSupport,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Target closure date",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: BaseDatesPicker(
                              onChange: (date) {
                                provider.changeClosureDateFrom(date);
                              },
                              initialDate: provider.tempClosureDateFrom ??
                                  provider.closureDateFrom,
                              lastDate: provider.tempClosureDateTo ??
                                  provider.closureDateTo,
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
                              initialDate: provider.tempClosureDateTo ??
                                  provider.closureDateTo,
                              firstDate: provider.tempClosureDateFrom ??
                                  provider.closureDateFrom,
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
                        provider.setIsShowAllSupport();
                        provider.setSelectedFilterStatus();
                        provider.setSptFilterDateField();
                        provider.fetchTaskAgainstSupportList(changeStart: true);
                      },
                      text: 'Apply',
                    )),
                  ],
                ),
              )
            ],
          ),
        )));
      });
}
