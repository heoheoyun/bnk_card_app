class TermsAgreeRequestModel {
  final int  termsId;
  final bool agreed;
  const TermsAgreeRequestModel({required this.termsId, required this.agreed});
  Map<String, dynamic> toJson() => {'termsId': termsId, 'agreed': agreed};
}
