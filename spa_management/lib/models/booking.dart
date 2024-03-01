import 'package:flutter/material.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/models/user.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
class Booking {
  final int id;
  final int userId;
  final int serviceId;
  final int staffId;
  final int locationId;
  final int loyaltyPointsEarned;
  final DateTime date;
  final TimeOfDay time;
  final String status;
  final String serviceName;
  final String clientName;
  final String staffName;
  final String location;
  Service? service;
  final User? user;



  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.staffId,
    required this.locationId,
    required this.loyaltyPointsEarned,
    required this.date,
    required this.time,
    required this.status,
    required this.serviceName,
    required this.clientName,
    required this.staffName,
    required this.location,
    required this.service,
    required this.user,

  });


  factory Booking.fromJson(Map<String, dynamic> json)   {
    final _apiService = ApiService();
    MyUtils utils = MyUtils();
    final date = json['date'];
    print('date from JSON: $date');

    final time = json['time'];
    print('time from JSON: $time');

    final status = json['status'];
    print('status from JSON: $status');

    final name = json['name'];
    print('name from JSON: $name');

    final serviceJson = json['service_id'];
    final userJson = json['user_id'];
    final staffJson = json['staff_id'];

    final phone = json['phone'];
    print('phone from JSON: $phone');

    final email = json['email'];

    return Booking(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      staffId: json['staff_id'],
      locationId: json['location_id'],
      loyaltyPointsEarned: 0,
      date: DateTime.parse(json['date']),
      time: _parseTime((utils.formatTime(json['time']) )),
      status: json['status'] ?? '',
      serviceName: json['service_name'] ?? '',
      clientName: json['user_name'] ?? '',
      staffName: json['staff_name'] ?? '',
      location: json['location_name'] ?? '',
      service: null,
      user: null,
    );
  }

 static Future<Service> _getService(int serviceId) async {
    final apiService = ApiService();
    final service = await apiService.getService(serviceId);
    return service;
  }

  static Future<User> _getUser(int userId) async {
    final apiService = ApiService();
    final user = await apiService.getUserById(userId);
    return user;
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(' ');
    final time = TimeOfDay(
      hour: int.parse(parts[0].split(':')[0]),
      minute: int.parse(parts[0].split(':')[1]),
    );
    return time;
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'staff_id': staffId,
      'location_id': locationId,
      'date': date.toString(),
      'time': time.toString(),
      'status': status,
      'name': serviceName,
      'clientName': clientName,
      'staffName': staffName,
      'location': location,
      'service': service?.toJson(),
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    MyUtils utils = MyUtils();
    String dateString  = utils.formatDate(date.toString());
    String timeString  = utils.formatTimeOfDay(time);
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'staff_id': staffId,
      'location_id': locationId,
      'date': dateString,
      'time': timeString,
      'status': status,
    };
  }
}
