class UserAddress {
  final int id;
  final String receiverName;
  final String phone;
  final String addressLine;
  final int? provinceId;
  final String provinceName;
  final int? districtId;
  final String districtName;
  final String wardCode;
  final String wardName;
  final bool isDefault;
  final String fullAddress;

  const UserAddress({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    required this.provinceId,
    required this.provinceName,
    required this.districtId,
    required this.districtName,
    required this.wardCode,
    required this.wardName,
    required this.isDefault,
    required this.fullAddress,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      receiverName: json["receiverName"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      addressLine: json["addressLine"]?.toString() ?? "",
      provinceId: int.tryParse(json["provinceId"]?.toString() ?? ""),
      provinceName: json["provinceName"]?.toString() ?? "",
      districtId: int.tryParse(json["districtId"]?.toString() ?? ""),
      districtName: json["districtName"]?.toString() ?? "",
      wardCode: json["wardCode"]?.toString() ?? "",
      wardName: json["wardName"]?.toString() ?? "",
      isDefault: json["isDefault"] == true,
      fullAddress: json["fullAddress"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toRequest() {
    return {
      "receiverName": receiverName,
      "phone": phone,
      "addressLine": addressLine,
      "provinceId": provinceId,
      "provinceName": provinceName,
      "districtId": districtId,
      "districtName": districtName,
      "wardCode": wardCode,
      "wardName": wardName,
      "isDefault": isDefault,
    };
  }
}
