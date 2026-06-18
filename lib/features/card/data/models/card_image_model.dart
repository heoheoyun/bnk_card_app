class CardImageModel {
  final int    imageId;
  final String imageType;   // FRONT / BACK / THUMBNAIL / DETAIL
  final String imageUrl;
  final int    sortOrder;
  const CardImageModel({required this.imageId, required this.imageType, required this.imageUrl, required this.sortOrder});
  factory CardImageModel.fromJson(Map<String, dynamic> j) => CardImageModel(
    imageId: j['imageId'] as int, imageType: j['imageType'] as String,
    imageUrl: j['imageUrl'] as String, sortOrder: j['sortOrder'] as int,
  );
}
