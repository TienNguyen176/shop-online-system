class AttributeModel {
  final int id;
  final String name;
  final List<String> values;

  AttributeModel({required this.id, required this.name, required this.values});

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      id: json['id'],
      name: json['name'],
      values: List<String>.from(json['values']),
    );
  }
}