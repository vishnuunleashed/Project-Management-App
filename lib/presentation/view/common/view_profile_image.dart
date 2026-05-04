import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageDialog {
  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
    String? userName,
    Color? headerBackgroundColor,
    Color barrierColor = Colors.black54,
    Duration transitionDuration = const Duration(milliseconds: 200),
    double dialogWidthFraction = 0.9,
    double maxImageHeightFraction = 0.7,
    Widget? placeholderIcon,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            alignment: Alignment.center,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(40),
            child: GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username bar
                  if (userName != null)
                    Container(
                      width: MediaQuery.of(context).size.width * dialogWidthFraction,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: headerBackgroundColor ?? Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Image
                  Container(
                    width: MediaQuery.of(context).size.width * dialogWidthFraction,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * maxImageHeightFraction,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: userName == null ? const Radius.circular(16) : Radius.zero,
                        topRight: userName == null ? const Radius.circular(16) : Radius.zero,
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                      color: Theme.of(context).cardColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                     imageUrl:  imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => _buildPlaceholder(context),
                      errorWidget: (context, url, error) => _buildPlaceholder(context),


                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.ease,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
  static Widget _buildPlaceholder(BuildContext context) {
    return Icon(
      Icons.person,
      size: 100,
      color: Colors.white,
    );
  }
}

// Usage example:
// ProfileImageDialog.show(
//   context: context,
//   imageUrl: provider.observationList[index].profileUrl ?? "",
//   userName: provider.observationList[index].observerName ?? "User",
//   headerBackgroundColor: bayaInfraGrey100,
// );