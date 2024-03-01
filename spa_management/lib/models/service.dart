import '../services/api_service.dart';

class Service {
  late int id;
  late String name;
  late String description;
  late double price;
  late String duration;
  late String benefit;
  late int categoryId;
  late int loyalty_points;
  late String staffMembers;
  late String imageUrl;

  int? count;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.benefit,
    required this.categoryId,
    required this.loyalty_points,
    required this.staffMembers,
    required this.imageUrl,
    this.count,
  });


  Service.fromNameAndCount(this.name, this.count);

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ,
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      benefit: json['benefit'],
      categoryId: json['category_id'] != null ? json['category_id'].toInt() : null,
      loyalty_points: json['loyalty_points'] != null ? json['loyalty_points'].toInt() : null,
      staffMembers: json['staff_members'],
      imageUrl: json['image_url'],
      count: json['count'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'benefit': benefit,
      'category_id': categoryId,
      'staff_members': staffMembers,
      'image_url': imageUrl,
      'count': count ?? null, //
    };
  }
  Future<void> reload() async {

    final apiService = ApiService();
    final updatedService = await apiService.getService(id);

    if (updatedService != null) {
      name = updatedService.name;
      description = updatedService.description;
      price = updatedService.price;
      duration = updatedService.duration;
      benefit = updatedService.benefit;
      categoryId = updatedService.categoryId;
      staffMembers = updatedService.staffMembers;
      imageUrl = updatedService.imageUrl;
      count = updatedService.count;
    }
  }
}

