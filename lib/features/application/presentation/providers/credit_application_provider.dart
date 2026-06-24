import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/credit_application.dart';
import '../../domain/usecases/create_credit_application_usecase.dart';
import '../../domain/usecases/submit_credit_application_usecase.dart';
import '../../domain/repositories/credit_application_repository.dart';
import '../../data/datasource/credit_application_remote_datasource.dart';
import '../../data/repositories/credit_application_repository_impl.dart';

// ── DI ────────────────────────────────────────────────────────────

final creditApplicationRepositoryProvider =
Provider<CreditApplicationRepository>((ref) {
  return CreditApplicationRepositoryImpl(
    CreditApplicationRemoteDatasource(),
  );
});

final createCreditApplicationUsecaseProvider =
Provider<CreateCreditApplicationUsecase>((ref) {
  return CreateCreditApplicationUsecase(
    ref.read(creditApplicationRepositoryProvider),
  );
});

final submitCreditApplicationUsecaseProvider =
Provider<SubmitCreditApplicationUsecase>((ref) {
  return SubmitCreditApplicationUsecase(
    ref.read(creditApplicationRepositoryProvider),
  );
});

// ── State ─────────────────────────────────────────────────────────

class CreditApplicationState {
  final int     currentStep;
  final int?    creditAppId;
  final bool    isLoading;
  final String? error;
  final bool    isExistingCustomer;

  // step4에서 임시 저장할 필드 추가
  final PaymentSnapshot? paymentSnapshot;
  final int?             requestedLimit;
  final String?          cardPassword;

  const CreditApplicationState({
    this.currentStep        = 1,
    this.creditAppId,
    this.isLoading          = false,
    this.error,
    this.isExistingCustomer = false,
    this.paymentSnapshot,
    this.requestedLimit,
    this.cardPassword,
  });

  CreditApplicationState copyWith({
    int?             currentStep,
    int?             creditAppId,
    bool?            isLoading,
    String?          error,
    bool?            isExistingCustomer,
    PaymentSnapshot? paymentSnapshot,
    int?             requestedLimit,
    String?          cardPassword,
  }) {
    return CreditApplicationState(
      currentStep:        currentStep        ?? this.currentStep,
      creditAppId:        creditAppId        ?? this.creditAppId,
      isLoading:          isLoading          ?? this.isLoading,
      error:              error,
      isExistingCustomer: isExistingCustomer ?? this.isExistingCustomer,
      paymentSnapshot:    paymentSnapshot    ?? this.paymentSnapshot,
      requestedLimit:     requestedLimit     ?? this.requestedLimit,
      cardPassword:       cardPassword       ?? this.cardPassword,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────

class CreditApplicationNotifier extends StateNotifier<CreditApplicationState> {
  final CreateCreditApplicationUsecase  _createUsecase;
  final SubmitCreditApplicationUsecase  _submitUsecase;
  final CreditApplicationRepository     _repo;

  CreditApplicationNotifier(
      this._createUsecase,
      this._submitUsecase,
      this._repo,
      ) : super(const CreditApplicationState());

  // STEP 1 - 약관 동의 → creditAppId 발급
  Future<void> createApplication({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final creditAppId = await _createUsecase.call(
        cardId:      cardId,
        agreedTerms: agreedTerms,
      );
      state = state.copyWith(
        creditAppId: creditAppId,
        currentStep: 2,
        isLoading:   false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // STEP 2 - 본인확인
  Future<void> verifyIdentity({
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.verifyIdentity(
        creditAppId:  state.creditAppId!,
        idType:       idType,
        idName:       idName,
        idResidentNo: idResidentNo,
        idAddress:    idAddress,
        idIssueDate:  idIssueDate,
      );
      state = state.copyWith(currentStep: 3, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // STEP 3 - 기본정보 + 직업/소득
  Future<void> saveApplicantInfo({
    required CreditApplicantSnapshot applicantSnapshot,
    required String                  annualIncomeBand,
    required String                  creditScoreBand,
    required int                     linkedAccountId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.saveApplicantInfo(
        creditAppId:       state.creditAppId!,
        applicantSnapshot: applicantSnapshot,
        annualIncomeBand:  annualIncomeBand,
        creditScoreBand:   creditScoreBand,
        linkedAccountId:   linkedAccountId,
      );

      // 기존고객 여부 확인 → STEP 5 서류 화면 노출 결정
      final isExisting = await _repo.checkExistingCustomer(state.creditAppId!);

      state = state.copyWith(
        currentStep:        4,
        isExistingCustomer: isExisting,
        isLoading:          false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // STEP 4 - 결제정보 저장 후 다음 스텝 분기
  // 기존고객 → submit / 신규고객 → STEP 5 서류
  void nextFromStep4() {
    if (state.isExistingCustomer) {
      // 기존고객은 서류 없이 바로 submit 호출 가능 상태
      state = state.copyWith(currentStep: 5);
    } else {
      state = state.copyWith(currentStep: 5);
    }
  }

  // step4 — API 호출 없이 state에만 저장
  void savePaymentInfo({
    required PaymentSnapshot paymentSnapshot,
    required int             requestedLimit,
    required String          cardPassword,
  }) {
    state = state.copyWith(
      paymentSnapshot: paymentSnapshot,
      requestedLimit:  requestedLimit,
      cardPassword:    cardPassword,
      currentStep:     5,
    );
  }

  // step5 — 서류 키 받아서 최종 신청 완료
  Future<void> submitApplication({
    String? incomeDocKey,
    String? assetDocKey,
    String? jobDocKey,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _submitUsecase.call(
        creditAppId:     state.creditAppId!,
        paymentSnapshot: state.paymentSnapshot!,
        requestedLimit:  state.requestedLimit!,
        cardPassword:    state.cardPassword!,
        incomeDocKey:    incomeDocKey,
        assetDocKey:     assetDocKey,
        jobDocKey:       jobDocKey,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);

  // 신청 처음부터 다시 시작
  void reset() => state = const CreditApplicationState();
}

// ── Provider ──────────────────────────────────────────────────────

final creditApplicationProvider =
StateNotifierProvider.autoDispose<CreditApplicationNotifier, CreditApplicationState>(
      (ref) => CreditApplicationNotifier(
    ref.read(createCreditApplicationUsecaseProvider),
    ref.read(submitCreditApplicationUsecaseProvider),
    ref.read(creditApplicationRepositoryProvider),
  ),
);