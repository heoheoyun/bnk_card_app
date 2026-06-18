import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/card_remote_datasource.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/get_card_list_usecase.dart';

final cardDatasourceProvider = Provider<CardRemoteDatasource>(
      (_) => CardRemoteDatasource(),
);

final cardRepositoryProvider = Provider<CardRepository>(
      (ref) => CardRepositoryImpl(ref.watch(cardDatasourceProvider)),
);

final getCardListUsecaseProvider = Provider<GetCardListUsecase>(
      (ref) => GetCardListUsecase(ref.watch(cardRepositoryProvider)),
);

final cardListProvider = FutureProvider.family<List<Card>, String?>(
      (ref, keyword) => ref.watch(getCardListUsecaseProvider)(keyword: keyword),
);