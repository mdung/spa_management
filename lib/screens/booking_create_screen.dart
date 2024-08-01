import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spa_management/models/booking.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/models/user.dart';
import 'package:spa_management/models/staff.dart';
import 'package:spa_management/models/location.dart';
import 'package:spa_management/services/api_service.dart';

class CreateBookingScreen extends StatefulWidget {
  @override
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String _token = ''; // Add toke
  late String _name;
  late String _date;
  late TimeOfDay _time;
  late int _serviceId;
  late int _staffId;
  late int _userId;
  late int _locationId;
  late int _loyaltyPointsEarned;
  late int _loyalty_points_redeemed;
  late String _status;
  List<Service> _services = [];
  List<Staff> _staffList = [];
  List<User> _users = [];
  List<LocationSpa> _locations = [];

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getServices();
    _getStaff();
    _getUsers();
    _getLocations();
  }

  Future<void> _getServices() async {
    List<Service> services = await _apiService.getServices();
    setState(() {
      _services = services;
    });
  }

  Future<void> _getStaff() async {

    try {
      _token = (await _apiService.getToken())!; // Get the token
      List<Staff> staffList = await _apiService.getStaff();
      setState(() {
        _staffList = staffList;
      });
    } catch (e) {
      print('Error loading staff: $e');
    }
  }

  Future<void> _getUsers() async {
    List<User> users = await _apiService.getUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _getLocations() async {
    List<LocationSpa> locations = await _apiService.getLocations();
    setState(() {
      _locations = locations;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Booking newBooking = Booking(
        serviceName: _services.firstWhere((service) => service.id == _serviceId).name,
        date: DateFormat('yyyy-MM-dd').parse(_date),
        time: _time,
        service: _services.firstWhere((service) => service.id == _serviceId),
        user: _users.firstWhere((user) => user.id == _userId),
        id: 0,
        userId: _userId,
        serviceId: _serviceId,
        staffId: _staffId,
        locationId: _locationId,
        loyaltyPointsEarned: _loyaltyPointsEarned,
        status: _status,
        clientName: '',
        staffName: _staffList.firstWhere((staff) => staff.id == _staffId).name,
        location: _locations.firstWhere((location) => location.id == _locationId).name,
      );

      try {
        final createdBooking = await _apiService.createBooking(
          newBooking,
          userId: _userId,
          serviceId: _serviceId,
          staffId: _staffId,
          locationId: _locationId,
          date: _date,
          time: _time.format(context),
          status: 'Pending',
        );

        if (createdBooking != null) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create booking')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking')),
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    List<String> statusList = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Service',
                  border: OutlineInputBorder(),
                ),
                items: _services
                    .map((service) => DropdownMenuItem(
                  value: service.id,
                  child: Text(service.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _serviceId = value as int;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Staff',
                  border: OutlineInputBorder(),
                ),
                items: _staffList
                    .map((staff) => DropdownMenuItem(
                  value: staff.id,
                  child: Text(staff.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _staffId = value as int;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder(),
                ),
                items: _users
                    .map((user) => DropdownMenuItem(
                  value: user.id,
                  child: Text(user.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _userId = value as int;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                items: _locations
                    .map((location) => DropdownMenuItem(
                  value: location.id,
                  child: Text(location.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _locationId = value as int;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statusList
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value as String;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Select Date and Time'),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _date = DateFormat('yyyy-MM-dd').format(selectedDate);
                        _time = selectedTime;
                        _dateController.text = DateFormat.yMd().add_jm().format(
                          DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          ),
                        );
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Selected Date and Time',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Create Booking'),
                onPressed: () {
                  _submitForm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


}