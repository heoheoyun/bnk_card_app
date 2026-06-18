import '../../domain/entities/card.dart';
import '../../domain/entities/card_detail.dart';
import '../../domain/entities/card_image.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasource/card_remote_datasource.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDatasource _ds;
  CardRepositoryImpl(this._ds);

  // ── 카드 목록 ────────────────────────────────────────────────────
  @override
  Future<List<Card>> getCardList({
    String? keyword,
    String? cardType,
    int page = 0,
    int size = 20,
  }) async {
    final data  = await _ds.getCardList(
        keyword: keyword, cardType: cardType, page: page, size: size);
    final items = (data['data']?['content'] as List? ?? []);
    return items
        .map((e) => _toEntity(
        CardModel.fromJson(Map<String, dynamic>.from(e as Map))))
        .toList();
  }

  // ── 카드 상세 — Map → CardDetail Entity 변환 완성 ─────────────────
  @override
  Future<CardDetail> getCardDetail(int cardId) async {
    final raw  = await _ds.getCardDetail(cardId);
    final data = raw['data'] != null
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw; // 서버가 래핑 없이 직접 반환하는 경우 대응

    // 혜택 파싱
    final benefits = ((data['benefits'] as List?) ?? [])
        .map((e) =>
        CardDetailBenefit.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    // 이미지 파싱
    final images = ((data['images'] as List?) ?? [])
        .map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return CardImage(
        imageId:   (m['imageId']   as num?)?.toInt() ?? 0,
        imageType: m['imageType']  as String? ?? '',
        imageUrl:  m['imageUrl']   as String? ?? '',
        sortOrder: (m['sortOrder'] as num?)?.toInt() ?? 0,
      );
    })
        .toList();

    // 콘텐츠 파싱
    final contents = ((data['contents'] as List?) ?? [])
        .map((e) =>
        CardDetailContent.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return CardDetail(
      cardId:              (data['cardId']              as num?)?.toInt() ?? 0,
      cardName:            data['cardName']             as String? ?? '',
      companyName:         data['companyName']          as String? ?? '',
      cardType:            data['cardType']             as String? ?? '',
      annualFeeDomestic:   (data['annualFeeDomestic']   as num?)?.toInt() ?? 0,
      annualFeeOverseas:   (data['annualFeeOverseas']   as num?)?.toInt() ?? 0,
      previousMonthSpend:  (data['previousMonthSpend']  as num?)?.toInt() ?? 0,
      summaryDescription:  data['summaryDescription']  as String?,
      targetUser:          data['targetUser']           as String?,
      benefits: benefits,
      images:   images,
      contents: contents,
    );
  }

  // ── TOP 3 카드 ───────────────────────────────────────────────────
  @override
  Future<List<Card>> getTop3Cards({String? surveyResult}) async {
    final list = await _ds.getTop3Cards(surveyResult: surveyResult);
    return list
        .map((e) => _toEntity(
        CardModel.fromJson(Map<String, dynamic>.from(e as Map))))
        .toList();
  }

  // ── 카드 비교 ────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>> compareCards(List<int> cardIds) =>
      _ds.compareCards(cardIds);

  // ── 내부 변환 헬퍼 ───────────────────────────────────────────────
  Card _toEntity(CardModel m) => Card(
    cardId:             m.cardId,
    cardName:           m.cardName,
    companyName:        m.companyName,
    cardType:           m.cardType,
    annualFeeDomestic:  m.annualFeeDomestic,
    annualFeeOverseas:  m.annualFeeOverseas,
    summaryDescription: m.summaryDescription,
    thumbnailUrl:       m.thumbnailUrl,
  );
}