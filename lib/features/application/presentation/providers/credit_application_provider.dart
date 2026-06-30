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

  // draft 임시 저장 필드 추가
  final CreditApplicantSnapshot? draftApplicantSnapshot;
  final String? draftAnnualIncomeBand;
  final String? draftCreditScoreBand;
  final int?    draftLinkedAccountId;

  const CreditApplicationState({
    this.currentStep        = 1,
    this.creditAppId,
    this.isLoading          = false,
    this.error,
    this.isExistingCustomer = false,
    this.paymentSnapshot,
    this.requestedLimit,
    this.cardPassword,
    this.draftApplicantSnapshot,
    this.draftAnnualIncomeBand,
    this.draftCreditScoreBand,
    this.draftLinkedAccountId,
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
    CreditApplicantSnapshot? draftApplicantSnapshot,
    String? draftAnnualIncomeBand,
    String? draftCreditScoreBand,
    int?    draftLinkedAccountId,
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
      draftApplicantSnapshot: draftApplicantSnapshot ?? this.draftApplicantSnapshot,
      draftAnnualIncomeBand:  draftAnnualIncomeBand  ?? this.draftAnnualIncomeBand,
      draftCreditScoreBand:   draftCreditScoreBand   ?? this.draftCreditScoreBand,
      draftLinkedAccountId:   draftLinkedAccountId   ?? this.draftLinkedAccountId,
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

  // #17 — step1 DRAFT 자동 전진을 1회만 수행하기 위한 가드.
  //  - 카드 상세 "신청하기" 진입 시 beginNewSession()으로 false 리셋
  //  - step1 이 자동 전진을 수행하면 markResumeHandled()로 true
  //  - back 으로 step1 재진입 시 resumeHandled==true 면 재전진하지 않아
  //    무한 전진(뒤로가기 먹통) 바운스를 막는다.
  bool _resumeHandled = false;
  bool get resumeHandled => _resumeHandled;
  void beginNewSession() => _resumeHandled = false;
  void markResumeHandled() => _resumeHandled = true;

  // DRAFT 조회 → 단계 분기
  Future<int> checkDraftAndGetStep(int cardId) async {
    try {
      final draft = await _repo.getDraftApplication(cardId);

      if (draft == null) return 1; // DRAFT 없음 → step1부터

      // creditAppId 저장
      state = state.copyWith(creditAppId: draft.creditAppId);

      // 본인확인 안 했으면 step2부터
      if (draft.idVerifiedYn != 'Y') return 2;

      // 본인확인 했으면 무조건 step3부터 (값 채워서)
      // step3 완료된 경우 draft 데이터 state에 저장 후 step3부터
      if (draft.applicantSnapshot != null) {
        state = state.copyWith(
          draftApplicantSnapshot: draft.applicantSnapshot,
          draftAnnualIncomeBand:  draft.annualIncomeBand,
          draftCreditScoreBand:   draft.creditScoreBand,
          draftLinkedAccountId:   draft.linkedAccountId,
        );
      }
      return 3;
    } catch (e) {
      return 1;
    }
  }

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
        creditAppId:  state.creditAppId!,
        idType:       idType,
        idName:       idName,
        idResidentNo: idResidentNo,
        idAddress:    idAddress,
        idIssueDate:  idIssueDate,
      );

      // 서버가 'N' 반환하면 실패 처리
      if (result != 'Y') {
        state = state.copyWith(
          isLoading: false,
          error: '본인확인에 실패했습니다.',
        );
        return false;
      }

      state = state.copyWith(currentStep: 3, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // STEP 2 → STEP 3 자동 반영용.
  // 본인확인에서 받은 이름/주소/생년월일을 draftApplicantSnapshot 에 채워
  // step3 폼이 비어 보이지 않도록 한다. (직업/소득 등 나머지는 step3에서 입력)
  void prefillApplicantFromIdentity({
    required String name,
    String? birthDate,
  }) {
    final base = state.draftApplicantSnapshot ??
        const CreditApplicantSnapshot(
          name: '', mobileNo: '', address: '', email: '',
        );
    state = state.copyWith(
      draftApplicantSnapshot:
      base.copyWith(name: name, birthDate: birthDate),
    );
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
  void reset() {
    _resumeHandled = false;
    state = const CreditApplicationState();
  }
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