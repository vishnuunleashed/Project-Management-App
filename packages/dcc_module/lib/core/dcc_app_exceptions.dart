/// Custom exception handling for the DCC module.
class DccException implements Exception {
  final String message;

  DccException(this.message);

  factory DccException.fromResult(Map<String, dynamic> result) {
    return DccException(result["statusMessage"] ?? "Unknown error");
  }

  @override
  String toString() => message;
}

class DccFetchDataException extends DccException {
  DccFetchDataException([String? message])
      : super(message ?? "Error During Communication");

  factory DccFetchDataException.fromResult(Map<String, dynamic> result) {
    return DccFetchDataException(result["statusMessage"] ?? "Error During Communication");
  }
}

class DccBadRequestException extends DccException {
  DccBadRequestException([String? message])
      : super(message ?? "Invalid Request");

  factory DccBadRequestException.fromResult(Map<String, dynamic> result) {
    return DccBadRequestException(result["statusMessage"] ?? "Invalid Request");
  }
}

class DccUnauthorisedException extends DccException {
  DccUnauthorisedException([String? message])
      : super(message ?? "Unauthorised");

  factory DccUnauthorisedException.fromResult(Map<String, dynamic> result) {
    return DccUnauthorisedException(result["statusMessage"] ?? "Unauthorised");
  }
}

class DccInvalidInputException extends DccException {
  DccInvalidInputException([String? message])
      : super(message ?? "Invalid Input");

  factory DccInvalidInputException.fromResult(Map<String, dynamic> result) {
    return DccInvalidInputException(result["statusMessage"] ?? "Invalid Input");
  }
}
