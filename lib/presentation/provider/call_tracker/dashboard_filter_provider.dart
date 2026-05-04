import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_service_request_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:intl/intl.dart';

class DashboardFilterProvider extends BaseProvider {
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController ticketController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  CommonMasterModel? selectedPriority;
  CommonMasterModel? selectedDashFilterCity;
  DateTime? dateFromDashFilter;
  DateTime? dateToDashFilter;
  List<CommonMasterModel> selDashFilterClientList = [];
  List<String> selDashFilterClientStr = [];
  List<CommonMasterModel> priorityList = [];
  List<CommonMasterModel> cityList = [];
  List<CommonMasterModel> clientList = [];

  // ── Single source of truth for filter model ──
  TaskDashBoardSummaryFilterModel get currentFilter =>
      TaskDashBoardSummaryFilterModel(
        ticketNo: ticketController.text,
        dateFrom: dateFromDashFilter == null
            ? null
            : DateFormat('dd-MM-yyyy').format(dateFromDashFilter!),
        dateTo: dateToDashFilter == null
            ? null
            : DateFormat('dd-MM-yyyy').format(dateToDashFilter!),
        priorityId: selectedPriority?.id,
        cityId: selectedDashFilterCity?.id,
        selDashFilterClientList: selDashFilterClientList,
      );

  void setSelectedPriority(CommonMasterModel priority) {
    selectedPriority = priority;
    priorityController.text = priority.description;
    notifyListeners();
  }

  void setSelectedDashFilterCity(CommonMasterModel city) {
    selectedDashFilterCity = city;
    cityController.text = city.cityname;
    notifyListeners();
  }

  void changeDateFromDashFilter(DateTime date) {
    dateFromDashFilter = date;
    notifyListeners();
  }

  void changeDateToDashFilter(DateTime date) {
    dateToDashFilter = date;
    notifyListeners();
  }

  void selectDashFilterClient(List<String> selectedNames) {
    selDashFilterClientStr = selectedNames;
    selDashFilterClientList = clientList
        .where((client) => selectedNames.contains(client.clientname))
        .toList();
    notifyListeners();
  }

  void removeDashFilterClient(String name) {
    selDashFilterClientStr.remove(name);
    selDashFilterClientList.removeWhere((user) => user.clientname == name);
    notifyListeners();
  }

  void clearFilters() {
    dateFromDashFilter = null;
    dateToDashFilter = null;
    ticketController.clear();
    priorityController.clear();
    cityController.clear();
    selectedPriority = null;
    selectedDashFilterCity = null;
    selDashFilterClientList.clear();
    selDashFilterClientStr.clear();
    engineerController.clear();
    selectedEngineer = null;
    reporterController.clear();
    coordinatorController.clear();

    selectedReporter = null;
    selectedCoordinator = null;
    notifyListeners();
  }

  void fetchServicePriority() {
    AddServiceRequestUsecase().fetchServicePriority(
        onRequestSuccess: (result) {
          priorityList = result;
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(
              loader: Loader.error, exception: exception));
        });
  }

  void fetchCityLists() {
    CallTrackerUseCase().fetchCityLists(
        onRequestSuccess: (result) {
          cityList = result;
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(
              loader: Loader.error, exception: exception));
        });
  }

  void fetchClientLists() {
    CallTrackerUseCase().fetchClientLists(
        onRequestSuccess: (result) {
          clientList = result;
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(
              loader: Loader.error, exception: exception));
        });
  }

  List<CommonMasterModel> engineerList = [];
  List<CommonMasterModel> reporterList = [];
  List<CommonMasterModel> coordinatorList = [];

  Future<void> fetchEngineers() async {
    AddServiceRequestUsecase().fetchAllUserByDepartment(
      onRequestSuccess: (List<CommonMasterModel> result){
        engineerList = result;
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
        );

      },
    );
  }

  Future<void> fetchReporters() async {
    AddServiceRequestUsecase().fetchAllUserByDepartment(
      onRequestSuccess: (List<CommonMasterModel> result){
        reporterList = result;
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
        );

      },
    );
  }

  Future<void> fetchCoordinator() async {
    AddServiceRequestUsecase().fetchUserByDepartment(
      departmentCode: "PCO",
      onRequestSuccess: (result) {
        coordinatorList = result;
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
        );
      },
    );
  }
  final TextEditingController engineerController = TextEditingController();
  CommonMasterModel? selectedEngineer;
  final TextEditingController reporterController = TextEditingController();
  final TextEditingController coordinatorController = TextEditingController();

  CommonMasterModel? selectedReporter;
  CommonMasterModel? selectedCoordinator;

  void setSelectedReporter(CommonMasterModel reporter) {
    selectedReporter = reporter;
    reporterController.text = reporter.name ?? "";
    notifyListeners();
  }

  void setSelectedCoordinator(CommonMasterModel coordinator) {
    selectedCoordinator = coordinator;
    coordinatorController.text = coordinator.name ?? "";
    notifyListeners();
  }

  void setSelectedEngineer(CommonMasterModel engineer) {
    selectedEngineer = engineer;
    engineerController.text = engineer.name ?? ""; // adjust field name
    notifyListeners();
  }

  void clearDetailFilter (){
    engineerController.clear();
    selectedEngineer = null;
    reporterController.clear();
    coordinatorController.clear();

    selectedReporter = null;
    selectedCoordinator = null;
    notifyListeners();

  }
}

class TaskDashBoardSummaryFilterModel{
  String? ticketNo;
  String? dateFrom;
  String? dateTo;
  int? cityId;
  int? priorityId;
  List<CommonMasterModel> selDashFilterClientList;
  TaskDashBoardSummaryFilterModel({required this.ticketNo, required this.dateFrom, required this.dateTo, required this.priorityId, required this.cityId, required this.selDashFilterClientList});
}

