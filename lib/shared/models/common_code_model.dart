class CommonCodeModel {
  final String groupCode;
  final String code;
  final String codeName;
  final String? codeValue;
  final int    displayOrder;
  const CommonCodeModel({required this.groupCode, required this.code, required this.codeName, this.codeValue, required this.displayOrder});
  factory CommonCodeModel.fromJson(Map<String, dynamic> j) => CommonCodeModel(
    groupCode: j['groupCode'] as String, code: j['code'] as String,
    codeName: j['codeName'] as String,  codeValue: j['codeValue'] as String?,
    displayOrder: j['displayOrder'] as int,
  );
}
