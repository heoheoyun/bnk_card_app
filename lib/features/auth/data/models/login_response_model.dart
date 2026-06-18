class LoginResponseModel {
  final String? accessToken;
  final String? refreshToken;
  const LoginResponseModel({this.accessToken, this.refreshToken});
  factory LoginResponseModel.fromJson(Map<String, dynamic> j) =>
      LoginResponseModel(accessToken: j['accessToken'] as String?, refreshToken: j['refreshToken'] as String?);
}
