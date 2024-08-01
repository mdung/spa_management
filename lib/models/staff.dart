import 'dart:convert';

class Staff {
  int? id;
  String name;
  String? position;
  late String bio;
  late String photo;
  late String email;
  late String phone;
  late String address;

  var count;

  Staff({
    this.id,
    required this.name,
    this.position,
    required this.bio,
    required this.photo,
    required this.email,
    required this.phone,
    required this.address, required String imageUrl,
  });

  Staff.fromNameAndCount(this.name, this.count);

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      bio: json['bio'] ?? '',
      photo: json['photo'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      imageUrl: '',
    );
  }

  get imageUrl => null;


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'bio': bio,
      'photo': photo,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
