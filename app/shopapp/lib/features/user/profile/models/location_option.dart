class LocationOption {
  final String id;
  final String name;

  const LocationOption({
    required this.id,
    required this.name,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
    );
  }
}
