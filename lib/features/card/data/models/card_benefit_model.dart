class CardBenefitModel {
  final int     benefitId;
  final String  benefitTitle;
  final String  benefitType;       // RATE_DISCOUNT / FIXED_DISCOUNT / POINT / CASHBACK
  final double? discountRate;
  final int?    discountAmount;
  final String  displayText;
  final int     displayOrder;
  final String  categoryName;
  const CardBenefitModel({
    required this.benefitId, required this.benefitTitle, required this.benefitType,
    this.discountRate, this.discountAmount, required this.displayText,
    required this.displayOrder, required this.categoryName,
  });
  factory CardBenefitModel.fromJson(Map<String, dynamic> j) => CardBenefitModel(
    benefitId: j['benefitId'] as int, benefitTitle: j['benefitTitle'] as String,
    benefitType: j['benefitType'] as String, discountRate: (j['discountRate'] as num?)?.toDouble(),
    discountAmount: j['discountAmount'] as int?, displayText: j['displayText'] as String,
    displayOrder: j['displayOrder'] as int, categoryName: j['categoryName'] as String? ?? '',
  );
}
