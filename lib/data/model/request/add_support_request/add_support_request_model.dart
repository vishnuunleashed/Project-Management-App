/*-------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 18//08/2025
PURPOSE		    : IN0011-25
MODULE/TOPIC	: Save Model
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';

class AddSupportRequestModel {
  int id = 0;
  int? optionId;
  int parentOptionId = 0;
  String transDate = "";
  String requestDescription = "";
  int projectId = 0;
  int? escalatedById;
  int dependencyDepId = 0;
  String targetClosureDate = "";
  String? remarks;
  int selectedOwnerId;
  int? prevlogid;
  int? supportTypeId;
  int? taskId;
  int? materialTypeId;
  int? recordId;
  bool fromTask;
  bool fromAdditionalMat;
  bool isCritical;
  bool supportEdit;
  List<OwnerModel> observers;
  bool fromCallTracker;
  int? callTrackerTypeId;
  int? actionItemId;
  bool isFromMom;
  List<EmployeeModel> observersFromUser;


  AddSupportRequestModel({
    this.id = 0,
    this.supportEdit = false,
    this.optionId,
    this.prevlogid,
    required this.parentOptionId,
    required this.transDate,
    required this.requestDescription,
    required this.projectId,
    this.escalatedById,
    required this.dependencyDepId,
    required this.targetClosureDate,
    this.remarks,
    required this.selectedOwnerId,
    this.fromTask = false,
    this.fromAdditionalMat = false,
    this.supportTypeId,
    this.taskId,
    this.isCritical = false,
    this.observers = const [],
    this.materialTypeId,
    this.recordId,
    this.fromCallTracker = false,
    this.callTrackerTypeId,
    this.observersFromUser = const [],
    this.actionItemId,
    this.isFromMom = false
  });
}