/// POST /api/cards/compare 요청 body
class CardCompareModel {
  final List<int> cardIds;
  final int?      monthlySpend; // 시뮬레이션 포함 시
  const CardCompareModel({required this.cardIds, this.monthlySpend});
  Map<String, dynamic> toJson() => {
    'cardIds': cardIds,
    if (monthlySpend != null) 'monthlySpend': monthlySpend,
  };
}
