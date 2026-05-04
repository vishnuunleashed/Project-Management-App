/*------------------------------------------------------------------------------
AUTHOR		    : Favas k
CREATED DATE	: 09/08/2025
PURPOSE		    :
MODULE/TOPIC	: IN0010-25
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:interior_design/presentation/provider/common_observation/base_observation_provider.dart';

class CloseObservationProvider extends BaseObservationProvider {
  bool get isUnassigned => observationList.isNotEmpty && observationList.first.logstatuscode == "UNASSIGNED";
  bool get hasClosingAuthority => observationList.isNotEmpty && observationList.first.closingauthorityyn == "Y";
  bool get isAssignedToUser => observationList.isNotEmpty && observationList.first.assignedto == userName;
  bool get canClose => hasClosingAuthority || isSuperUser;
  String get logStatus => observationList.isNotEmpty ? (observationList.first.logstatuscode ?? "") : "";
  String get toCloseYn => observationList.isNotEmpty ? (observationList.first.tocloseyn ?? "N") : "N";
  bool get isPending => observationstatuscode == "PENDING";

  bool get showClosedButton {
    if (!isPending) return false;
    if (isUnassigned && canClose) return true;
    if (isSuperUser && logStatus == 'SUBMIT') return true;
    if (!isSuperUser && toCloseYn == 'N' && isAssignedToUser && canClose) return true;
    if (!isSuperUser && toCloseYn == 'Y' && hasClosingAuthority) return true;
    return false;
  }

  bool get showAssignButton {
    if (!isPending) return false;
    if (isUnassigned && canClose) return true;
    return false;
  }

  bool get showRejectButton {
    if (!isPending) return false;
    if (isSuperUser && logStatus == 'SUBMIT') return true;
    if (!isSuperUser && toCloseYn == 'Y' && hasClosingAuthority) return true;
    return false;
  }

  bool get showRequestForClosureButton {
    if (!isPending) return false;
    if (isSuperUser && logStatus != 'SUBMIT' && logStatus != 'UNASSIGNED') return true;
    if (!isSuperUser && toCloseYn == 'N' && isAssignedToUser && !canClose) return true;
    return false;
  }

  bool get showActionButtons => showClosedButton || showAssignButton || showRejectButton || showRequestForClosureButton;

  String get appBarTitle {
    if (observationList.isEmpty || observationstatuscode == "CLOSED" || !showActionButtons) {
      return "View Observation";
    }
    if (showRequestForClosureButton) {
      return "Submit Observation";
    }
    return "Close Observation";
  }
}
