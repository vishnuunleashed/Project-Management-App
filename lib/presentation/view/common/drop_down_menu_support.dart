import 'package:flutter/material.dart';

class MenuItemModel {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuItemModel({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class ThreeDotMenu extends StatelessWidget {
  final List<MenuItemModel?> items;

  const ThreeDotMenu({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItemModel>(
      icon:  Icon(Icons.more_vert,color: Theme.of(context).iconTheme.color,),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (item) => item.onTap(),
      itemBuilder: (context) {
        return items
            .where((item) => item != null)       // ⛔ skip placeholder
            .map((item) {
          return PopupMenuItem<MenuItemModel>(
            value: item,
            child: ListTile(
              leading: Icon(item?.icon,color: Theme.of(context).iconTheme.color,),
              title: Text(item?.title??"",style: Theme.of(context).textTheme.labelLarge,),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 8,
            ),
          );
        }).toList();
      },
    );
  }
}
