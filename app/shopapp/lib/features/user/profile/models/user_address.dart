/// Model biểu diễn một địa chỉ giao hàng đã lưu của người dùng.
class UserAddress {
  /// ID địa chỉ trong database.
  final int id;

  /// Tên người nhận hàng.
  final String receiverName;

  /// Số điện thoại người nhận.
  final String phone;

  /// Số nhà, tên đường hoặc mô tả chi tiết địa chỉ.
  final String addressLine;

  /// Mã tỉnh/thành phố theo dữ liệu GHN.
  final int? provinceId;

  /// Tên tỉnh/thành phố.
  final String provinceName;

  /// Mã quận/huyện theo dữ liệu GHN.
  final int? districtId;

  /// Tên quận/huyện.
  final String districtName;

  /// Mã phường/xã theo dữ liệu GHN.
  final String wardCode;

  /// Tên phường/xã.
  final String wardName;

  /// Đánh dấu địa chỉ này có phải địa chỉ mặc định hay không.
  final bool isDefault;

  /// Chuỗi địa chỉ đầy đủ đã được backend ghép sẵn để hiển thị.
  final String fullAddress;

  /// Khởi tạo đầy đủ thông tin địa chỉ giao hàng.
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

  /// Tạo model địa chỉ từ JSON backend trả về.
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

  /// Chuyển địa chỉ thành request body để tạo/cập nhật địa chỉ hoặc đổi địa chỉ đơn hàng.
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
