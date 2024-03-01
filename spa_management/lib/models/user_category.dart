class UserCategory {
  int id;
  String name;

  UserCategory({required this.id, required this.name});

  factory UserCategory.fromJson(Map<String, dynamic> json) {
    return UserCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  String get categoryName => name; // Add this getter

}
