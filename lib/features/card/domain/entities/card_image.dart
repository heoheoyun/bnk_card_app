class CardImage {
  final int    imageId;
  final String imageType;   // FRONT / BACK / THUMBNAIL / DETAIL
  final String imageUrl;
  final int    sortOrder;
  const CardImage({required this.imageId, required this.imageType, required this.imageUrl, required this.sortOrder});
}
