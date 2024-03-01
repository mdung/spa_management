import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spa_management/models/booking.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/models/user.dart';
import 'package:spa_management/models/staff.dart';
import 'package:spa_management/models/location.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking;

  EditBookingScreen({required this.booking});

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
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

    _name = widget.booking.clientName;
    _date = DateFormat('yyyy-MM-dd').format(widget.booking.date);
    _time = widget.booking.time;
    _serviceId = widget.booking.serviceId;
    _staffId = widget.booking.staffId;
    _userId = widget.booking.userId;
    _locationId = widget.booking.locationId;
    _status = widget.booking.status;

    _dateController.text = DateFormat.yMd().add_jm().format(
      DateTime(
        widget.booking.date.year,
        widget.booking.date.month,
        widget.booking.date.day,
        widget.booking.time.hour,
        widget.booking.time.minute,
      ),
    );
  }

  Future<void> _getServices() async {
    await ApiAuth.checkTokenAndNavigate(context);
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
      final time = TimeOfDay(
        hour: _time.hour,
        minute: _time.minute,
      );
      final date = DateFormat('yyyy-MM-dd').parse(_date);
      Booking updatedBooking = Booking(
        id: widget.booking.id,
        userId: _userId,
        serviceId: _serviceId,
        staffId: _staffId,
        locationId: _locationId,
        loyaltyPointsEarned: _loyaltyPointsEarned,
        date: date,
        time: time,
        status: _status, serviceName: '', clientName: '', staffName: '', location: '', service: null, user: null,
      );

      try {
        final updated = await _apiService.updateBooking(updatedBooking,
          widget.booking.id,
          userId: _userId,
          serviceId: _serviceId,
          staffId: _staffId,
          locationId: _locationId,
          date: _date,
          time: _time.format(context),
          status: _status,);
        if (updated != null) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update booking')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update booking')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    List<String> statusList = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
    return FutureBuilder(
        future: _apiService.getBooking(widget.booking.id),
        builder: (context, AsyncSnapshot<Booking> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error fetching booking details'),
              ),
            );
          } else if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Text('Booking not found'),
              ),
            );
          }
          Booking booking = snapshot.data!;
          _serviceId = booking.serviceId;
          _staffId = booking.staffId;
          _userId = booking.userId;
          _locationId = booking.locationId;
          _status = booking.status;
          _date = DateFormat('yyyy-MM-dd').format(booking.date);
          _time =
              TimeOfDay(hour: booking.time.hour, minute: booking.time.minute);
          _dateController.text =
              DateFormat.yMd().add_jm().format(DateTime(
                  booking.date.year, booking.date.month, booking.date.day,
                  booking.time.hour, booking.time.minute));

          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Booking'),
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
                      items: _services.map((service) {
                        return DropdownMenuItem(
                          value: service.id,
                          child: Text(service.name),
                        );
                      }).toList(),
                      value: _serviceId,
                      onChanged: (int? newValue) {
                        setState(() {
                          _serviceId = newValue!;
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
                          .map((staff) =>
                          DropdownMenuItem(
                            value: staff.id,
                            child: Text(staff.name),
                          ))
                          .toList(),
                      value: _staffId,
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
                          .map((user) =>
                          DropdownMenuItem(
                            value: user.id,
                            child: Text(user.name),
                          ))
                          .toList(),
                      value: _userId,
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
                          .map((location) =>
                          DropdownMenuItem(
                            value: location.id,
                            child: Text(location.name),
                          ))
                          .toList(),
                      value: _locationId,
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
                      validator: (value) {
                        if (value == null || value.toString().isEmpty) {
                          return 'Please select a status';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _status = value as String;
                        });
                      },
                      value: _status,
                      items: statusList
                          .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
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
                              _date =
                                  DateFormat('yyyy-MM-dd').format(selectedDate);
                              _time = selectedTime;
                              _dateController.text =
                                  DateFormat.yMd().add_jm().format(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date and time';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      child: Text('Save Changes'),
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
    );
  }
}