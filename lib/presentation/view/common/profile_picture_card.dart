import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';

import 'cached_image_view.dart';

class ProfileItem {
  final String name;
  final String profileUrl;
  final String profilePicSubtitle;

  ProfileItem({
    required this.name,
    required this.profileUrl,
    required this.profilePicSubtitle
  });
}

class GenericProfilePictureList extends StatelessWidget {
  final String title;
  final List<ProfileItem> items;
  final String? currentUserName;
  final ScrollController? scrollController;

  final double avatarSize;
  final double spacing;


  const GenericProfilePictureList({
    super.key,
    required this.title,
    required this.items,
    this.currentUserName,
    this.scrollController,
    this.avatarSize = 50,
    this.spacing = 16,


  });

  @override
  Widget build(BuildContext context) {
    final controller = scrollController ?? ScrollController();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Card(
        color: Theme
            .of(context)
            .cardColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8 ),
                child: Text(
                  title,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),


              // Scrollbar wrapper
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Scrollbar(
                  controller: controller,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 2,
                  radius: const Radius.circular(4),
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SizedBox(
                    height: avatarSize + 35, // Avatar + Name text
                    child: ListView.builder(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing),
                          child: _buildTeamMember(context, item),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, ProfileItem item) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ProfileImageDialog.show(context: context,
              imageUrl: item.profileUrl,
              userName: item.name,);
          },
          child: CachedNetworkImageWidget(
            imageUrl: item.profileUrl ,
            size: 50,
            iconSize: 24,
            userName: item.name,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.profilePicSubtitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
