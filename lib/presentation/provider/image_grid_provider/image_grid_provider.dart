import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';

class ImageGridProvider extends ProjectScheduleProvider{


  ScrollController gridScrollController = ScrollController();

  void setParameterForImages(int index){
    gridScrollController.jumpTo(double.parse(index.toString()));

  }

}