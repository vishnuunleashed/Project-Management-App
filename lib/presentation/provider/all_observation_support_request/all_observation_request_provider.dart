import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/presentation/provider/common_observation/base_all_observation_provider.dart';


class AllObservationRequestProvider extends BaseAllObservationProvider{


  void changeObsDateFrom(DateTime date) {
    tempObsDateFrom = date;
    notifyListeners();
  }

  void changeObsDateTo(DateTime date) {
    tempObsDateTo = date;
    notifyListeners();
  }

  void changeIsShowAllObs(bool value){
    tempIsShowAllObs = value;
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    obsDateTo = DateTime.now();

    notifyListeners();
  }

  void setIsShowAllObs(){
    isShowAllObs = tempIsShowAllObs ?? true;
    notifyListeners();
  }

  void setObsFilterDateField(){
    if(tempObsDateFrom != null) {
      obsDateFrom = tempObsDateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
    if(tempObsDateTo != null) {
      obsDateTo = tempObsDateTo ?? DateTime.now();
    }
    notifyListeners();
  }

  void setObsRangeFilterApplied(bool value){
    obsRangeFilterApplied = value;
    if(value == false){
      selectedObsRange = null;
      selectedObsRangeLabel = "";
    }
    notifyListeners();
  }
  //Common filter Functions
  void setThisWeek({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.thisWeek();
      selectedObsRangeLabel = "This Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setLastWeek({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.lastWeek();
      selectedObsRangeLabel = "Last Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setNextWeek({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.nextWeek();
      selectedObsRangeLabel = "Next Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setThisMonth({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.thisMonth();
      selectedObsRangeLabel = "This Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setLastMonth({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.lastMonth();
      selectedObsRangeLabel = "Last Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setNextMonth({required bool isSupport}) {
      observationList = [];
      selectedObsRange = DateRangeHelper.nextMonth();
      selectedObsRangeLabel = "Next Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    notifyListeners();
  }

}