/// 사용자 주소(배송지) 모델.
///
/// 서버 응답: GET /api/users/me/addresses → AddressResponse
///   { addressId, alias, zipcode, address, addressDetail, isDefault, createdAt }
/// 본인 소유 주소이므로 마스킹 없이 평문으로 내려온다.
class Address {
  final int addressId;
  final String? alias;
  final String? zipcode;
  final String? address;
  final String? addressDetail;
  final bool isDefault;
  final DateTime? createdAt;

  const Address({
    required this.addressId,
    this.alias,
    this.zipcode,
    this.address,
    this.addressDetail,
    this.isDefault = false,
    this.createdAt,
  });

  /// 도로명 + 상세주소 합친 표시용 전체 주소
  String get fullAddress => [address, addressDetail]
      .where((s) => s != null && s.trim().isNotEmpty)
      .join(' ');

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        addressId: (j['addressId'] as num).toInt(),
        alias: j['alias'] as String?,
        zipcode: j['zipcode'] as String?,
        address: j['address'] as String?,
        addressDetail: j['addressDetail'] as String?,
        isDefault: j['isDefault'] == true,
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'].toString()),
      );
}
