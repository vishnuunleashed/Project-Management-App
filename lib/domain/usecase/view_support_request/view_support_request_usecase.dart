/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 20/08/2025
PURPOSE		    :
MODULE/TOPIC	: CloseSupportRequestUseCase
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/request/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/domain/repository/close_support_request/close_support_request_repository.dart';
import 'package:interior_design/domain/usecase/base_usecase/base_support_usecase.dart';
import 'package:interior_design/domain/usecase/close_support_request/close_support_request_usecase.dart';

class ViewSupportRequestUseCase extends BaseCloseSupportRequestUseCase{

  factory ViewSupportRequestUseCase() => _instance;
  static final ViewSupportRequestUseCase _instance =  ViewSupportRequestUseCase._internal();

  ViewSupportRequestUseCase._internal();


}