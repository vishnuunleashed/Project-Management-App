import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/task_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/ticket_dashboard/service_tasks_provider.dart';
import 'package:interior_design/presentation/view/call_tracker/from_home/partials/service_task_filter.dart';

class TasksWiseTicketProvider extends ServiceTasksListProvider{
  
  int clientId = 0;
  String siteName = "";
  String status = "";
  String dashboardType = "";
  String dashboardSubType = "";
  int serviceUserId = 0;
  bool isFromDashboard = false;


  void initValuesFromHome(){
    selectedTaskFilter = TaskFilterDashboard.all;
    tasksTicket = [];
    taskTicketTempList = [];
    notifyListeners();
  }

  void setParameter(Map<String, dynamic>? extra) async {
    loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
    clientId = int.parse("${extra!['clientId']??0}");
    siteName = extra['siteName']??"";
    status = extra['status']??"";
    isFromDashboard = extra['isFromDashboard']??false;
    serviceTrackerHeader = extra['header'];
    serviceTrackerSubHeader = extra['subHeader'];
    if(isFromDashboard){
      dashboardType = extra['dashboardType']??"";
      dashboardSubType = extra['dashboardSubType']??"";
      serviceUserId = extra['serviceUserId'] ?? 0;
      loadTasksFromDashboard();
    }
    else{
      loadTasksFromHome();
    }


  }

  List<TaskModel> tasksTicket = [];
  List<TaskModel> taskTicketTempList = [];
  Future<void> loadTasksFromHome({bool changeStart = false}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchTasksByClientAndLocation(
        clientId: clientId,
        siteName: siteName,
        onRequestSuccess: (result){
          if(status != ""){
            tasksTicket = result.where((item) {
              return item.status == status;
            }).toList();
          }else{
            tasksTicket = result;
          }

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          notifyListeners();
        });
  }

  Future<void> loadTasksFromDashboard() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchTasksFromDashboard(
      clientId: clientId,
        type: dashboardType,
        subType: dashboardSubType,
        serviceUserId: serviceUserId,
        onRequestSuccess: (result){
            tasksTicket = result;
            taskTicketTempList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          notifyListeners();
        });
  }

  TaskFilterDashboard selectedTaskFilter = TaskFilterDashboard.all;
  void changeFilter(TaskFilterDashboard filter) {
    selectedTaskFilter = filter;
    _applyFilter();
    notifyListeners();
  }
  void _applyFilter() {
    switch (selectedTaskFilter) {
      case TaskFilterDashboard.assignment_pending:
        tasksTicket = taskTicketTempList
            .where((e) =>
        e.statusCode == "ASSIGNMENT_PENDING" ||
            e.statusCode == "PENDING")
            .toList();
        break;

      case TaskFilterDashboard.assigned:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "ASSIGNED").toList();
        break;

      case TaskFilterDashboard.accepted:
        tasksTicket = taskTicketTempList
            .where((e) =>
        e.statusCode == "ACCEPTED" ||
            e.statusCode == "IN_PROGRESS")
            .toList();
        break;

      case TaskFilterDashboard.submitted:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "SUBMITTED").toList();
        break;

      case TaskFilterDashboard.send_back:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "SEND_BACK").toList();
        break;

      case TaskFilterDashboard.reviewed:
        tasksTicket = taskTicketTempList
            .where((e) =>
        e.statusCode == "REVIEWD" ||
            e.statusCode == "REVIEWED")
            .toList();
        break;

      case TaskFilterDashboard.closed:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "CLOSED").toList();
        break;

      case TaskFilterDashboard.rejected:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "REJECTED").toList();
        break;

      case TaskFilterDashboard.reopened:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "REOPENED").toList();
        break;

      case TaskFilterDashboard.cancelled:
        tasksTicket =
            taskTicketTempList.where((e) => e.statusCode == "CANCELLED").toList();
        break;

      case TaskFilterDashboard.all:
        tasksTicket = List.from(taskTicketTempList);
        break;
    }
  }

  int getCountForFilter(TaskFilterDashboard filter) {
    if (filter == TaskFilterDashboard.all) return taskTicketTempList.length;

    return taskTicketTempList.where((t) {
      final String status = (t.statusCode ?? '').toUpperCase();

      switch (filter) {
        case TaskFilterDashboard.assignment_pending:
          return status == "ASSIGNMENT_PENDING" || status == "PENDING";
        case TaskFilterDashboard.assigned:
          return status == "ASSIGNED";
        case TaskFilterDashboard.accepted:
          return status == "ACCEPTED" || status == "IN_PROGRESS";
        case TaskFilterDashboard.submitted:
          return status == "SUBMITTED";
        case TaskFilterDashboard.send_back:
          return status == "SEND_BACK";
        case TaskFilterDashboard.reviewed:
          return status == "REVIEWD" || status == "REVIEWED";
        case TaskFilterDashboard.closed:
          return status == "CLOSED";
        case TaskFilterDashboard.rejected:
          return status == "REJECTED";
        case TaskFilterDashboard.reopened:
          return status == "REOPENED";
        case TaskFilterDashboard.cancelled:
          return status == "CANCELLED";
        default:
          return false;
      }
    }).length;
  }

}