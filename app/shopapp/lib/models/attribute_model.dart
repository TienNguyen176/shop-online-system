class AttributeModel {
  final int id;
  final String name;
  final List<String> values;

  AttributeModel({required this.id, required this.name, required this.values});

  /// Tao doi tuong tu du lieu JSON.
  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      id: json['id'],
      name: json['name'],
      values: List<String>.from(json['values']),
    );
  }

  /// Chuyen doi doi tuong hien tai thanh du lieu JSON.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "values": values,
    };
  }
}
