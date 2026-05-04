
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';

class ObservationDetailCommonHeader extends StatelessWidget {
  final String projectName;
  final String observer;
  final String transNo;
  final String selectedDate;
  final String profileUrl;
  final String createdLabel;
  final String statusLabel;
  final String? observationStatusDate;

  const ObservationDetailCommonHeader({

    super.key,
    required this.projectName,
    required this.observer,
    required this.transNo,
    required this.selectedDate,
    required this.profileUrl,
    required this.createdLabel,
    required this.statusLabel,
    this.observationStatusDate
  });

  @override
  Widget build(BuildContext context) {
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
                projectName,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Profile and details section
        Column(
          children: [

            GestureDetector(
              onTap: () {
                ProfileImageDialog.show(context: context,
                  imageUrl:profileUrl,
                  userName: observer,);

              },
              child:CachedNetworkImageWidget(
                imageUrl: profileUrl ?? "",
                size: 80,
                userName: observer,
              ),
            ),
            const SizedBox(height: 8),

            // Owner
            Text(statusLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            // Text(observationStatusDate ?? "", ),

            // Created by

            const Divider(indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            Text(createdLabel,
                style: Theme.of(context).textTheme.titleLarge
            ),



            const SizedBox(height: 4),

            // Transaction number
            Text(
              transNo,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 4),

            // Selected date
            Text(
              selectedDate,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
