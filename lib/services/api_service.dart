import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:spa_management/models/booking.dart';
import 'package:spa_management/models/service.dart';
import '../models/menu.dart';
import '../models/payment.dart';
import '../models/reward.dart';
import '../models/reward_history.dart';
import '../models/service_category.dart';
import '../models/staff.dart';
import '../models/location.dart';
import '../models/staff_performance.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/user_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';
import 'api_auth.dart';
import 'api_client.dart';

class ApiService extends ApiClient{
  int? _userId;

  set userId(int? value) {
    _userId = value;
  }

  int get userId {
    return _userId ?? 0;
  }

  final String baseUrl = 'http://127.0.0.1:5000';
  String? _token;
  Future<List<User>> getUsers() async {
    final response = await get('api/user');
    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }


  Future<User> getUserById(int id) async {
    final response = await get('api/user/$id');
    if (response.statusCode == 200) {
      Map<String, dynamic> userJson = jsonDecode(response.body);
      User user = User.fromJson(userJson);
      return user;
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<UserCategory>> getUserCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/user-category'));
    if (response.statusCode == 200) {
      List<dynamic> categoriesJson = jsonDecode(response.body);
      return categoriesJson.map((json) => UserCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user categories');
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    required int userCategoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'user_category_id': userCategoryId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      await saveToken(_token);
      return true;
    } else {
      return false;
    }
  }

  Future<void> saveToken(String? token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token ?? ''); // null safety update
  }


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token;
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }


  Future<Map<String, dynamic>?> login_detail(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await saveToken(token); // Save the token

      final jwtPayload = json.decode(utf8.decode(base64Url.decode(token.split('.')[1].padRight((token.split('.')[1].length + 3) & ~3, '='))));


      final id = int.parse(jwtPayload['user_id'].toString());
      final name = jwtPayload['name'];
      final user_category_id = jwtPayload['user_category_id'];
      return {'id': id, 'name': name,'user_category_id':user_category_id};
    } else {
      return null;
    }
  }


  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn');
    return isLoggedIn ?? false;
  }

  Future<bool> logout() async {
    final response = await post('api/logout');
    if (response.statusCode == 200) {
      await removeToken(); // Call removeToken()
      _token = null;
      return true;
    } else {
      return false;
    }
  }

  Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/api/service'));
    if (response.statusCode == 200) {
      List<dynamic> servicesJson = jsonDecode(response.body);
      List<Service> services = servicesJson.map((json) => Service.fromJson(json)).toList();
      return services;
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<Service> getService(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/service/$id'));
    if (response.statusCode == 200) {
      Map<String, dynamic> serviceJson = jsonDecode(response.body);
      Service service = Service.fromJson(serviceJson);
      return service;
    } else {
      throw Exception('Failed to load service');
    }
  }

  Future<List<Booking>> getBookings(int userId) async {
    final response = await get('api/booking_join/$userId');
    if (response.statusCode == 200) {
      List<dynamic> bookingsJson = jsonDecode(response.body);
      List<Booking> bookings = bookingsJson.map((json) => Booking.fromJson(json)).toList();
      return bookings;
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<bool> addBookingById(int bookingId) async {
    try {
      final Booking booking = await getBooking(bookingId);
      final response = await post('api/booking',
          body: booking.toJson());

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error adding booking: $e');
      return false;
    }
  }


  Future<Booking> getBooking(int id) async {
    final response = await get('api/booking/$id');
    if (response.statusCode == 200) {
      Map<String, dynamic> bookingJson = jsonDecode(response.body);
      Booking booking = Booking.fromJson(bookingJson);
      return booking;
    } else {
      throw Exception('Failed to load booking');
    }
  }

  Future<int> addBooking(Booking booking) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt('user_id');
    final response = await post(
      'api/booking',
      body: {
        'user_id': userId,
        'service_id': booking.serviceId,
        'staff_id': booking.staffId,
        'location_id': booking.locationId,
        'date': booking.date,
        'time': booking.time,
        'status': booking.status,
      },
    );
    if (response.statusCode == 200) {
      int bookingId = int.parse(response.body);
      return bookingId;
    } else {
      throw Exception('Failed to add booking');
    }
  }


  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  Future<bool> updateBooking(Booking booking, int id, {required int locationId, required String status, required String date, required String time, required int staffId, required int userId, required int serviceId}) async {
    final url = '$baseUrl/api/booking/$id';
    final headers = {'Content-Type': 'application/json'};
    String body = '';
    try {
      body = jsonEncode(booking.toJsonUpdate());
    } catch (e) {
      print(e);
    }

    final token = await getToken();
    final response = await httpClient.put(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', ...headers},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }




  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final response = await get('api/service_category');

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        final List<ServiceCategory> categories = categoriesJson.map((json) => ServiceCategory.fromJson(json)).toList();
        return categories;
      } else {
        throw Exception('Failed to load service categories');
      }
    } catch (e) {
      print('Error loading service categories: $e');
      throw Exception('Failed to load service categories');
    }
  }



  Future<Service> updateService(int id, String? name, String? description, double? price, String? duration, String? benefit, int? categoryId, String? staffMembers, String? imageUrl) async {
    try {
      final response = await put('api/service/$id', body: {
        'name': name,
        'description': description,
        'price': price?.toString(),
        'duration': duration,
        'benefit': benefit,
        'category_id': categoryId?.toString(),
        'staff_members': staffMembers,
        'image_url': imageUrl,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final service = Service.fromJson(responseData);
        return service;
      } else {
        throw Exception('Failed to update service.');
      }
    } catch (e) {
      print('Error updating service: $e');
      throw Exception('Failed to update service.');
    }
  }


  Future<bool> deleteService(int id) async {
    try {
      final response = await delete('api/service/$id');
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error deleting service: server returned status code ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting service: $error");
      return false;
    }
  }


  Future<void> deleteUser(int id) async {
    try {
      final response = await delete('api/user/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user.');
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user.');
    }
  }

  Future<ServiceCategory> getServiceCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/service-categories/$categoryId'));
    if (response.statusCode == 200) {
      final categoryJson = jsonDecode(response.body);
      return ServiceCategory(
        id: categoryJson['id'],
        name: categoryJson['name'],
      );
    } else {
      throw Exception('Failed to load service category');
    }
  }

  Future<User> updateUser(int id, String name, String email, String oldPassword, String newPassword, String confirmNewPassword) async {
    try {
      final response = await put('api/user/$id', body: {
        'name': name,
        'email': email,
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmNewPassword,
      });
      if (response.statusCode == 200) {
        print('response : $response.body');
        final responseData = json.decode(response.body.toString());
        print('responseData : $responseData');
        final user = User.fromJson(responseData['user']);
        return user;
      } else {
        throw Exception('Failed to update user.');
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user.');
    }
  }



  Future<void> deleteStaff(int? id) async {
    try {
      final response = await delete('api/staff/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete staff.');
      }
    } catch (e) {
      print('Error deleting staff: $e');
      throw Exception('Failed to delete staff.');
    }
  }



  Future<List<Staff>> getStaff() async {
    try {
      final response = await get('api/staff');
      if (response.statusCode != 200) {
        throw Exception('Failed to load staff.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final staffList = jsonList.map((json) => Staff.fromJson(json)).toList();
      return staffList;
    } catch (e) {
      print('Error loading staff: $e');
      print('Response body: ');
      throw Exception('Failed to load staff.');
    }
  }


  Future<List<Map<String, dynamic>>> getBookingStatistics(int userId, String startDate, String endDate) async {
    try {
      final response = await get('api/booking_stat/$userId/$startDate/$endDate');
      if (response.statusCode != 200) {
        throw Exception('Failed to load booking statistics.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final bookingList = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
      return bookingList;
    } catch (e) {
      print('Error loading booking statistics: $e');
      print('Response body: ');
      throw Exception('Failed to load booking statistics.');
    }
  }

  Future<List<Map<String, dynamic>>> getMostPopularServices(String startDate, String endDate) async {
    try {
      final response = await get('api/most_popular_services/$startDate/$endDate');
      if (response.statusCode != 200) {
        throw Exception('Failed to load most popular services.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final serviceList = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();// convert to Map<String, dynamic>
      return serviceList;
    } catch (e) {
      print('Error loading most popular services: $e');
      throw Exception('Failed to load most popular services.');
    }
  }

  Future<List<Map<String, dynamic>>> getMostPopularStaff(String startDate, String endDate) async {
    try {
      final response = await get('api/most_popular_staff/$startDate/$endDate');
      if (response.statusCode != 200) {
        throw Exception('Failed to load most popular staff.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final staffList = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();// convert to Map<String, dynamic>
      return staffList;
    } catch (e) {
      print('Error loading most popular staff: $e');
      throw Exception('Failed to load most popular staff.');
    }
  }

  Future<void> updateStaff(Staff staff) async {
    try {
      final url = Uri.parse('$baseUrl/api/staff/${staff.id}');
      final response = await put(url.toString(), body: staff.toJson());

      if (response.statusCode != 200) {
        throw Exception('Failed to update staff.');
      }
    } catch (e) {
      print('Error updating staff: $e');
      throw Exception('Failed to update staff.');
    }
  }


  Future<Staff> createStaff(Staff staff) async {
    try {
      final response = await post('api/staff', body: staff.toJson());

      if (response.statusCode != 200) {
        throw Exception('Failed to create staff.');
      }

      final jsonResponse = json.decode(response.body);
      return Staff.fromJson(jsonResponse);
    } catch (e) {
      print('Error creating staff: $e');
      throw Exception('Failed to create staff.');
    }
  }



  Future<List<LocationSpa>> getLocations() async {
    try {
    final response = await http.get(Uri.parse('$baseUrl/api/location'));
      if (response.statusCode != 200) {
        throw Exception('Failed to load locations.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final locationList = jsonList.map((json) => LocationSpa.fromJson(json as Map<String, dynamic>)).toList();
      return locationList;
    } catch (e) {
      print('Error loading locations: $e');
      throw Exception('Failed to load locations.');
    }
  }



  Future<void> deleteLocation(int id) async {
    try {
      final response = await delete('api/location/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete location.');
      }
    } catch (e) {
      print('Error deleting location: $e');
      throw Exception('Failed to delete location.');
    }
  }

  Future<void> updateLocation(int id, String name, String address, String city, String state, String zip, String? photoUrl) async {
    try {
      final response = await put('api/location/$id', body: {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to update location.');
      }
    } catch (e) {
      print('Error updating location: $e');
      throw Exception('Failed to update location.');
    }
  }



  Future<LocationSpa> createLocation({required String name, required String address,required city, required state, required zip}) async {
    try {
      final url = 'api/location';
      final response = await post(
        url,
        body: {'name': name, 'address': address, 'city': city, 'state': state, 'zip': zip},
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create location.');
      }

      final locationJson = json.decode(response.body);
      final location = LocationSpa.fromJson(locationJson);

      return location;
    } catch (e) {
      print('Error creating location: $e');
      throw Exception('Failed to create location.');
    }
  }


  Future<Booking> createBooking(
      Booking newBooking,
      {
        required int userId,
        required int serviceId,
        required int locationId,
        required String date,
        required String time,
        required String status,
        required int staffId,
      }) async {
    try {
      MyUtils utils = MyUtils();
      final url = 'api/booking';
      final encodedTime = utils.getUnixTimestamp(date, time);

      final staffResponse = await get(
        'api/first_available_staff?service_id=$serviceId&date=$date&time=$encodedTime',
      );

      if (staffResponse.statusCode != 200) {
        throw Exception('Failed to find available staff.');
      }

      final staffJson = jsonDecode(staffResponse.body);
      final staffId = staffJson['staff'];
      if (staffId == null) {
        throw Exception('No staff available for this service at the specified time.');
      }

      final response = await post(url, body: {
        'user_id': userId.toString(),
        'service_id': serviceId.toString(),
        'staff_id': staffId.toString(),
        'location_id': locationId.toString(),
        'date': date,
        'time': encodedTime.toString(),
        'status': status,
      });

      print('createBooking response: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to create booking.');
      }

      final bookingJson = jsonDecode(response.body);
      final booking = Booking.fromJson(bookingJson);
      return booking;
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Failed to create booking.');
    }
  }



  Future<bool> deleteBooking(int bookingId) async {
    try {
      final response = await delete('api/booking/$bookingId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }


  Future<List<Menu>> getMenuItems() async {
    try {
      final response = await get('api/menu/hierarchical');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse != null) {
          List<Menu> menuItems = [];
          for (var item in jsonResponse) {
            menuItems.add(Menu.fromJson(item));
          }
          return menuItems;
        } else {
          throw Exception('Response is null');
        }
      } else {
        throw Exception('Failed to retrieve menu items');
      }
    } catch (e) {
      throw Exception('Failed to retrieve menu items: $e');
    }
  }


  Future<List<Reward>> getRewards() async {
    try {
      final response = await get('api/rewards');
      if (response.statusCode != 200) {
        throw Exception('Failed to load rewards.');
      }
      final jsonList = json.decode(response.body) as List<dynamic>;
      final rewardsList = jsonList
          .map((json) => Reward.fromJson(json as Map<String, dynamic>))
          .toList();
      return rewardsList;
    } catch (e) {
      throw Exception('Failed to load rewards.');
    }
  }

  Future<bool> redeemReward(int rewardId, int userId, String date) async {
    try {
      final response = await post('api/rewards/$rewardId/redeem', body: {
        'user_id': userId,
        'date': date,
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to redeem reward.');
      }
    } catch (e) {
      throw Exception('Failed to redeem reward: $e');
    }
  }

  Future<String> uploadLocationPhoto(String filePath) async {
    try {
      final url = '$baseUrl/upload';
      final file = File(filePath);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final jsonResponse = await response.stream.bytesToString();
        final data = json.decode(jsonResponse);
        final photoUrl = data['photoUrl'];
        return photoUrl;
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      throw Exception('Failed to upload location photo: $e');
    }
  }


  Future<List<Reward>> fetchAvailableRewards(int userId) async {
    final response = await get('api/rewards-avail/$userId');
    if (response.statusCode == 200) {
      List<dynamic> rewardsJson = jsonDecode(response.body);
      List<Reward> rewards = rewardsJson.map((json) => Reward.fromJson(json)).toList();
      return rewards;
    } else {
      throw Exception('Failed to load available rewards');
    }
  }


  Future<List<dynamic>> fetchRewardHistory(int userId) async {
    final response = await get('api/reward-history/$userId');
    if (response.statusCode == 200) {
      List<dynamic> rewardHistoryJson = jsonDecode(response.body);
      List<dynamic> rewardHistoryList = rewardHistoryJson.map((json) => RewardHistory.fromJson(json)).toList();
      return rewardHistoryList;
    } else {
      throw Exception('Failed to load reward history');
    }
  }


  Future<UserCategory> getUserCategoryById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/user_category/$id'));
    if (response.statusCode == 200) {
      dynamic userCategoryJson = jsonDecode(response.body);
      return UserCategory.fromJson(userCategoryJson);
    } else {
      throw Exception('Failed to load user category');
    }
  }

  Future<List<StaffPerformance>> getStaffPerformance() async {
    final response = await get('api/staff_performance');
    if (response.statusCode == 200) {
      List<dynamic> staffPerformanceJson = jsonDecode(response.body);
      List<StaffPerformance> staffPerformance = staffPerformanceJson.map((json) => StaffPerformance.fromJson(json)).toList();
      return staffPerformance;
    } else {
      throw Exception('Failed to load staff performance metrics');
    }
  }


  Future<StaffPerformance> getStaffPerformanceById(int id) async {
    final response = await get('api/staff_performance/$id');
    if (response.statusCode == 200) {
      Map<String, dynamic> staffPerformanceJson = jsonDecode(response.body);
      StaffPerformance staffPerformance = StaffPerformance.fromJson(staffPerformanceJson);
      return staffPerformance;
    } else {
      throw Exception('Failed to load staff performance metric');
    }
  }


  Future<void> updateStaffPerformance(StaffPerformance staffPerformance) async {
    final response = await put('api/staff_performance/${staffPerformance.id}', body: staffPerformance.toJson());
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to update staff performance metric');
    }
  }


  Future<void> deleteStaffPerformance(int id) async {
    final response = await delete('api/staff_performance/$id');
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete staff performance metric');
    }
  }


  Future<void> createStaffPerformance(StaffPerformance staffPerformance) async {
    final response = await post('api/staff_performance', body: staffPerformance.toJson());
    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to create staff performance metric');
    }
  }

  Future<int> createTransaction(Transaction transaction) async {
    final response = await post(
      'api/transactions',
      body: transaction.toJson(),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['id'];
    } else {
      throw Exception('Failed to create transaction');
    }
  }

  Future<int> createPayment(Payment payment) async {
    final response = await post(
      'api/payments',
      body: payment.toJson(),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['transaction_id'];
    } else {
      throw Exception('Failed to create payment');
    }
  }



}

