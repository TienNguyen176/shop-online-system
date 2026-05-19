class Category {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? parentId;
  final int level;

  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parentId,
    this.level = 0,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['Id'];
    final rawParentId = json['parentId'] ?? json['ParentId'];
    final rawLevel = json['level'] ?? json['Level'];
    final rawChildren = json['children'] ?? json['Children'];

    return Category(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? "") ?? 0,
      name: (json['name'] ?? json['Name'] ?? "").toString(),
      slug: (json['slug'] ?? json['Slug'] ?? "").toString(),
      image: (json['image'] ?? json['Image'])?.toString(),
      parentId:
          rawParentId == null
              ? null
              : rawParentId is int
              ? rawParentId
              : int.tryParse(rawParentId.toString()),
      level:
          rawLevel is int ? rawLevel : int.tryParse(rawLevel?.toString() ?? "") ?? 0,
      children:
          (rawChildren as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "image": image,
      "parentId": parentId,
      "level": level,
    };
  }
}
