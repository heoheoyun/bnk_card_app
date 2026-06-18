class CardContentModel {
  final String  contentType;        // INTRO / GUIDE / NOTICE
  final String  title;
  final String  contentHtml;
  final String? mobileContentHtml;
  final int     displayOrder;
  const CardContentModel({required this.contentType, required this.title, required this.contentHtml, this.mobileContentHtml, required this.displayOrder});
  factory CardContentModel.fromJson(Map<String, dynamic> j) => CardContentModel(
    contentType: j['contentType'] as String, title: j['title'] as String,
    contentHtml: j['contentHtml'] as String, mobileContentHtml: j['mobileContentHtml'] as String?,
    displayOrder: j['displayOrder'] as int,
  );
}
