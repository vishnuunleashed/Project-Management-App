import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';

class MyScheduleProvider extends BaseProvider{

  //Filter section
  DateTime projectScheduleDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime projectScheduleDateTo = DateTime.now();
  DateTime? tempProjectScheduleDateFrom;
  DateTime? tempProjectScheduleDateTo;
  bool? tempIsShowAllProjectSchedule;
  bool isShowAllProjectSchedule = true;
  bool projectScheduleRangeFilterApplied = false;
  DateRangeModel? selectedProjectScheduleRange;
  String? selectedProjectScheduleRangeLabel;

  void setIsShowAllProjectSchedule(){
    isShowAllProjectSchedule = tempIsShowAllProjectSchedule ?? true;
    notifyListeners();
  }

  void changeIsShowAllProjectSchedule(bool value){
    tempIsShowAllProjectSchedule = value;
    projectScheduleDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    projectScheduleDateTo = DateTime.now();

    notifyListeners();
  }

  void setProjectScheduleRangeFilterApplied(bool value){
    projectScheduleRangeFilterApplied = value;
    if(value == false){
      selectedProjectScheduleRange = null;
      selectedProjectScheduleRangeLabel = "";
    }
    notifyListeners();
  }

  void changeProjectScheduleDateTo(DateTime date) {
    tempProjectScheduleDateTo = date;
    notifyListeners();
  }

  void changeProjectScheduleDateFrom(DateTime date) {
    tempProjectScheduleDateFrom = date;
    notifyListeners();
  }

  void setProjectScheduleFilterDateField(){
    if(tempProjectScheduleDateFrom != null) {
      projectScheduleDateFrom = tempProjectScheduleDateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
    if(tempProjectScheduleDateTo != null) {
      projectScheduleDateTo = tempProjectScheduleDateTo ?? DateTime.now();
    }
    notifyListeners();
  }

  void clearObservationFilter({required bool isFromClearButton,bool isFromRangeFilter = false}) {
    if(isFromClearButton) {
      projectScheduleDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      projectScheduleDateTo = DateTime.now();
      tempProjectScheduleDateFrom = null;
      tempProjectScheduleDateTo = null;
      isShowAllProjectSchedule = true;
      tempIsShowAllProjectSchedule = null;
      if(isFromRangeFilter){
        selectedProjectScheduleRange = null;
        projectScheduleRangeFilterApplied = false;
        selectedProjectScheduleRangeLabel = "";
      }
    }
    else{
      tempProjectScheduleDateFrom = null;
      tempProjectScheduleDateTo = null;
      tempIsShowAllProjectSchedule = null;
    }
    notifyListeners();
  }
}