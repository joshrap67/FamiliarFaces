class ApiResult<T> {
  String? errorMessage;
  T? data;

  bool success() => data != null;

  ApiResult({this.errorMessage, this.data});

  @override
  String toString() {
    return 'ApiResult{data: $data, isSuccess: ${success()}, errorMessage: $errorMessage}';
  }
}
