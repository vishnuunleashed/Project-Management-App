import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/home/swipable_side_bar.dart';

class DrawerParams{
  int? index;
  int projectId;
  String projectName;
  DrawerParams({
    required this.projectName,
    this.index,
    required this.projectId,

  });
}
class SideBarProvider extends BaseProvider{


  String drawerTitle = "Project Name";
  int? projectIndex;
  int projectId = 0;

  void setParameter(DrawerParams drawerParams){
    drawerTitle = drawerParams.projectName;
    projectId = drawerParams.projectId;
    projectIndex = drawerParams.index;
    notifyListeners();
  }

  bool isDrawerOpened = false;

  void onEndDrawerChange(bool opened){
    isDrawerOpened = opened;
    if(projectIndex != null){
      ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context).read(homeProvider).changeExpanded(projectIndex??0);
    }
    notifyListeners();
  }
}