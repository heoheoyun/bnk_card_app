import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/account_remote_datasource.dart';
import '../../domain/entities/account_model.dart';

// 기존에 account_provider.dart 만 import 하던 파일(credit_step3_applicant_page,
// account_create_page 등)이 AccountModel / AccountRemoteDatasource 를 그대로
// 사용할 수 있도록 재공개(re-export)한다. 덕분에 사용처 import 수정이 불필요하다.
export '../../domain/entities/account_model.dart';
export '../../data/datasource/account_remote_datasource.dart';

final accountDatasourceProvider = Provider<AccountRemoteDatasource>(
      (_) => AccountRemoteDatasource(),
);

final myAccountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final ds = ref.watch(accountDatasourceProvider);
  final data = await ds.getMyAccounts();
  return data.map(AccountModel.fromJson).toList();
});