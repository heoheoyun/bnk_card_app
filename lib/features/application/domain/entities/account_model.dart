/// 계좌 도메인 모델. 서버 GET /api/accounts/me 응답 1건에 대응.
class AccountModel {
  final int     accountId;
  final String  accountNumber;
  final String  accountType;
  final String? accountAlias;
  final String  accountStatus;
  final int     balance;

  const AccountModel({
    required this.accountId,
    required this.accountNumber,
    required this.accountType,
    this.accountAlias,
    required this.accountStatus,
    this.balance = 0,
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
    accountId: (j['accountId'] as num).toInt(),
    accountNumber: j['accountNumber'] as String,
    accountType: j['accountType'] as String,
    accountAlias: j['accountAlias'] as String?,
    accountStatus: j['accountStatus'] as String,
    balance: (j['balance'] as num?)?.toInt() ?? 0,
  );

  String get displayName => accountAlias ?? accountNumber;
}