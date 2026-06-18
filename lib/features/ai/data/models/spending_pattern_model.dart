class SpendingPatternModel {
  final int    categoryId;
  final String categoryName;
  final int    monthlyAmount;
  final double ratio;
  const SpendingPatternModel({required this.categoryId, required this.categoryName, required this.monthlyAmount, required this.ratio});
  factory SpendingPatternModel.fromJson(Map<String, dynamic> j) => SpendingPatternModel(
    categoryId: j['categoryId'] as int, categoryName: j['categoryName'] as String,
    monthlyAmount: j['monthlyAmount'] as int, ratio: (j['ratio'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {'categoryId': categoryId, 'monthlyAmount': monthlyAmount, 'source': 'MANUAL'};
}
