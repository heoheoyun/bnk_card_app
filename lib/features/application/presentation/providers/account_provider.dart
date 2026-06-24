import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// ── Model ─────────────────────────────────────────────────────────

class AccountModel {
  final int     accountId;
  final String  accountNumber;
  final String  accountType;
  final String? accountAlias;
  final String  accountStatus;

  const AccountModel({
    required this.accountId,
    required this.accountNumber,
    required this.accountType,
    this.accountAlias,
    required this.accountStatus,
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
    accountId:     (j['accountId'] as num).toInt(),
    accountNumber: j['accountNumber'] as String,
    accountType:   j['accountType']   as String,
    accountAlias:  j['accountAlias']  as String?,
    accountStatus: j['accountStatus'] as String,
  );

  String get displayName => accountAlias ?? accountNumber;
}

// ── Datasource ────────────────────────────────────────────────────

class AccountRemoteDatasource {
  final _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> getMyAccounts() async {
    final res = await _dio.get('/api/accounts/me');
    return (res.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}

// ── Providers ─────────────────────────────────────────────────────

final accountDatasourceProvider = Provider<AccountRemoteDatasource>(
      (_) => AccountRemoteDatasource(),
);

final myAccountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final ds   = ref.watch(accountDatasourceProvider);
  final data = await ds.getMyAccounts();
  return data.map((e) => AccountModel.fromJson(e)).toList();
});