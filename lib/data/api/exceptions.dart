class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(message, "Error During Communication: ");
}

class DataNotAvailableException extends AppException {
  DataNotAvailableException([String message])
      : super(message, "Data Not Available Error: ");
}
