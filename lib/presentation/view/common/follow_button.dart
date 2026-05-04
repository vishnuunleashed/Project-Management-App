import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowed;
  final bool isCritical;
  final bool isCC;
  final bool isBlocked; // NEW

  final VoidCallback onFollow;
  final VoidCallback onUnfollow;

  final String followTooltip;
  final String unfollowTooltip;
  final String criticalToolTip;
  final String blockedTooltip; // NEW
  final String ccTooltip; // NEW

  final double size;
  final Color? iconColor;
  final Axis axis;
  const FollowButton({
    Key? key,
    required this.isFollowed,
    required this.isCC,
    required this.isBlocked,        // NEW
    required this.onFollow,
    required this.onUnfollow,
    this.followTooltip = 'Followed',
    this.unfollowTooltip = 'Unfollowed',
    this.blockedTooltip = "Follow/unfollow disabled because you are the creator or observer of this support",
    this.ccTooltip ="You have been added in CC to this support request",
    this.size = 24,
    this.iconColor,
    this.isCritical = false,
    this.criticalToolTip = "Support is critical",
    this.axis = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> criticalKey = GlobalKey<TooltipState>();





    return Wrap(
      direction: axis,
      children: [
        Visibility(
          visible: false,
          child: Tooltip(
            key: UniqueKey(),
            message: blockedTooltip,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => tooltipKey.currentState?.ensureTooltipVisible(),
              child: IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.block,
                  size: size,
                  color: iconColor ?? Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: isCC,
          child: Tooltip(
            key: UniqueKey(),
            message: ccTooltip,
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.notifications_active,
                size: size,
                color: bayaInfraAmber,
              ),
            ),
          ),
        ),
        Visibility(
          visible: !isBlocked && !isCC,
          child: Tooltip(
            key: UniqueKey(),
            message: isFollowed ? followTooltip : unfollowTooltip,
            waitDuration: const Duration(milliseconds: 300),
            showDuration: const Duration(seconds: 2),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => tooltipKey.currentState?.ensureTooltipVisible(),
              child: IconButton(
                onPressed: isFollowed ? onUnfollow : onFollow,
                iconSize: size,
                icon: Icon(
                  isFollowed ? Icons.notifications_active : Icons.notifications_off,
                  color: isFollowed ? bayaInfraGreen : Theme.of(context).iconTheme.color,
                  size: size,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: false,
          child: Tooltip(
            key: UniqueKey(),
            message: criticalToolTip,
            waitDuration: const Duration(milliseconds: 300),
            showDuration: const Duration(seconds: 2),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => criticalKey.currentState?.ensureTooltipVisible(),
              child: IconButton(
                onPressed: null,
                iconSize: size,
                icon: Icon(
                  Icons.priority_high,
                  color: bayaInfraRed,
                  size: size,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
