import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/credit_application.dart';
import '../../domain/entities/check_application.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import 'credit_application_provider.dart' show creditApplicationRepositoryProvider;
import 'check_application_provider.dart' show checkApplicationRepositoryProvider;

// ── UseCase DI ────────────────────────────────────────────────────

final getMyApplicationsUsecaseProvider =
Provider<GetMyApplicationsUsecase>((ref) {
  return GetMyApplicationsUsecase(
    ref.read(creditApplicationRepositoryProvider),
    ref.read(checkApplicationRepositoryProvider),
  );
});

// ── State ─────────────────────────────────────────────────────────

class MyApplicationsState {
  final List<CreditApplication> creditApplications;
  final List<CheckApplication>  checkApplications;
  final bool    isLoading;
  final String? error;

  const MyApplicationsState({
    this.creditApplications = const [],
    this.checkApplications  = const [],
    this.isLoading          = false,
    this.error,
  });

  MyApplicationsState copyWith({
    List<CreditApplication>? creditApplications,
    List<CheckApplication>?  checkApplications,
    bool?    isLoading,
    String?  error,
  }) {
    return MyApplicationsState(
      creditApplications: creditApplications ?? this.creditApplications,
      checkApplications:  checkApplications  ?? this.checkApplications,
      isLoading:          isLoading          ?? this.isLoading,
      error:              error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────

class MyApplicationsNotifier extends StateNotifier<MyApplicationsState> {
  final GetMyApplicationsUsecase _usecase;
  MyApplicationsNotifier(this._usecase) : super(const MyApplicationsState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _usecase.call();
      state = state.copyWith(
        creditApplications: result['creditApplications'] as List<CreditApplication>,
        checkApplications:  result['checkApplications']  as List<CheckApplication>,
        isLoading:          false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────

final myApplicationsProvider =
StateNotifierProvider.autoDispose<MyApplicationsNotifier, MyApplicationsState>(
      (ref) => MyApplicationsNotifier(
    ref.read(getMyApplicationsUsecaseProvider),
  ),
);