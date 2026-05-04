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
import 'package:base/data/repository/remote/generate_uuid_source..dart';
import 'package:base/domain/repository/generate_uuid_repo.dart';

class GetUUID{
  GenerateUUIDRepository generateUUIDRepository = GenerateUUIDRepositoryImpl();

  void callUUID({required onSuccess,required onFailure}){
    generateUUIDRepository.fetchUUID(onSuccess: onSuccess, onFailure: onFailure);
  }
  void clearUUID({required onSuccess,required onFailure}){
    generateUUIDRepository.clearUUID();
  }
}

