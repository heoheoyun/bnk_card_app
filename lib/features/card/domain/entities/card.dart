class Card {
  final int     cardId;
  final String  cardName;
  final String  companyName;
  final String  cardType;
  final int     annualFeeDomestic;
  final int     annualFeeOverseas;
  final String? summaryDescription;
  final String? thumbnailUrl;
  const Card({required this.cardId, required this.cardName, required this.companyName,
    required this.cardType, required this.annualFeeDomestic, required this.annualFeeOverseas,
    this.summaryDescription, this.thumbnailUrl});
}
