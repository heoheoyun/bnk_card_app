class CardModel {
  final int     cardId;
  final String  cardName;
  final String  companyName;
  final String  cardType;         // CREDIT / CHECK / PREPAID
  final int     annualFeeDomestic;
  final int     annualFeeOverseas;
  final String? summaryDescription;
  final String? thumbnailUrl;
  final String? topBenefit;
  final int     viewCount;
  const CardModel({
    required this.cardId, required this.cardName, required this.companyName,
    required this.cardType, required this.annualFeeDomestic, required this.annualFeeOverseas,
    this.summaryDescription, this.thumbnailUrl, this.topBenefit, required this.viewCount,
  });
  factory CardModel.fromJson(Map<String, dynamic> j) => CardModel(
    cardId: j['cardId'] as int, cardName: j['cardName'] as String,
    companyName: j['companyName'] as String, cardType: j['cardType'] as String,
    annualFeeDomestic: (j['annualFeeDomestic'] as num?)?.toInt() ?? 0,
    annualFeeOverseas: (j['annualFeeOverseas'] as num?)?.toInt() ?? 0,
    summaryDescription: j['summaryDescription'] as String?,
    thumbnailUrl: j['thumbnailUrl'] as String?,
    topBenefit: j['topBenefit'] as String?,
    viewCount: j['viewCount'] as int? ?? 0,
  );
}