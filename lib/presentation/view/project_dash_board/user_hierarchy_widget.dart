import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_dash_baord/project_dashboard_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_dash_board/widgets/glassmorphic_text_toggle.dart';
//
class CompactUserFilter extends ConsumerWidget {
  final Function(UserHierarchyModel user, String scopeFlag)? onUserSelectionChanged;
  final Function(String scopeFlag)? onScopeChanged;
  final Function(CategoryFlag categoryFlag)? onCategoryChanged;

  const CompactUserFilter({
    Key? key,
    this.onUserSelectionChanged,
    this.onScopeChanged,
    this.onCategoryChanged,
  }) : super(key: key);


  void _showUserSelectionDialog(BuildContext context, WidgetRef ref) {
    final provider = ref.read(projectDashboardProvider);

    showDialog(
      context: context,
      builder: (context) => _UserSelectionDialog(
        currentUserId: provider.userId,
        loggedInUserId: provider.loggedInUserId,
        loggedInUserName: provider.loggedInUserName,
        onUserSelected: (user) {
          onUserSelectionChanged!(user, provider.scopeFlag);
        },
      ),
    );
  }

  Color _getBorderColor(String scopeFlag, BuildContext context) {
    return scopeFlag == "INDIVIDUAL"
        ? Colors.grey // emerald-500
        : Theme.of(context).primaryColor; // blue-500
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(projectDashboardProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(height: 2,),

          // User Selection Pill
          Flexible(
            child: InkWell(
              onTap: () => _showUserSelectionDialog(context, ref),
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                child: Container(

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        blurRadius: 1,
                        spreadRadius: 1,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),

                  margin: EdgeInsets.zero,

                  child: Row(
                    children: [
                      CachedNetworkImageWidget(
                        imageUrl: provider.selectedUser?.userId == provider.loggedInUserId
                            ? provider.loggedInUserProfileImageUrl ?? ""
                            : provider.selectedUser?.userProfileImageUrl ?? "",
                        size: 25,
                        userName: provider.selectedUser?.userName ?? provider.loggedInUserName,
                        isCircleEnabled: true,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.selectedUser?.userId == provider.loggedInUserId
                              ? 'You'
                              : provider.selectedUser?.userName ??"You",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                child: Container(

                   decoration: BoxDecoration(
                     color: Theme.of(context).cardColor,
                     borderRadius: BorderRadius.circular(32),
                     boxShadow: [
                       BoxShadow(
                         color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                         blurRadius: 1,
                         spreadRadius: 1,
                         offset: Offset(0, 0),
                       ),
                     ],
                   ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSegmentButton(
                          context,
                          "Individual",
                          provider.scopeFlag == "INDIVIDUAL",
                              () => provider.changeScopeFlag(scopeFlag: "INDIVIDUAL"),
                        ),
                        _buildSegmentButton(
                          context,
                          "Team",
                          provider.scopeFlag == "TEAM",
                              () => provider.changeScopeFlag(scopeFlag: "TEAM"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),



        ],
      ),
    );
  }

  Widget _buildSegmentButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected
                ? Colors.white
                : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

}
// class CompactUserFilter extends ConsumerWidget {
//   final Function(UserHierarchyModel user, String scopeFlag)? onUserSelectionChanged;
//
//
//   const CompactUserFilter({
//     Key? key,
//     this.onUserSelectionChanged,
//
//   }) : super(key: key);
//
//   void _showUserSelectionDialog(BuildContext context, WidgetRef ref) {
//     final provider = ref.read(projectDashboardProvider);
//
//     showDialog(
//       context: context,
//       builder: (context) => _UserSelectionDialog(
//         currentUserId: provider.userId,
//         loggedInUserId: provider.loggedInUserId,
//         loggedInUserName: provider.loggedInUserName,
//         onUserSelected: (user) {
//           onUserSelectionChanged!(user, provider.scopeFlag);
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final provider = ref.watch(projectDashboardProvider);
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: provider.scopeFlag == "INDIVIDUAL"
//               ? bayaInfraGreen
//               : Theme.of(context).primaryColor,
//           width: 1,
//         ),
//       ),
//       elevation: 0,
//       color: Theme.of(context).cardColor,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "${provider.scopeFlag} TASKS",
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 11,
//
//                   ),
//                 ),
//                 Transform.scale(
//                   scale: 0.9,
//                   child: Switch(
//                     value: provider.scopeFlag == "TEAM",
//                     onChanged: (value) {
//                       final scopeFlag = value ? 'TEAM' : 'INDIVIDUAL';
//                       provider.changeScopeFlag(scopeFlag: scopeFlag);
//                     },
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     inactiveTrackColor: Colors.white,
//                     inactiveThumbColor: bayaInfraPaleLightGreen,
//                     activeColor: Theme.of(context).primaryColor,
//                     trackOutlineColor:
//                     MaterialStateProperty.resolveWith<Color?>(
//                           (states) {
//                         if (states.contains(MaterialState.disabled)) {
//                           return Colors.grey;
//                         }
//                         return provider.scopeFlag == "INDIVIDUAL"
//                             ? bayaInfraPaleLightGreen
//                             : Theme.of(context).primaryColor;
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(width: 8),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.6,
//               child: Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           'FOCUSING ON',
//                           style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       InkWell(
//                         onTap: () => _showUserSelectionDialog(context, ref),
//                         borderRadius: BorderRadius.circular(16),
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             side: BorderSide(
//                               color: provider.scopeFlag == "INDIVIDUAL"
//                                   ? bayaInfraGreen
//                                   : Theme.of(context).primaryColor,
//                               width: 1,
//                             ),
//                           ),
//                           elevation: 0,
//                           color: Theme.of(context).cardColor,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 6),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Flexible(
//                                   child: Text(
//                                     provider.selectedUser?.userId == provider.loggedInUserId
//                                         ? 'Me'
//                                         : provider.selectedUser?.userName ?? 'Me',
//
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .labelLarge
//                                         ?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Icon(
//                                   Icons.arrow_drop_down,
//                                   size: 20,
//                                   color: Theme.of(context).iconTheme.color,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 8),
//                   if (provider.selectedUser != null &&
//                       provider.selectedUser?.userId != provider.loggedInUserId)
//                     GestureDetector(
//                       onTap: () {
//                         ProfileImageDialog.show(
//                           context: context,
//                           imageUrl: provider.selectedUser?.userProfileImageUrl ?? "",
//                           userName: provider.selectedUser?.userName ?? "User",
//                         );
//                       },
//                       child: CachedNetworkImageWidget(
//                         imageUrl: provider.selectedUser?.userProfileImageUrl ?? "",
//                         size: 40,
//                         userName: provider.selectedUser?.userName ?? "",
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// ============================================================================
// DIALOG WITH FIXES FOR DUPLICATE USERS AND HIERARCHY DISPLAY
// ============================================================================

class _UserSelectionDialog extends ConsumerStatefulWidget {
  final int currentUserId;
  final int loggedInUserId;
  final String loggedInUserName;
  final Function(UserHierarchyModel) onUserSelected;

  const _UserSelectionDialog({
    required this.currentUserId,
    required this.loggedInUserId,
    required this.loggedInUserName,
    required this.onUserSelected,
  });

  @override
  ConsumerState<_UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends ConsumerState<_UserSelectionDialog> {
  late Map<int?, List<UserHierarchyModel>> _hierarchy;
  late Set<int> _allReportingToIds;
  late Set<int> _allUserIds;
  late List<int?> _rootParentIds;
  late Set<int> _processedUserIds; // Track processed users to avoid duplicates
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _processedUserIds = {};
    _buildHierarchyStructure();
  }

  /// Build hierarchy structure ONCE in initState
  void _buildHierarchyStructure() {
    try {
      final provider = ref.read(projectDashboardProvider);
      final users = provider.userHierarchyModel
          .where((item) => item.userId != widget.loggedInUserId)
          .toList();

      _hierarchy = {};
      _allReportingToIds = {};
      _allUserIds = {};

      for (var user in users) {
        if (user.userId != null) {
          _hierarchy.putIfAbsent(user.reportingTo, () => []).add(user);
          _allUserIds.add(user.userId!);
        }
        if (user.reportingTo != null) {
          _allReportingToIds.add(user.reportingTo!);
        }
      }

      // Find root users: users whose reportingTo is null, 0, or not in the user list
      _rootParentIds = [];

      // Add users with null or 0 reportingTo
      for (var user in users) {
        if ((user.reportingTo == null || user.reportingTo == 0) && !_rootParentIds.contains(user.reportingTo)) {
          if (!_rootParentIds.contains(user.reportingTo)) {
            _rootParentIds.add(user.reportingTo);
          }
        }
      }

      // Add reportingTo IDs that don't exist in user list
      for (var reportingToId in _allReportingToIds) {
        if (!_allUserIds.contains(reportingToId) && !_rootParentIds.contains(reportingToId)) {
          _rootParentIds.add(reportingToId);
        }
      }

      debugPrint('Hierarchy built: ${_hierarchy.length} groups, ${_allUserIds.length} users');
    } catch (e) {
      debugPrint('Error building hierarchy: $e');
    }
  }

  /// Build root items - avoiding duplicates
  List<Widget> _buildRootUserItems(List<UserHierarchyModel> users) {
    List<Widget> widgets = [];
    _processedUserIds.clear();

    try {
      void buildTree(int? parentId) {
        final children = _hierarchy[parentId] ?? [];

        for (int i = 0; i < children.length; i++) {
          final user = children[i];

          // Skip if already processed (avoid duplicates)
          if (user.userId != null && _processedUserIds.contains(user.userId)) {
            continue;
          }

          if (user.userId != null) {
            _processedUserIds.add(user.userId!);
          }

          final isLast = i == children.length - 1;

          widgets.add(
            UserHierarchyItem(
              user: user,
              hierarchy: _hierarchy,
              loggedInUserId: widget.loggedInUserId,
              depth: 0,
              isLastAtLevel: const [],
              isLast: isLast,
              processedUserIds: _processedUserIds,
              onUserSelected: widget.onUserSelected,
              onUserTapped: _closeDialog,
            ),
          );
        }
      }

      // Only build from root parents
      for (var rootId in _rootParentIds) {
        buildTree(rootId);
      }
    } catch (e) {
      debugPrint('Error building root items: $e');
    }

    return widgets;
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _cleanup() {
    try {
      _hierarchy.clear();
      _allReportingToIds.clear();
      _allUserIds.clear();
      _rootParentIds.clear();
      _processedUserIds.clear();
      _scrollController.dispose();
      debugPrint('Dialog cleanup completed');
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(projectDashboardProvider);
    final users = provider.userHierarchyModel
        .where((item) => item.userId != widget.loggedInUserId)
        .toList();

    return WillPopScope(
      onWillPop: () async {
        debugPrint('Dialog will pop');
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Select Person',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Visibility(
                          visible: provider.isAllExpanded,
                          child: IconButton(onPressed: (){
                            provider.collapseAllHierarchyUsers();
                          },
                              icon: Icon(Icons.unfold_more,
                            color: Theme.of(context).iconTheme.color,)),
                        ),
                        Visibility(
                          visible: !provider.isAllExpanded,
                          child: IconButton(onPressed: (){
                            provider.expandAllHierarchyUsers();
                          },
                              icon: Icon(Icons.unfold_less,
                            color: Theme.of(context).iconTheme.color,)),
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closeDialog,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // User List
              Flexible(
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: [
                    // Me (Reset) - without expand icon
                    UserHierarchyItem(
                      user: UserHierarchyModel(
                        userId: widget.loggedInUserId,
                        userName: 'You',
                      ),
                      hierarchy: _hierarchy,
                      loggedInUserId: widget.loggedInUserId,
                      depth: 0,
                      isLastAtLevel: const [],
                      isLast: true,
                      isResetUser: true,
                      processedUserIds: _processedUserIds,
                      onUserSelected: widget.onUserSelected,
                      onUserTapped: _closeDialog,
                    ),
                    // Root users
                    ..._buildRootUserItems(users),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RECURSIVE USER HIERARCHY ITEM WIDGET
// ============================================================================

class UserHierarchyItem extends StatelessWidget {
  final UserHierarchyModel user;
  final Map<int?, List<UserHierarchyModel>> hierarchy;
  final int loggedInUserId;
  final int depth;
  final List<bool> isLastAtLevel;
  final bool isLast;
  final bool isResetUser;
  final Set<int> processedUserIds;
  final Function(UserHierarchyModel) onUserSelected;
  final VoidCallback onUserTapped;

  const UserHierarchyItem({
    Key? key,
    required this.user,
    required this.hierarchy,
    required this.loggedInUserId,
    required this.depth,
    required this.isLastAtLevel,
    required this.isLast,
    required this.processedUserIds,
    required this.onUserSelected,
    required this.onUserTapped,
    this.isResetUser = false,
  }) : super(key: key);

  /// Check if user has children
  bool get hasChildren {
    if (isResetUser) return false; // Me (Reset) never has children
    return hierarchy[user.userId]?.isNotEmpty ?? false;
  }

  /// Get children list
  List<UserHierarchyModel> get childUsers {
    return hierarchy[user.userId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer(
      provider: projectDashboardProvider,
      builder: (context,provider,ref) {
        return Column(
          children: [
            _buildUserTile(context),

            // Recursively render children if expanded
            if (hasChildren && (provider.userHierarchyModel.firstWhere((item){return item.userId == user.userId;}).isExpanded ?? false))
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    for (int childIndex = 0; childIndex < childUsers.length; childIndex++)
                      UserHierarchyItem(
                        user: childUsers[childIndex],
                        hierarchy: hierarchy,
                        loggedInUserId: loggedInUserId,
                        depth: depth + 1,
                        isLastAtLevel: [...isLastAtLevel, isLast],
                        isLast: childIndex == childUsers.length - 1,
                        isResetUser: false,
                        processedUserIds: processedUserIds,
                        onUserSelected: onUserSelected,
                        onUserTapped: onUserTapped,
                      ),
                  ],
                ),
              ),
          ],
        );
      }
    );
  }

  Widget _buildUserTile(BuildContext context) {
    return BaseStatelessConsumer(
      provider: projectDashboardProvider,
      builder: (context,provider,ref) {
        return InkWell(
          onTap: () {
            onUserTapped();
            onUserSelected(user);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Hierarchical connector lines
                if (depth > 0)
                  ...List.generate(depth, (index) {
                    final isLastAtIndex =
                        index < isLastAtLevel.length && isLastAtLevel[index];
                    final isCurrentLevel = index == depth - 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 20,
                        child: CustomPaint(
                          painter: _HierarchyLinePainter(
                            isLast: isLastAtIndex,
                            isCurrentLevel: isCurrentLevel,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    );
                  }),

                // Profile Image
                GestureDetector(
                  onTap: () {
                    ProfileImageDialog.show(
                      context: context,
                      imageUrl: user.userProfileImageUrl ?? "",
                      userName: user.userName ?? "User",
                    );
                  },
                  child: CachedNetworkImageWidget(
                    imageUrl: user.userProfileImageUrl ?? "",
                    size: 40,
                    userName: isResetUser ? "M E" : (user.userName ?? ""),
                  ),
                ),
                const SizedBox(width: 12),

                // Name
                Row(
                  children: [
                    Text(
                      user.userName ?? '',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    if (!isResetUser && user.to_docount != 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${user.to_docount ?? "0"}",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),


                  ],
                ),

                Spacer(),
                // To-Do Badge (not for reset user)

                // Expand/Collapse icon (only if has children and not reset user)
                if (hasChildren && !isResetUser)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        final provider =
                        ProviderScope.containerOf(context)
                            .read(projectDashboardProvider);
                        provider.changeHierarchyUsersExpansion(user.userId ?? 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          provider.userHierarchyModel.firstWhere((item){return item.userId == user.userId;}).isExpanded
                              ? Icons.expand_less : Icons.arrow_forward_ios,
                          size: provider.userHierarchyModel.firstWhere((item){return item.userId == user.userId;}).isExpanded
                              ?20 :15,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  )
                else if (!isResetUser)
                // Placeholder for alignment
                  const SizedBox(width: 28),
              ],
            ),
          ),
        );
      }
    );
  }
}

// Custom painter for hierarchical lines
class _HierarchyLinePainter extends CustomPainter {
  final bool isLast;
  final bool isCurrentLevel;
  final Color color;

  _HierarchyLinePainter({
    required this.isLast,
    required this.isCurrentLevel,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    if (isCurrentLevel) {
      if (isLast) {
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
      }
    } else {
      if (!isLast) {
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HierarchyLinePainter oldDelegate) {
    return oldDelegate.isLast != isLast ||
        oldDelegate.isCurrentLevel != isCurrentLevel ||
        oldDelegate.color != color;
  }
}