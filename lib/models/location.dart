import 'dart:convert';

class LocationSpa {
  final int id;
  late final String name;
  late final String address;
  late final String city;
  late final String state;
  late final String zip;
  double latitude = 0.0; // Initialize with a default value
  double longitude = 0.0; // Initialize with a default value
   String? photo;

  LocationSpa({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    this.photo,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSpa.fromJson(Map<String, dynamic> json) {
    return LocationSpa(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      photo: json['photo'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }
}
