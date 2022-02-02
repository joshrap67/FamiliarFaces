class ApiResult<T> {
  String? errorMessage;
  T? data;

  bool success() => data != null;

  ApiResult({this.errorMessage, this.data});

  ApiResult.success(this.data);

  ApiResult.failure(this.errorMessage);

  @override
  String toString() {
    return 'ApiResult{data: $data, isSuccess: ${success()}, errorMessage: $errorMessage}';
  }
}
