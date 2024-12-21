class ApiResponse {
  dynamic response;
  String? error;

  ApiResponse.withSuccess(this.response);
  ApiResponse.withError(this.error);
}
