import 'package:bnk_card_app/features/application/presentation/widgets/application_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../../terms/data/models/terms_model.dart';
import '../../../../terms/presentation/providers/terms_provider.dart';
import '../../../../terms/presentation/widgets/terms_item_tile.dart';
import '../../../presentation/providers/credit_application_provider.dart';
import '../../../../card/presentation/providers/card_list_provider.dart';

class CreditStep1TermsPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditStep1TermsPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditStep1TermsPage> createState() => _CreditStep1TermsPageState();
}

class _CreditStep1TermsPageState extends ConsumerState<CreditStep1TermsPage> {

  bool _memberTermsAgreed  = false;
  bool _privacyTermsAgreed = false;
  bool _marketingAgreed    = false;

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 약관 동의 상태 초기화
    Future.microtask(() =>
        ref.read(termsAgreeProvider.notifier).reset(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(cardTermsProvider(widget.cardId));
    final agreeState  = ref.watch(termsAgreeProvider);
    final appState    = ref.watch(creditApplicationProvider);
    final appNotifier = ref.read(creditApplicationProvider.notifier);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 1, totalSteps: 5),

          Expanded(
            child: termsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => const Center(child: Text('약관을 불러오지 못했습니다.')),
              data: (raw) {
                final terms = raw
                    .map((e) => TermsModel.fromJson(e as Map<String, dynamic>))
                    .toList();

                final allIds      = terms.map((t) => t.termsId).toList();
                final isAllChecked = allIds.isNotEmpty &&
                    allIds.every((id) => agreeState[id] == true);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      '약관 동의',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '카드 신청을 위해 아래 약관에 동의해 주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 전체 동의
                    CheckboxListTile(
                      value:   isAllChecked,
                      onChanged: (_) => ref
                          .read(termsAgreeProvider.notifier)
                          .agreeAll(allIds),
                      title: const Text(
                        '전체 동의',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.teal600,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // 약관 목록
                    ...terms.map((term) => TermsItemTile(
                      terms:    term,
                      agreed:   agreeState[term.termsId] ?? false,
                      onToggle: () => ref
                          .read(termsAgreeProvider.notifier)
                          .toggle(term.termsId),
                    )),
                    const Divider(height: 24),

                    // 홈페이지 회원약관 (필수)
                    _StaticTermsTile(
                      title: '[필수] 홈페이지 회원약관',
                      isRequired: true,
                      agreed: _memberTermsAgreed,
                      onToggle: () => setState(() => _memberTermsAgreed = !_memberTermsAgreed),
                      content:
                        '''제1장 총칙 제1조(목적) 이 약관은 주식회사 부산은행(이하 '은행'이라 한다)과 이용 고객(이하 '회원'이라 한다)간에
                        홈페이지 및 회원 개인홈페이지의 이용조건 및 절차에 관한 사항을 정함을 목적으로 합니다. 제2조(이용약관의 효력 및
                        변경) ① 이 약관은 부산은행 웹사이트에서 온라인으로 공시함으로써 효력을 발생합니다. ② 은행은 합리적인 사유가
                        발생될 경우에는 이 약관을 변경할 수 있으며, 약관이 변경된 경우에는 지체없이 제1항과 같은 방법으로 이를 공시 또는
                        공지 합니다. 제3조(용어의 정의) ① '회원'이라 함은 은행과 회원간의 홈페이지 및 개인홈페이지 이용계약을
                        체결하고, 본 약관에 동의한 자를 말합니다. ② '이용계약'이라 함은 서비스 이용과 관련하여 은행과 회원간에 체결하는
                        계약을 말합니다. ③ '서비스'라 함은 은행의 홈페이지 및 개인홈페이지에서 제공하는 웹서비스를 말합니다. ④
                        '고객ID'라 함은 회원의 식별과 회원의 서비스 이용을 위하여 회원이 정하고 은행이 부여하는 문자와 숫자의 조합을
                        말합니다. (6자 이상 8자 이내의 영문과 숫자) ⑤ '비밀번호'라 함은 회원이 부여 받은 고객ID와 일치된 회원임을
                        확인하고 회원의 비밀 및 권익보호를 위하여 회원 스스로가 선정하여 은행에 등록한 문자와 숫자의 조합을 말합니다.
                        [6자 이상 8자 이내의 영문(대/소 구분)과 숫자] ⑥ '개인홈페이지'라 함은 은행의 계좌보유자로써 회원의 신청에
                        의하여 은행이 회원에게 제공하는 인터넷홈페이지를 말합니다. 제2장 이용계약 체결 제4조(이용계약의 성립) ①
                        이용계약은 회원의 신청에 대하여 은행의 이용승낙으로 성립합니다. ② 회원의 본 약관에 대한 동의는 이용신청 당시 해당
                        웹화면상의 '동의합니다' 버튼을 누름으로써 이루어집니다. 제5조(이용 신청) ① 회원으로 가입하여 본 서비스를
                        이용하고자 하는 고객은 은행에서 요청하는 정보(이름, 주민등록번호, 연락처 등)를 제공하여야 합니다. ② 회원가입은
                        반드시 실명으로 본인의 이름과 주민등록번호를 제공하여야만 서비스를 이용할 수 있습니다. ③ 타인의 이름 및
                        주민등록번호를 도용하거나, 비실명으로 이용신청을 한 고객의 ID는 삭제되며, 관계법령에 따라 처벌을 받을 수
                        있습니다. 제6조(이용신청의 승낙과 제한) ① 은행은 다음 각 호에 해당하는 신청에 대하여는 승낙을 하지 아니할 수
                        있습니다. 1. 타인 명의의 신청 또는 비실명으로 신청하는 경우 2. 이용계약 신청서의 내용을 허위로 기재한 경우
                        3. 영리를 추구할 목적으로 본 서비스를 이용하고자 하는 경우 4. 기타 규정한 사항을 위반하며 신청하는 경우 제3장
                        계약당사자의 권리 및 의무 제8조(은행의 의무) ① 은행은 회원이 희망한 서비스 제공 개시일에 제6조의 경우를
                        제외하고는 서비스를 이용할 수 있도록 하여야 합니다. ② 은행은 개인정보 보호를 위해 보안시스템을 구축하며 개인정보
                        보호정책을 공시하고 준수합니다. 제9조(회원의 의무) ① 이용자는 회원가입 신청 또는 회원정보 변경시 실명으로 모든
                        사항을 사실에 근거하여 작성하여야 하며, 허위 또는 타인의 정보를 등록할 경우 일체의 권리를 주장할 수 없습니다. ②
                        회원은 본 약관에서 규정하는 사항과 기타 은행이 정한 제반 규정, 공지사항 및 관계법령을 준수하여야 합니다. ③
                        회원은 주소, 연락처, 전자우편 주소 등 이용계약사항이 변경된 경우에 해당 절차를 거쳐 이를 은행에 즉시 알려야
                        합니다. ④ 부여된 ID 및 비밀번호 관리소홀, 부정사용에 의하여 발생하는 모든 결과에 대한 책임은 회원에게
                        있습니다. 제4장 서비스의 이용 제10조(서비스 이용 시간) ① 서비스 이용은 은행의 업무상 또는 기술상 특별한
                        지장이 없는 한 연중무휴, 1일 24시간 운영을 원칙으로 합니다. 제5장 계약 해지 및 이용 제한 제14조(계약
                        해지) 회원이 이용계약을 해지하고자 하는 때에는 회원 본인이 홈페이지 및 개인 홈페이지 내의 메뉴를 이용해 가입해지를
                        해야 합니다. 제6장 손해배상 및 기타사항 제16조(면책조항) ① 은행은 천재지변, 전쟁 및 기타 이에 준하는
                        불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 대한 책임이 면제됩니다. ② 은행은 회원의
                        귀책사유로 인한 서비스 이용의 장애 또는 손해에 대하여 책임을 지지 않습니다. ⑩ 은행에서 회원에게 무료로 제공하는
                        서비스의 이용과 관련해서는 어떠한 손해도 책임을 지지 않습니다. 제17조(준거법 및 재판권) ① 이 약관에 명시되지
                        않은 사항은 전기통신사업법 등 관계법령과 상관습에 따릅니다. ② 서비스 이용으로 발생한 분쟁에 대해 소송이 제기되는
                        경우 은행의 본사 소재지를 관할하는 법원을 관할 법원으로 합니다.'''

                    ),
                    const SizedBox(height: 8),

                    // 개인정보처리취급방침 (필수)
                    _StaticTermsTile(
                      title: '[필수] 개인정보처리취급방침',
                      isRequired: true,
                      agreed: _privacyTermsAgreed,
                      onToggle: () => setState(() => _privacyTermsAgreed = !_privacyTermsAgreed),
                      content:
                        '''㈜부산은행(이하 '당행')은 개인정보보호법 제30조에 따라 고객의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 고객의 고충을
                        원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다. 제1조(개인정보의 처리 목적) 당행은 개인정보를
                        다음 각 호의 목적을 위해 처리합니다. 처리한 개인정보는 다음의 목적 외의 용도로는 사용되지 않으며 이용 목적이
                        변경될 시에는 사전동의를 구할 예정입니다. 1.(금융)거래 관계 관련 (금융)거래와 관련하여 신용조회회사 또는
                        신용정보집중기관에 대한 개인신용정보의 조회, (금융)거래 관계의 설정 여부의 판단, (금융)거래 관계의
                        설정·유지·이행·관리, 금융사고 조사, 분쟁 해결, 민원처리 및 법령상 의무이행 등의 목적으로 개인정보를 처리합니다.
          
                        2.상품 및 서비스 홍보 및 판매 권유 고객 만족도 조사를 통한 신규 서비스 개발 및 맞춤 서비스 제공, 인구통계학적
                        특성에 따른 서비스 제공 및 광고의 게재, 서비스의 유효성 확인, 경품지급, 사은행사 등 고객의 편의 및 참여기회
                        제공 등의 목적으로 개인정보를 처리합니다. 3.회원 가입 및 관리 회원가입, 회원제 서비스 이용, 제한적 본인
                        확인제에 따른 본인확인, 개인식별, 부정이용방지, 비인가 사용방지, 가입의사 확인, 민원처리 및 고지사항 전달 등의
                        목적으로 개인정보를 처리합니다. 4.온라인 거래 관련 목적 전자금융거래법 제21조, 제22조에 의해 전자금융거래의
                        내용 추적 및 검색, 보안정책 수립용 통계 자료로 활용 등을 목적으로 개인정보를 처리합니다. 제2조(개인정보의 처리
                        및 보유 기간) ① (금융)거래와 관련한 개인(신용)정보는 수집·이용에 관한 동의일로부터 (금융)거래 종료일로부터
                        5년까지 위 이용목적을 위하여 보유·이용됩니다. ② 개인(신용)정보의 조회를 목적으로 수집된 개인(신용)정보는
                        수집·이용에 대한 동의일로부터 고객에 대한 신용정보 제공·조회 동의의 효력기간까지 보유·이용됩니다. ③ 상품 및
                        서비스 홍보 및 판매 권유 등과 관련한 개인(신용)정보는 수집·이용에 관한 동의일로부터 동의 철회일까지
                        보유·이용됩니다. ④ 회원 가입 및 관리 목적으로 수집된 개인(신용)정보는 고객의 회원 가입일로부터 회원 탈퇴일까지
                        보유·이용됩니다. 제4조(개인정보의 제3자 제공) ① 당행은 원칙적으로 고객의 개인정보를 제1조에서 명시한 목적 범위
                        내에서 처리하며, 고객의 사전 동의없이는 본래의 범위를 초과하여 처리하거나 제3자에게 제공하지 않습니다.
          
                        제6조(고객의 권리·의무 및 그 행사방법) ① 고객은 당행이 처리하는 자신의 개인정보의 열람을 요구할 수 있습니다.
                        ② 자신의 개인정보를 열람한 고객은 사실과 다르거나 확인할 수 없는 개인정보에 대하여 당행에 정정 또는 삭제를 요구할
                        수 있습니다. ③ 고객은 당행에 대하여 자신의 개인정보 처리의 정지를 요구할 수 있습니다. 제7조(처리하는 개인정보의
                        항목) 1. 필수적 정보 - 개인식별정보 : 성명, 주민등록번호 등 고유식별정보, 국적, 직업군, 주소·전자우편
                        주소·전화번호 등 연락처 - (금융)거래정보 : 상품종류, 거래조건(이자율, 만기, 담보 등), 거래일시, 금액 등
                        거래설정 및 내역 정보 2. 선택적 정보 - 개인식별정보 외에 거래신청서에 기재된 정보 또는 고객이 제공한 정보(주거
                        및 가족사항, 거주기간, 세대구성, 결혼여부 등) 제8조(개인정보의 파기) ① 당행은 개인정보의 보유기간이 경과된
                        경우에는 보유기간의 종료일로부터 5영업일 이내에 그 개인정보를 파기합니다. 제12조(권익침해 구제방법) 고객은
                        개인정보침해로 인한 신고나 상담이 필요하신 경우 아래 기관에 문의하시기 바랍니다. - 개인정보분쟁조정위원회
                        (www.kopico.go.kr / 02-405-5150) - 한국인터넷진흥원 개인정보침해신고센터
                        (privacy.kisa.or.kr / 118) - 대검찰청 첨단범죄수사과 (www.spo.go.kr /
                        02-3480-2000) - 경찰청 사이버테러대응센터 (www.ctrc.go.kr / 182) 제13조(개인정보
                        보호책임자) - 소속/직책 : 정보보호부 / CISO - 담당부서 : 정보보호부 / 금융소비자보호부 - 연락처 :
                        051-661-4370 / 080-522-2200'''

                    ),
                    const SizedBox(height: 8),

                    // 마케팅 동의 (선택)
                    _StaticTermsTile(
                      title: '[선택] 마케팅 정보 수신 동의',
                      isRequired: false,
                      agreed: _marketingAgreed,
                      onToggle: () => setState(() => _marketingAgreed = !_marketingAgreed),
                      content: '마케팅 정보 수신에 동의하시면 BNK 부산은행의 다양한 혜택과 이벤트 정보를 받아보실 수 있습니다.',
                    ),
                  ],
                );
              },
            ),
          ),

          // 하단 다음 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: termsAsync.maybeWhen(
                data: (raw) {
                  final terms = raw
                      .map((e) => TermsModel.fromJson(e as Map<String, dynamic>))
                      .toList();

                  final requiredIds = terms
                      .where((t) => t.required)
                      .map((t) => t.termsId)
                      .toList();

                  final allRequiredAgreed = ref
                      .read(termsAgreeProvider.notifier)
                      .isAllAgreed(requiredIds)
                      && _memberTermsAgreed
                      && _privacyTermsAgreed;

                  return BnkButton(
                    label:     '다음',
                    isLoading: appState.isLoading,
                    onPressed: allRequiredAgreed
                        ? () async {
                      final agreedTerms = terms
                          .map((t) => {
                        'termsId': t.termsId.toString(),
                        'agreedYn': (agreeState[t.termsId] == true)
                            ? 'Y'
                            : 'N',
                      })
                          .toList();

                      await appNotifier.createApplication(
                        cardId:      widget.cardId,
                        agreedTerms: agreedTerms,
                      );

                      if (context.mounted && appState.error == null) {
                        context.push(
                          '/application/credit/step2',
                          extra: widget.cardId,
                        );
                      }
                    }
                        : null,
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticTermsTile extends StatelessWidget {
  final String     title;
  final bool       isRequired;
  final bool       agreed;
  final VoidCallback onToggle;
  final String     content;

  const _StaticTermsTile({
    required this.title,
    required this.isRequired,
    required this.agreed,
    required this.onToggle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRequired ? AppColors.teal50 : AppColors.gray200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isRequired ? '필수' : '선택',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isRequired ? AppColors.teal800 : AppColors.gray600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 본문 스크롤
          Container(
            height: 120,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.7),
              ),
            ),
          ),

          // 동의 체크
          const Divider(height: 1, color: AppColors.gray200),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    agreed ? Icons.check_circle : Icons.check_circle_outline,
                    color: agreed ? AppColors.teal600 : AppColors.gray400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${title.replaceAll(RegExp(r'\[.*?\]\s*'), '')}에 동의합니다',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '(필수)',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}