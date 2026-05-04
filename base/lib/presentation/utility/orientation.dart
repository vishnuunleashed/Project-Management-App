
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:flutter/material.dart';

bool isPortraitMode(){
  if((MediaQuery.of(NavigatorKey.navKey.currentState!.context).orientation)==Orientation.portrait){
    return true;
  }
  return false;
}