class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json, String id) {
    return Category(
      id: id,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
