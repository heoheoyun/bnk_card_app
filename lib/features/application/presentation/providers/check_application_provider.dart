import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_application.dart';
import '../../domain/entities/credit_application.dart' show PaymentSnapshot;
import '../../domain/usecases/create_check_application_usecase.dart';
import '../../domain/usecases/submit_check_application_usecase.dart';
import '../../domain/repositories/check_application_repository.dart';
import '../../data/datasource/check_application_remote_datasource.dart';
import '../../data/repositories/check_application_repository_impl.dart';

// ── DI ────────────────────────────────────────────────────────────

final checkApplicationRepositoryProvider =
Provider<CheckApplicationRepository>((ref) {
  return CheckApplicationRepositoryImpl(
    CheckApplicationRemoteDatasource(),
  );
});

final createCheckApplicationUsecaseProvider =
Provider<CreateCheckApplicationUsecase>((ref) {
  return CreateCheckApplicationUsecase(
    ref.read(checkApplicationRepositoryProvider),
  );
});

final submitCheckApplicationUsecaseProvider =
Provider<SubmitCheckApplicationUsecase>((ref) {
  return SubmitCheckApplicationUsecase(
    ref.read(checkApplicationRepositoryProvider),
  );
});

// ── State ─────────────────────────────────────────────────────────

class CheckApplicationState {
  final int     currentStep;  // 1~4
  final int?    checkAppId;   // STEP 1 완료 후 세팅
  final bool    isLoading;
  final String? error;

  final CheckApplicantSnapshot? draftApplicantSnapshot;

  const CheckApplicationState({
    this.currentStep = 1,
    this.checkAppId,
    this.isLoading   = false,
    this.error,
    this.draftApplicantSnapshot,
  });

  CheckApplicationState copyWith({
    int?    currentStep,
    int?    checkAppId,
    bool?   isLoading,
    String? error,
    CheckApplicantSnapshot? draftApplicantSnapshot,
  }) {
    return CheckApplicationState(
      currentStep: currentStep ?? this.currentStep,
      checkAppId:  checkAppId  ?? this.checkAppId,
      isLoading:   isLoading   ?? this.isLoading,
      error:       error,
      draftApplicantSnapshot: draftApplicantSnapshot ?? this.draftApplicantSnapshot,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────

class CheckApplicationNotifier extends StateNotifier<CheckApplicationState> {
  final CreateCheckApplicationUsecase _createUsecase;
  final SubmitCheckApplicationUsecase _submitUsecase;
  final CheckApplicationRepository    _repo;

  CheckApplicationNotifier(
      this._createUsecase,
      this._submitUsecase,
      this._repo,
      ) : super(const CheckApplicationState());

  // DRAFT 조회 → 단계 분기
  Future<int> checkDraftAndGetStep(int cardId) async {
    try {
      final draft = await _repo.getDraftApplication(cardId);
      if (draft == null) return 1; // DRAFT 없음 → step1부터

      // creditAppId 저장
      state = state.copyWith(checkAppId: draft.checkAppId);

      // 본인확인 안 했으면 step2부터
      if (draft.idVerifiedYn != 'Y') return 2;

      // 본인확인 했으면 무조건 step3부터 (값 채워서)
      if (draft.applicantSnapshot != null) {
        state = state.copyWith(draftApplicantSnapshot: draft.applicantSnapshot);
      }
      return 3;
    } catch (e) {
      return 1;
    }
  }

  // STEP 1 - 약관 동의 → checkAppId 발급
  Future<void> createApplication({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final checkAppId = await _createUsecase.call(
        cardId:      cardId,
        agreedTerms: agreedTerms,
      );
      state = state.copyWith(
        checkAppId:  checkAppId,
        currentStep: 2,
        isLoading:   false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // STEP 2 - 본인확인
  Future<bool> verifyIdentity({
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repo.verifyIdentity(
        checkAppId:   state.checkAppId!,
        idType:       idType,
        idName:       idName,
        idResidentNo: idResidentNo,
        idAddress:    idAddress,
        idIssueDate:  idIssueDate,
      );
      if (result != 'Y') {
        state = state.copyWith(isLoading: false, error: '본인확인에 실패했습니다.');
        return false;
      }
      state = state.copyWith(currentStep: 3, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // STEP 3 - 기본정보
  Future<void> saveApplicantInfo({
    required CheckApplicantSnapshot applicantSnapshot,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.saveApplicantInfo(
        checkAppId:        state.checkAppId!,
        applicantSnapshot: applicantSnapshot,
      );
      state = state.copyWith(currentStep: 4, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // STEP 4 - 결제정보 + 신청 완료
  Future<void> submitApplication({
    required PaymentSnapshot paymentSnapshot,
    required int             linkedAccountId,
    required String          cardPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _submitUsecase.call(
        checkAppId:      state.checkAppId!,
        paymentSnapshot: paymentSnapshot,
        linkedAccountId: linkedAccountId,
        cardPassword:    cardPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);

  void reset() => state = const CheckApplicationState();

  void prefillApplicantFromIdentity({
    required String name,
    String? birthDate,
  }) {
    final base = state.draftApplicantSnapshot ??
        const CheckApplicantSnapshot(
          name: '', mobileNo: '', address: '', email: '',
        );
    state = state.copyWith(
      draftApplicantSnapshot:
      base.copyWith(name: name, birthDate: birthDate),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────

final checkApplicationProvider =
StateNotifierProvider.autoDispose<CheckApplicationNotifier, CheckApplicationState>(
      (ref) => CheckApplicationNotifier(
    ref.read(createCheckApplicationUsecaseProvider),
    ref.read(submitCheckApplicationUsecaseProvider),
    ref.read(checkApplicationRepositoryProvider),
  ),
);

