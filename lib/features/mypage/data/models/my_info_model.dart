class MyInfoModel {
  final int    userId;
  final String email;
  final String name;
  final String phone;
  final int?   creditScore;
  const MyInfoModel({required this.userId, required this.email, required this.name, required this.phone, this.creditScore});
  factory MyInfoModel.fromJson(Map<String, dynamic> j) => MyInfoModel(
    userId: j['userId'] as int, email: j['email'] as String,
    name: j['name'] as String, phone: j['phone'] as String,
    creditScore: j['creditScore'] as int?,
  );
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}
