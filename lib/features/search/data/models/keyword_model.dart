class KeywordModel {
  final int     keywordId;
  final String  keyword;
  final int?    searchCount;
  final bool    isRecommended;
  const KeywordModel({required this.keywordId, required this.keyword, this.searchCount, this.isRecommended = false});
  factory KeywordModel.fromJson(Map<String, dynamic> j) => KeywordModel(
    keywordId: j['keywordId'] as int? ?? 0, keyword: j['keyword'] as String,
    searchCount: j['searchCount'] as int?, isRecommended: j['isRecommended'] as bool? ?? false,
  );
}
