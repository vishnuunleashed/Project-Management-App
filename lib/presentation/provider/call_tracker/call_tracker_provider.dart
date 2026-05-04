import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:intl/intl.dart';

import 'dashboard_filter_provider.dart';

class CallTrackerProvider extends BaseProvider {

  // Data lists
  List<CallTicketModel> _tickets = [];
  List<StatusModel> _statusOptions = [];
  List<TypeOptionModel> _typeOptions = [];


  String _ticketNoFilter = '';

  int _start = 0;
  int _limit = 10;
  int _totalRecords = 0;
  bool _isLoadingMore = false;

  List<CallTicketModel> get tickets => _tickets;
  List<StatusModel> get statusOptions => _statusOptions;
  List<TypeOptionModel> get typeOptions => _typeOptions;
  String get ticketNoFilter => _ticketNoFilter;
  int get totalRecords => _totalRecords;



  bool get isFiltered =>
      selectedEngineer != null ||
          selectedStatus != null ||
          selectedType?.code != "todo" ||
          _ticketNoFilter.isNotEmpty;

  StatusModel? selectedStatus;
  TypeOptionModel? selectedType;
  EngineerModel? selectedEngineer;
  bool isProjectCoordinator = false;
  int loggedInUserId = 0;
  bool isSuperUser = false;
  DashboardFilterProvider? filterProvider;

  Future<void> initialize() async {
    isProjectCoordinator = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PCO";
    loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    _start = 0;
    _limit = 10;
    selectedEngineer = null;
    selectedStatus = null;
    statusFromGraph = "";
    _ticketNoFilter = '';
    scrollController = ScrollController();

    _loadEngineers();
    _loadStatusOptions();
    _loadTypeOptions();
    fetchClientLists();
    fetchCityLists();
    fetchPriorityLists();

    loadTickets(changeStart: true);
    _setupScrollListener();

  }

  Future<void> refreshWithFilters() async {
    isProjectCoordinator = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PCO";
    loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);

    loadTickets();
  }

  ScrollController scrollController = ScrollController();

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent)  {
        if(statusFromGraph.isNotEmpty){
          _loadMoreTicketsFromGraph();
        }else{
          _loadMoreTickets();
        }

      }
    });
  }

  void changeStatus(StatusModel status) {
    selectedStatus = status;
    notifyListeners();
  }

  void loadTicketsFromDashboard(StatusModel status) {
    statusFromGraph = "";
    _start = 0;
    _limit = 10;
    selectedEngineer = null;
    _ticketNoFilter = '';
    _loadStatusOptions();
    selectedStatus = status;
    selectedType =  (status.code == "ASGN_PENDING") ? typeOptions.firstWhere((item){ return item.code == "todo";})  : typeOptions.firstWhere((item){ return item.code == "all";});
    if((status.code == "ASGN_PENDING")){
      selectStatus(["Assignment Pending"]);
    }
    loadTickets(changeStart: true);
    notifyListeners();
  }

  String siteName = '';
  loadTicketByClient(String clientName,String siteName){
    this.siteName = siteName;
    selectClient([clientName]);
    loadTickets(changeStart: true);
  }



  void changeType(TypeOptionModel type) {
    selectedType = type;
    notifyListeners();
  }


  void changeEngineer(EngineerModel engineer) {
    selectedEngineer = engineer;
    notifyListeners();
  }



  // Load engineers from API
  Future<void> _loadEngineers() async {
    CallTrackerUseCase().fetchDepartmentFilter(
        onRequestSuccess: (result){
          engineerList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });

  }

  List<CommonMasterModel> clientList = [];
  void fetchClientLists(){
    CallTrackerUseCase().fetchClientLists(
        onRequestSuccess: (result){
          clientList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<CommonMasterModel> selectedClientList = [];

  List<String> selectedClientString = [];
  void selectClient(List<String> selectedNames) {
    sitesList = [];
    selectedSitesString = [];
    selectedSitesList = [];
    selectedClientString = selectedNames;
    selectedClientList = clientList
        .where((client) => selectedNames.contains(client.clientname))
        .toList();
    notifyListeners();
    if(selectedClientList.isNotEmpty) {
      fetchSiteLists();
    }
  }

  void removeSelectedClient(String name) {
    sitesList = [];
    selectedClientString.remove(name);
    selectedClientList.removeWhere((user) => user.clientname == name);
    if(selectedClientList.isNotEmpty) {
      fetchSiteLists();
    }
    else{
      sitesList = [];
      selectedSitesList = [];
      selectedSitesString = [];
    }
    notifyListeners();
  }

  List<CommonMasterModel> selectedCityList = [];
  List<CommonMasterModel> cityList = [];
  void fetchCityLists(){
    CallTrackerUseCase().fetchCityLists(
        onRequestSuccess: (result){
          cityList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<String> selectedCityString = [];
  void selectCity(List<String> selectedNames) {
    selectedCityString = selectedNames;
    selectedCityList = cityList
        .where((city) => selectedNames.contains(city.cityname))
        .toList();
    notifyListeners();
  }

  void removeSelectedCity(String name) {
    selectedCityString.remove(name);
    selectedCityList.removeWhere((user) => user.cityname == name);
    notifyListeners();
  }
  /// date fields
  DateTime? dateFromFilter;
  DateTime? dateToFilter;

  void changeDateFromFilter(DateTime date) {
    dateFromFilter = date;
    notifyListeners();
  }

  void changeDateToFilter(DateTime date) {
    dateToFilter = date;
    notifyListeners();
  }
  //Priority
  List<CommonMasterModel> selectedPriorityList = [];
  List<CommonMasterModel> priorityList = [];
  List<String> selectedPriorityString = [];
  void fetchPriorityLists(){
    CallTrackerUseCase().fetchPriority(
        onRequestSuccess: (result){
          priorityList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void selectPriority(List<String> selectedNames) {
    selectedPriorityString = selectedNames;
    selectedPriorityList = priorityList
        .where((priority) => selectedNames.contains(priority.description))
        .toList();
    notifyListeners();
  }

  void removeSelectedPriority(String name) {
    selectedPriorityString.remove(name);
    selectedPriorityList.removeWhere((priority) => priority.description == name);
    notifyListeners();
  }

  // Status section

  List<String> selectedStatusString = [];
  List<StatusModel> statusList = [];
  List<StatusModel> selectedStatusList = [];
  void selectStatus(List<String> selectedNames) {
    selectedStatusString = selectedNames;
    selectedStatusList = statusList
        .where((status) => selectedNames.contains(status.description))
        .toList();
    notifyListeners();
  }

  void removeSelectedStatus(String name) {
    selectedStatusString.remove(name);
    selectedStatusList.removeWhere((status) => status.description == name);
    notifyListeners();
  }

  //Engineer section
  // Status section

  List<String> selectedEngineerString = [];
  List<EngineerModel> engineerList = [];
  List<EngineerModel> selectedEngineerList = [];
  void selectEngineer(List<String> selectedNames) {
    selectedEngineerString = selectedNames;
    selectedEngineerList = engineerList
        .where((engineer) => selectedNames.contains(engineer.name))
        .toList();
    notifyListeners();
  }

  void removeSelectedEngineer(String name) {
    selectedEngineerString.remove(name);
    selectedEngineerList.removeWhere((status) => status.name == name);
    notifyListeners();
  }

  /// Site section
  List<String> selectedSitesString = [];
  List<SiteModel> sitesList = [];
  List<SiteModel> selectedSitesList = [];
  void selectSites(List<String> selectedNames) {
    selectedSitesString = selectedNames;
    selectedSitesList = sitesList
        .where((site) => selectedNames.contains(site.siteName))
        .toList();
    notifyListeners();
  }

  void removeSelectedSites(String name) {
    selectedSitesString.remove(name);
    selectedSitesList.removeWhere((site) => site.siteName == name);
    notifyListeners();
  }

  void fetchSiteLists(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchSiteLists(
        clientList: selectedClientList,
        onRequestSuccess: (result){
          selectedSitesList = [];
          selectedSitesString = [];
          sitesList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }



  // Load status options from API
  Future<void> _loadStatusOptions() async {
    CallTrackerUseCase().fetchStatusTypes(
        onRequestSuccess: (statusType){
          _statusOptions = statusType;
          _statusOptions.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
          statusList = statusType;
          statusList.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });

  }

  // Load type options (local data)
  Future<void> _loadTypeOptions() async {
    _typeOptions = [
      TypeOptionModel(id: 1, name: "All Tickets", code: "all"),
      TypeOptionModel(id: 2, name: "Created by Me", code: "my"),
      TypeOptionModel(id: 88, name: "Assigned Tickets", code: "todo"),
    ];
    selectedType = typeOptions.firstWhere((item){ return item.code == "todo";});
    notifyListeners();
  }

  void _loadMoreTickets() {
    // Prevent multiple simultaneous loads
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _start += _limit;

    loadTickets(changeStart: false).then((_) {
      _isLoadingMore = false;
      notifyListeners();
    });
  }

  void _loadMoreTicketsFromGraph() {
    // Prevent multiple simultaneous loads
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _start += _limit;

    loadTicketsFromGraph(changeStart: false).then((_) {
      _isLoadingMore = false;
      notifyListeners();
    });
  }
  // Update hasMore getter to be more accurate
  bool get hasMore => _tickets.length < _totalRecords;

  Future<void> loadTickets({bool changeStart = false}) async {
    if(changeStart){
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
      _tickets = [];
      _start = 0;
      _totalRecords = 0; // Reset total records too
    }


    CallTrackerUseCase().fetchCallTrackerInfo(
        start: _start,
        limit: _limit,
        ticketNo: _ticketNoFilter,
        refTableDataId: 0,
        engineers: selectedEngineerList,
        statuses: selectedStatusList,
        cities: selectedCityList,
        priorityList: selectedPriorityList,
        clientList: selectedClientList,
        sitesList: selectedSitesList,
        type: selectedType?.code ?? "",
        sitenames: siteName,
        dateFrom: (dateFromFilter != null ? DateFormat('dd-MM-yyyy').format(dateFromFilter!) : null) ?? "",
        dateTo: (dateToFilter != null ? DateFormat('dd-MM-yyyy').format(dateToFilter!) : null) ?? "",
        taskId: 0,
        onRequestSuccess: (result){
          if(_start == 0) {
            _tickets = result;
          } else {
            _tickets.addAll(result); // Use addAll instead of +=
          }

          // Update total records from response
          _totalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : _totalRecords;

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          notifyListeners();
        });
  }


  String flag = '';
  String statusFromGraph = '';
  int serviceClientId = 0;
  int userId = 0;
  void getParameter(Map<String,dynamic>? extra, DashboardFilterProvider filter){
    filterProvider = filter;
    filterProvider?.clearDetailFilter();
    if(extra == null){
      return;
    }
    flag = extra['flag']??"";
    serviceClientId = extra['clientId']??0;
    userId = extra['userId']??0;
    statusFromGraph = extra['statusFromGraph']??"";
    loadTicketsFromGraph();
  }
  Future<void> loadTicketsFromGraph({bool changeStart = false}) async {
    if(changeStart){
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
      _tickets = [];
      _start = 0;
      _totalRecords = 0; // Reset total records too
    }

    print("FUnction called -- fff");

    CallTrackerUseCase().fetchCallTrackerInfoFromGraphDashboard(
        start: _start,
        limit: _limit,
        ticketNo: _ticketNoFilter,
        refTableDataId: 0,
        status: statusFromGraph,
        userId: userId,
        serviceClientId: serviceClientId ?? 0,
        type: selectedType?.code ?? "",
        flag:flag,
        taskDashBoardSummaryFilter: filterProvider!.currentFilter,
        engineerId: filterProvider?.selectedEngineer?.id,
        reporterId: filterProvider?.selectedReporter?.id,
        coordinatorId: filterProvider?.selectedCoordinator?.id,
        onRequestSuccess: (result){
          if(_start == 0) {
            _tickets = result;
          } else {
            _tickets.addAll(result); // Use addAll instead of +=
          }

          // Update total records from response
          _totalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : _totalRecords;

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          notifyListeners();
        });
  }

  // Refresh tickets
  Future<void> refreshTickets() async {
    if(statusFromGraph.isNotEmpty){
      loadTicketsFromGraph();
    }else{
      loadTickets(changeStart: false);
    }

  }




  // Update ticket number filter
  void setTicketNoFilter(String ticketNo) {
    _ticketNoFilter = ticketNo;
    notifyListeners();
  }



  // Clear all filters
  Future<void> clearFilters() async {
    selectedEngineer = null;
    selectedStatus = null;
    _ticketNoFilter = '';
    selectedClientString = [];
    selectedClientList = [];
    selectedCityString = [];
    dateFromFilter = null;
    dateToFilter = null;
    selectedCityList = [];
    selectedPriorityList = [];
    sitesList = [];
    selectedStatusList = [];
    selectedStatusString = [];
    selectedEngineerList = [];
    selectedEngineerString = [];
    selectedSitesList = [];
    selectedSitesString = [];
    siteName = "";
    _start = 0;
    if(selectedType?.code == "todo"){
      selectedType = typeOptions.firstWhere((item){ return item.code == "all";});
    }else{
      selectedType = typeOptions.firstWhere((item){ return item.code == "todo";});
    }
    await loadTickets(changeStart: false);
  }

  // Get status color
  Color getStatusColor(String? statusCode, BuildContext context) {
    if (statusCode == null) return Colors.grey;

    switch (statusCode) {
      case 'ASGN_PENDING':
        return bayaInfraPaleOrange;
      case 'ASSIGNED':
        return bayaInfraBlue600!;
      case 'IN_PROGRESS':
        return Theme.of(context).primaryColor;
      case 'CLOSE_PENDING':
        return bayaInfraAmber;
      case 'REVIEWED':
        return bayaInfraRed;
      case 'CLOSED':
        return bayaInfraGreen;
      case 'REJECTED':
        return bayaInfraLightRedColor;
      default:
        return Colors.grey;
    }
  }

  // Get priority color
  Color getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;

    if (priority.contains('1')) {
      return Colors.red;
    } else if (priority.contains('2')) {
      return Colors.orange;
    } else if (priority.contains('3')) {
      return bayaInfraPaleGreen;
    } else {
      return Colors.green;
    }
  }
}