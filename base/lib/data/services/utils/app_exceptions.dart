class AppException implements Exception {
  final String message;

  AppException(this.message);

  // Factory constructor to handle the result checking
  factory AppException.fromResult(Map<String, dynamic> result) {
    return AppException(result["statusMessage"] ?? "Unknown error");
  }

  @override
  String toString() {
    return message;
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message ?? "Error During Communication");

  factory FetchDataException.fromResult(Map<String, dynamic> result) {
    return FetchDataException(result["statusMessage"] ?? "Error During Communication");
  }
}

class BadRequestException extends AppException {
  BadRequestException([String? message])
      : super(message ?? "Invalid Request");

  factory BadRequestException.fromResult(Map<String, dynamic> result) {
    return BadRequestException(result["statusMessage"] ?? "Invalid Request");
  }
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message])
      : super(message ?? "Unauthorised");

  factory UnauthorisedException.fromResult(Map<String, dynamic> result) {
    return UnauthorisedException(result["statusMessage"] ?? "Unauthorised");
  }
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(message ?? "Invalid Input");

  factory InvalidInputException.fromResult(Map<String, dynamic> result) {
    return InvalidInputException(result["statusMessage"] ?? "Invalid Input");
  }
}

class UnNamedMessage extends AppException {
  UnNamedMessage([String? message])
      : super(message ?? "");

  factory UnNamedMessage.fromResult(Map<String, dynamic> result) {
    return UnNamedMessage(result["statusMessage"] ?? "");
  }
}

class DataBaseException extends AppException {
  DataBaseException([String? message])
      : super(message ?? "Database Exception");

  factory DataBaseException.fromResult(Map<String, dynamic> result) {
    return DataBaseException(result["statusMessage"] ?? "Database Exception");
  }
}

class PlatFormException extends AppException {
  PlatFormException([String? message])
      : super(message ?? "Platform Exception");

  factory PlatFormException.fromResult(Map<String, dynamic> result) {
    return PlatFormException(result["statusMessage"] ?? "Platform Exception");
  }
}

