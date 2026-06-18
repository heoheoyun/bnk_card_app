class ApiResponse<T> {
  final String code;
  final String? message;
  final T?      data;
  const ApiResponse({required this.code, this.message, this.data});
  bool get isSuccess => code == 'SUCCESS';

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return ApiResponse(
      code:    json['code'] as String,
      message: json['message'] as String?,
      data:    json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
