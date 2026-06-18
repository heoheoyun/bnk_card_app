class BannerModel {
  final int    cardId;
  final String cardName;
  final String? imageUrl;
  final String? benefitSummary;
  const BannerModel({required this.cardId, required this.cardName, this.imageUrl, this.benefitSummary});
  factory BannerModel.fromJson(Map<String, dynamic> j) => BannerModel(
    cardId: j['cardId'] as int,
    cardName: j['cardName'] as String,
    imageUrl: j['imageUrl'] as String?,
    benefitSummary: j['benefitSummary'] as String?,
  );
}
