class UserModel {
  final int    userId;
  final String email;
  final String name;
  final String phone;
  const UserModel({required this.userId, required this.email, required this.name, required this.phone});
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    userId: j['userId'] as int, email: j['email'] as String,
    name:  j['name']  as String, phone: j['phone'] as String,
  );
}
