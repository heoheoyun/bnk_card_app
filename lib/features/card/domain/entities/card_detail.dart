import 'card_image.dart';

/// 카드 상세 화면에 필요한 모든 정보를 담는 도메인 Entity.
///
/// Repository 레이어에서 raw Map → Entity 변환이 완료되므로
/// Presentation 레이어는 Map 타입을 직접 다루지 않는다.
class CardDetail {
  final int    cardId;
  final String cardName;
  final String companyName;
  final String cardType;
  final int    annualFeeDomestic;
  final int    annualFeeOverseas;
  final int    previousMonthSpend;
  final String? summaryDescription;
  final String? targetUser;

  final List<CardDetailBenefit> benefits;
  final List<CardImage>         images;
  final List<CardDetailContent> contents;

  const CardDetail({
    required this.cardId,
    required this.cardName,
    required this.companyName,
    required this.cardType,
    required this.annualFeeDomestic,
    required this.annualFeeOverseas,
    required this.previousMonthSpend,
    this.summaryDescription,
    this.targetUser,
    this.benefits = const [],
    this.images   = const [],
    this.contents = const [],
  });
}

// ── 혜택 서브 Entity ──────────────────────────────────────────────

class CardDetailBenefit {
  final int    benefitId;
  final String benefitTitle;
  final String benefitType;
  final String displayText;
  final int    sortOrder;

  const CardDetailBenefit({
    required this.benefitId,
    required this.benefitTitle,
    required this.benefitType,
    required this.displayText,
    required this.sortOrder,
  });

  factory CardDetailBenefit.fromMap(Map<String, dynamic> m) =>
      CardDetailBenefit(
        benefitId:    (m['benefitId']    as num?)?.toInt() ?? 0,
        benefitTitle: m['benefitTitle']  as String? ?? '',
        benefitType:  m['benefitType']   as String? ?? '',
        displayText:  m['displayText']   as String? ?? '',
        sortOrder:    (m['sortOrder']    as num?)?.toInt() ?? 0,
      );
}

// ── 콘텐츠 서브 Entity ────────────────────────────────────────────

class CardDetailContent {
  final int    contentId;
  final String contentType;
  final String title;
  final String? contentHtml;
  final String? mobileContentHtml;
  final int    displayOrder;

  const CardDetailContent({
    required this.contentId,
    required this.contentType,
    required this.title,
    this.contentHtml,
    this.mobileContentHtml,
    required this.displayOrder,
  });

  factory CardDetailContent.fromMap(Map<String, dynamic> m) =>
      CardDetailContent(
        contentId:         (m['contentId']      as num?)?.toInt() ?? 0,
        contentType:       m['contentType']     as String? ?? '',
        title:             m['title']           as String? ?? '',
        contentHtml:       m['contentHtml']     as String?,
        mobileContentHtml: m['mobileContentHtml'] as String?,
        displayOrder:      (m['displayOrder']   as num?)?.toInt() ?? 0,
      );
}