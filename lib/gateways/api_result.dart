class ApiResult<T> {
  String? errorMessage;
  T? data;

  bool success() => data != null;

  ApiResult({this.errorMessage, this.data});
}
