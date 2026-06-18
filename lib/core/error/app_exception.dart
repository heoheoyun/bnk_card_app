class AppException implements Exception {
  final String code;
  final String message;
  final int?   statusCode;
  const AppException({required this.code, required this.message, this.statusCode});
  factory AppException.fromResponse(int statusCode, String code, String message) =>
      AppException(code: code, message: message, statusCode: statusCode);
  factory AppException.network()      => const AppException(code: 'NETWORK',      message: '네트워크 오류가 발생했습니다.');
  factory AppException.timeout()      => const AppException(code: 'TIMEOUT',      message: '요청 시간이 초과되었습니다.');
  factory AppException.unknown()      => const AppException(code: 'UNKNOWN',      message: '알 수 없는 오류가 발생했습니다.');
  factory AppException.unauthorized() => const AppException(code: 'UNAUTHORIZED', message: '로그인이 필요합니다.', statusCode: 401);
  @override String toString() => 'AppException[$code]: $message';
}
