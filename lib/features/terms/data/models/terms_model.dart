class TermsModel {
  final int    termsId;
  final String title;
  final String termsType;
  final bool   required;
  final String? fileUrl;
  const TermsModel({required this.termsId, required this.title, required this.termsType, required this.required, this.fileUrl});
  factory TermsModel.fromJson(Map<String, dynamic> j) => TermsModel(
    termsId: j['termsId'] as int, title: j['title'] as String,
    termsType: j['termsType'] as String, required: j['required'] as bool? ?? false,
    fileUrl: j['fileUrl'] as String?,
  );
}
