import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:intl/intl.dart' as intl;

class SupportDetailCommonHeader extends StatelessWidget {
  final String? projectName;
  final String? transNo;
  final String? expectedClosureDate; // raw date string input
  final String toUserProfileUrl;
  final String? assignedTo;
  final String? loginUserName;

  final String createdLabel;
  final String statusLabel;

  const SupportDetailCommonHeader({
    super.key,
    required this.projectName,
    required this.assignedTo,
    required this.transNo,
    required this.expectedClosureDate,
    required this.toUserProfileUrl,
    required this.createdLabel,
    required this.statusLabel,
    required this.loginUserName
  });

  /// 🔹 Formats the date according to the given rules
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return "";

    final now = DateTime.now();
    if (parsedDate.year == now.year) {
      // Same year → don't show year
      return intl.DateFormat.MMMd().format(parsedDate); // e.g. Oct 14
    } else {
      // Different year → show year
      return intl.DateFormat.yMMMd().format(parsedDate); // e.g. Oct 14, 2024
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(expectedClosureDate);

    return Column(
      children: [
        // Project name
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                projectName ?? "",
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Profile section
        Column(
          children: [
            GestureDetector(
                    onTap: () {
                      ProfileImageDialog.show(context: context,
                        imageUrl: toUserProfileUrl,
                        userName:  assignedTo,);


                    },
                    child: CachedNetworkImageWidget(
                      imageUrl: toUserProfileUrl ,
                      size:80,
                      userName: (assignedTo == "You") ? (loginUserName ?? "") : (assignedTo??""),
                    ),
                  ),
            const SizedBox(height: 8),

            // Created By
            Text(
              statusLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 4),
            const Divider(indent: 16, endIndent: 16),
            const SizedBox(height: 4),

            // To

            Text(
              createdLabel,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Transaction number
            Text(
              transNo ?? "",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 4),

            // Date (auto formatted)
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
