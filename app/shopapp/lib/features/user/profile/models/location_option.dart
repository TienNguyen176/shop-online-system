/// Model dùng chung cho lựa chọn tỉnh/thành, quận/huyện, phường/xã.
class LocationOption {
  /// Mã định danh của địa điểm, có thể là số hoặc chuỗi tùy API GHN.
  final String id;

  /// Tên hiển thị của địa điểm.
  final String name;

  /// Khởi tạo một lựa chọn địa điểm.
  const LocationOption({
    required this.id,
    required this.name,
  });

  /// Tạo lựa chọn địa điểm từ JSON backend/GHN trả về.
  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
    );
  }
}
