import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_service_request_usecase.dart';
import 'package:interior_design/presentation/provider/call_tracker/add_service_request_provider.dart';

class ReassignEngineerProvider extends AddServiceRequestProvider{

  CallTicketModel? selectedTicket;
  ServiceTaskModel? task;
  TextEditingController reassignEngineerController = TextEditingController();
  TextEditingController closureDateCtrl = TextEditingController();
  CommonMasterModel? selectedReassignEngineer;
  bool isAssignMode = false;
  String? selectedTargetClosureDate;

  Future<void> initState({Map<String, dynamic>? extra}) async {
    selectedTicket = null;
    isAssignMode = false;
    selectedTargetClosureDate = null;
    closureDateCtrl.clear();
    if (extra != null && extra['currentTicket'] != null) {
      selectedTicket = extra['currentTicket'];
    }
    if (extra != null && extra['task'] != null) {
      task = extra['task'];
    }
    if (extra != null && extra['isAssignMode'] == true) {
      isAssignMode = true;
    }
    fetchAllUserByDepartment();
    notifyListeners();
  }

  // Set selected engineer
  void setReassignedEngineer(CommonMasterModel engineer) {
    selectedReassignEngineer = engineer;
    reassignEngineerController.text = engineer.name;
    notifyListeners();
  }



  Future<void> reassignEngineer({required Function() onSuccess, required Function(String exception) onFailure}) async{
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddServiceRequestUsecase().reassignEngineer(
      ticketId: task?.id ?? 0,
      assignedUsedId: selectedReassignEngineer?.id ?? 0,
      lastModDate: task?.lastModDate ?? "",
      targetClosureDate: taskTargetClosureDate,
      onRequestSuccess: (){
        onSuccess();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (e){
        onFailure(e.toString());
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
      },
    );
  }

}