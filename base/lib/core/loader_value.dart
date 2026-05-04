/*------------------------------------------------------------------------------
AUTHOR		    : Karan Sreyas
CREATED DATE	: 07/08/2025
PURPOSE		    : Base
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------*/

import 'package:base/data/services/utils/app_exceptions.dart';

enum Loader { init, success, loading, error }

class LoadingStatus {
  Loader loader = Loader.init;
  String message;
  AppException? exception = AppException("Empty");
  LoadingStatus({this.loader = Loader.init,this.message = "Loading",this.exception});
}
