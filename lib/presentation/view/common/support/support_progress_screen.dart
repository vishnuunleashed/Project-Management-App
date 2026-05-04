
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:intl/intl.dart';

class SupportProgressScreen<U extends BaseSupportProvider> extends ConsumerStatefulWidget {
  final ProviderListenable<U> provider;
  Future<bool> Function(BuildContext) onBack;
  SupportProgressScreen({super.key,required this.provider,required this.onBack});

  @override
  ConsumerState<SupportProgressScreen> createState() => _SupportProgressScreenState();
}

class _SupportProgressScreenState extends ConsumerState<SupportProgressScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();




  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(widget.provider);
    return RefreshIndicator(
      onRefresh: ()async{
        provider.fillSupportRequestDetails();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: CustomAppBar(
            title: const Text(
              'Task Progress',
            ),
            onBack: widget.onBack,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Details Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            Theme.of(context).primaryColor.withValues(alpha: 0.25),
                            Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            Theme.of(context).primaryColor.withValues(alpha: 0.15),
                            Theme.of(context).primaryColor.withValues(alpha: 0.1)],
                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: provider.supportListData != null
                                          &&  provider.supportListData?.reftransaction != null
                                          && provider.supportListData!.reftransaction!.isNotEmpty,
                                      child: Text(
                                        "${provider.supportListData?.reftransaction.toString()}",
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Visibility(
                                      visible: provider.supportListData != null
                                          &&  provider.supportListData!.projectName != null
                                          && provider.supportListData!.projectName!.isNotEmpty,
                                      child: Text(
                                        "${provider.supportListData?.projectName.toString()}",
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${provider.supportListData?.transNo.toString()}",
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        height: 1.4,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Escalation date    : ${provider.formatDateOrToday(DateTime.parse(provider.supportListData?.transDate??DateTime.now().toString()))}',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                      overflow:  TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Exp Closure date : ${provider.formatDateOrToday(DateTime.parse(provider.supportListData?.targetClosureDate??DateTime.now().toString()))}',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        height: 1.4,
                                        fontWeight: FontWeight.w400 ,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 80,
                                  height: 80,
                                  child:SvgPicture.asset(
                                    'assets/svgs/project_icon.svg',
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (provider.supportListData?.requeststatus == "Closed") ?
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Closed Date',
                                      style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      DateFormat('MMM dd, yyyy').format(provider.supportListData?.statusDate ?? DateTime.now()),
                                      style:  Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ))
                                ],
                              )
                                  : Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                      style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Builder(
                                      builder: (context) {
                                        Color textColor;
                                        if (provider.targetClosureDate == 'Delayed') {
                                          textColor = bayaInfraRed;
                                        } else if (provider.targetClosureDate == 'Due today' || provider.targetClosureDate == 'Due tomorrow') {
                                          textColor = bayaInfraAmber;
                                        } else {
                                          textColor = bayaInfraGreen;
                                        }
                                        return Text(
                                          provider.targetClosureDate,
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              color: textColor,
                                            ),
                                        );
                                      }
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${provider.supportListData?.reqtrackjson.last.status} ${(provider.supportListData?.reqtrackjson.last.status == "Closed") ? "By" : "To"}",
                                      style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (provider.supportListData?.requeststatus == "Closed") ? provider.supportListData?.closedBy ?? "" :provider.supportListData?.assignedTo??"",
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Timeline Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Card(
                      color: Theme.of(context).cardColor,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Task Progress',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                if (provider.reqTrackList.isNotEmpty) ...[
                                  // First Item
                                  _buildTimelineItem(
                                      icon: _getIcon(provider.reqTrackList.first.status, context)['icon'],
                                      iconColor: _getIcon(provider.reqTrackList.first.status, context)['color'],
                                      title: provider.reqTrackList.first.status,
                                      subtitle: provider.reqTrackList.first.remarks ?? '',
                                      date: provider.reqTrackList.first.statusDate != null &&
                                          provider.reqTrackList.first.statusDate!.isNotEmpty
                                          ? provider.formatDate(DateTime.parse(provider.reqTrackList.first.statusDate!))
                                          : '',
                                      fromUserName: (provider.reqTrackList.first.fromUser == provider.userName) ? "You" : provider.reqTrackList.first.fromUser ?? '',
                                      toUserName: (provider.reqTrackList.first.toUser == provider.userName) ? "You" : provider.reqTrackList.first.toUser ?? "",
                                      isPreviousUserTakeAction: false,
                                      isCompleted: true,
                                      showConnector: true,
                                      status: provider.reqTrackList.first.status,
                                      fromUserProfileUrl: provider.reqTrackList.first.fromUserProfileUrl ?? "",
                                      toUserProfileUrl: provider.reqTrackList.first.toUserProfileUrl ?? "",
                                      logInUserName: provider.userName
                                  ),

                                  SizedBox(height: 8,),
                                  // Expandable Middle Items
                                  if (provider.reqTrackList.length > 2)
                                    ExpansionTile(
                                      shape: RoundedRectangleBorder(side: BorderSide.none),
                                      childrenPadding: EdgeInsets.zero,
                                      onExpansionChanged: (bool expanded) {
                                        provider.changeIsTileExpanded(expanded);
                                      },
                                      title: Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: bayaInfraBlue50,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              provider.isTileExpanded ? Icons.timeline : Icons.timeline_outlined,
                                              color: Theme.of(context).primaryColor,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              (provider.isTileExpanded)
                                                  ? 'Hide ${provider.reqTrackList.length - 2} progress'
                                                  : 'View ${provider.reqTrackList.length - 2} more progress',
                                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                color: bayaInfraBlue600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: bayaInfraBlue50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          provider.isTileExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      initiallyExpanded: provider.isTileExpanded,
                                      children: List.generate(
                                        provider.reqTrackList.length - 2,
                                            (index) {
                                          final item = provider.reqTrackList[index + 1];
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12, top: 12),
                                            child: _buildTimelineItem(
                                                icon: _getIcon(provider.reqTrackList[index + 1].status, context)['icon'],
                                                iconColor: _getIcon(provider.reqTrackList[index + 1].status, context)['color'],
                                                title: item.status,
                                                subtitle: item.remarks ?? '',
                                                date: item.statusDate != null && item.statusDate!.isNotEmpty
                                                    ? provider.formatDate(DateTime.parse(item.statusDate!))
                                                    : '',
                                                fromUserName: (item.fromUser == provider.userName) ? "You" : item.fromUser ?? '',
                                                toUserName: (item.toUser == provider.userName) ? "You" : item.toUser ?? "",
                                                isPreviousUserTakeAction:(provider.reqTrackList[index].toUser != null && provider.reqTrackList[index].toUser != "") ? (provider.reqTrackList[index].toUser != item.fromUser) ? true : false:false,
                                                isCompleted: true,
                                                showConnector: true,
                                                status: provider.reqTrackList[index + 1].status,
                                                fromUserProfileUrl: provider.reqTrackList[index+1].fromUserProfileUrl ?? "",
                                                toUserProfileUrl: provider.reqTrackList[index + 1].toUserProfileUrl ?? "",
                                                logInUserName: provider.userName
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  // Last Item
                                  if (provider.reqTrackList.length > 1)
                                    _buildTimelineItem(
                                        icon: _getIcon(provider.reqTrackList.last.status, context)['icon'],
                                        iconColor: _getIcon(provider.reqTrackList.last.status, context)['color'],
                                        title: provider.reqTrackList.last.status,
                                        subtitle: provider.reqTrackList.last.remarks ?? '',
                                        date: provider.reqTrackList.last.statusDate != null &&
                                            provider.reqTrackList.last.statusDate!.isNotEmpty
                                            ? provider.formatDate(DateTime.parse(provider.reqTrackList.last.statusDate!))
                                            : '',
                                        fromUserName: (provider.reqTrackList.last.fromUser == provider.userName)  ? "You" :provider.reqTrackList.last.fromUser ?? '',
                                        toUserName: (provider.reqTrackList.last.toUser == provider.userName) ? "You" : provider.reqTrackList.last.toUser ?? '',
                                        isPreviousUserTakeAction: (provider.reqTrackList[provider.reqTrackList.length - 1].toUser == provider.reqTrackList.last.fromUser) || (provider.reqTrackList.last.status == "Closed"),
                                        isCompleted: true,
                                        showConnector: false,
                                        status: provider.reqTrackList.last.status,
                                        fromUserProfileUrl: provider.reqTrackList.last.fromUserProfileUrl ?? "",
                                        toUserProfileUrl: provider.reqTrackList.last.toUserProfileUrl ?? "",
                                        logInUserName: provider.userName

                                    ),
                                ],
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Team Members Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Card(
                      color: Theme.of(context).cardColor,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participants',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(bayaInfraBlue100),
                                thickness: WidgetStateProperty.all(6),
                                radius: const Radius.circular(4),
                              ),
                              child: Scrollbar(
                                controller: provider.scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 2,
                                radius: const Radius.circular(4),
                                scrollbarOrientation: ScrollbarOrientation.bottom,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * 0.12,
                                  child: ListView.builder(
                                    controller: provider.scrollController,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: provider.supportListData?.supportUsersJson.length ?? 0,
                                    itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: _buildTeamMember(
                                        provider.supportListData!.supportUsersJson[index].name,
                                        "Team Member",
                                        Colors.green,
                                        provider.userName,
                                        provider.supportListData?.supportUsersJson[index].profileUrl ?? "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Add Comment Input at Bottom
          bottomNavigationBar: Visibility(
            visible:  (provider.supportListData != null
                && provider.supportListData?.assignedstatuscode != "CLOSED"
                && provider.supportListData?.assignedstatuscode != "CANCELLED"),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: provider.commentController,
                        style: Theme.of(context).textTheme.labelLarge,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
                          hintText: 'Add a comment...',
                          hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), width: 1),
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) {
                          _addComment(provider);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _addComment(provider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addComment(BaseSupportProvider provider) {
    if (provider.commentController.text.trim().isEmpty) {
      BaseSnackBar().show(message: "Add a comment");
      return;
    }

    provider.sendCommentSupportTrack();

    FocusScope.of(context).unfocus();
  }

  Map<String, dynamic> _getIcon(String? status, BuildContext context) {
    switch (status) {
      case "Created":
        return {'icon':Icons.add_circle_outline, 'color': bayaInfraGreen};
      case "Assigned":
        return {'icon':Icons.assignment_ind, 'color': Color(0xFF0298DB)};
      case "Forwarded":
        return {'icon': Icons.forward, 'color': bayaInfraAmber};
      case "Submitted":
        return {'icon': Icons.upload_file, 'color': bayaInfraPaleGreen};
      case "Closed":
        return {'icon': Icons.task_alt, 'color': bayaInfraGreen};
      case "Reassigned":
        return {'icon': Icons.swap_horiz, 'color': bayaInfraAmber};
      case "Cancelled":
        return {'icon': Icons.cancel, 'color': bayaInfraRed};
      case "Commented":
        return {'icon': Icons.comment, 'color': bayaInfraBlue600};
      default:
        return {'icon': Icons.help_outline, 'color': bayaInfraGreyColor};
    }
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String date,
    required String fromUserName,
    required String fromUserProfileUrl,
    required String toUserProfileUrl,
    required String toUserName,
    required bool isCompleted,
    required bool showConnector,
    required bool isPreviousUserTakeAction,
    required String status,
    required String logInUserName
  }) {
    // Special rendering for comments
    if (status == "Comment") {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bayaInfraBlue100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.comment,
                  color: bayaInfraBlue600,
                  size: 24,
                ),
              ),
              if (showConnector)
                Container(
                  width: 3,
                  height: 60,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: bayaInfraBlue100,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bayaInfraBlue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bayaInfraBlue100, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: bayaInfraBlue100,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(
                              context: context,
                              imageUrl: fromUserProfileUrl,
                              userName: fromUserName,
                            );
                          },
                          child: CachedNetworkImageWidget(
                            imageUrl: fromUserProfileUrl ,
                            size: 32,
                            iconSize: 12,
                            userName: (fromUserName == "You") ? logInUserName : fromUserName,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromUserName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Commented',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).scaffoldBackgroundColor
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            bayaInfraBlue50!,
                                            bayaInfraBlue100,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "Comment",
                                              style: Theme.of(context).textTheme.titleLarge
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.grey),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: 100,
                                          maxHeight: 400,
                                        ),
                                        child: SingleChildScrollView(
                                          physics: AlwaysScrollableScrollPhysics(),
                                          child: Text(
                                            subtitle,
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Original rendering for other statuses
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? iconColor : bayaInfraGrey300,
                shape: BoxShape.circle,
                border: !isCompleted ? Border.all(
                  color: Colors.grey[400]!,
                  width: 2,
                ) : null,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : bayaInfraGrey400,
                size: 24,
              ),
            ),
            if (showConnector)
              Container(
                width: 3,
                height: (status == "Created") ? 40 : 60,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? iconColor : bayaInfraGrey300,
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: !isCompleted? bayaInfraGrey300 :bayaInfraBlue100,
                      shape: BoxShape.circle,
                    ),
                    child:
                    GestureDetector(
                      onTap: () {
                        ProfileImageDialog.show(context: context,
                          imageUrl: fromUserProfileUrl,
                          userName:  fromUserName,);

                      },
                      child:CachedNetworkImageWidget(
                        imageUrl: fromUserProfileUrl ,
                        size: 32,
                        iconSize: 12,
                        userName: (fromUserName == "You") ? logInUserName : fromUserName,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (status == "Created")
                              ? "By"
                              : (title == "Closed")
                              ?  "By"
                              : (status == "Cancelled")
                              ? "By"
                              : (status == "Commented")
                              ? "By"
                              : "From",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        fromUserName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: (toUserName != ""),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: !isCompleted? bayaInfraGrey300 :bayaInfraBlue100,
                        shape: BoxShape.circle,
                      ),
                      child:GestureDetector(
                        onTap: () {
                          ProfileImageDialog.show(context: context,
                            imageUrl: toUserProfileUrl,
                            userName:  toUserName,);
                        },
                        child:CachedNetworkImageWidget(
                          imageUrl: toUserProfileUrl ,
                          size: 32,
                          iconSize: 12,
                          userName: (toUserName == "You") ? logInUserName : toUserName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            (status == "Closed") ? "By" : "To",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        const SizedBox(height: 2),
                        Text(
                          toUserName,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: (subtitle != "") ? true : false ,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).scaffoldBackgroundColor
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        bayaInfraBlue50!,
                                        bayaInfraBlue100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Remarks",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.black
                                          )
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: Colors.grey),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: 200,
                                      maxHeight: 600,
                                    ),
                                    child: SingleChildScrollView(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: Text(
                                        subtitle,
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember(String name, String role, Color statusColor, String loginUsername, String profileUrl) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ProfileImageDialog.show(context: context,
              imageUrl: profileUrl,
              userName:  name,);
          },
          child:  CachedNetworkImageWidget(
            imageUrl: profileUrl ,
            size: 50,
            iconSize: 24,
            userName: name,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (loginUsername == name) ? "You" : name,
          style:  Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}