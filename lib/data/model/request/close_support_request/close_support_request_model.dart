/*-------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 21//08/2025
PURPOSE		    : IN0011-25
MODULE/TOPIC	: CloseSupportRequest Save Model
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

class CloseSupportRequestModel {
  int? id;
  int? optionid;
  int? projectid;
  String? requestdescription;
  int? dependencydepartmentid;
  String? targetclosuredate;
  int? escalatedto;
  String? status;
  String? remarks;
  int? prevlogid;

  CloseSupportRequestModel({
    this.status = "",
    this.dependencydepartmentid,
    this.escalatedto,
    this.id = 0,
    this.optionid,
    this.projectid,
    this.prevlogid,
    this.remarks = "",
    this.requestdescription = '',
    this.targetclosuredate = ''
  });
}