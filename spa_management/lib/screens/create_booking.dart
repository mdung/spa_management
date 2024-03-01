import 'package:flutter/material.dart';
import 'package:spa_management/models/booking.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/services/api_service.dart';
import '../services/api_auth.dart';
import '../utils/utils.dart';

class BookingScreen extends StatefulWidget {
  final bool isLoggedIn;
  final int serviceId;
  final int staffId;
  final int locationId;
  final Service service;
  final int userId;
  final String name;
  final int loyaltyPointsEarned;
  final int loyaltyPointsRedeemed;

  BookingScreen({
    required this.isLoggedIn,
    required this.serviceId,
    required this.staffId,
    required this.locationId,
    required this.service,
    required this.userId,
    required this.name,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsRedeemed,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _date;
  TimeOfDay? _time;
  ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';

  Future<void> _buildDateAndTimePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2024),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _date = selectedDate.toIso8601String().split('T').first;
          _time = selectedTime;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Session'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Expanded(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select a Date and Time',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _buildDateAndTimePicker(context),
              child: Text('Pick a Date and Time'),
            ),
            SizedBox(height: 20.0),
            if (_date != null && _time != null) ...[
              Text(
                'You are booking the service:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Text(
                widget.service.name,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Date: $_date',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Time: ${_time!.format(context)}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loyalty points earned:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '${widget.service.loyalty_points}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),

            ],
          ],
        ),
      ),
      SizedBox(height: 20.0),
      _isSuccess
          ? Text(
        'Booking created successfully!',
        style: TextStyle(color: Colors.green),
      )
          : Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      ),
      SizedBox(height: 20.0),
      _isLoading
          ? Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : _date == null || _time == null
          ? Expanded(
        child: ElevatedButton(
          onPressed: null,
          child: Text('Book Session'),
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
          ),
        ),
      )
          : Expanded(
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            try {
              final userId = widget.isLoggedIn ? widget.userId : 0;
              final newBooking = Booking(
                serviceName: '',
                date: DateTime.parse(_date!),
                time: _time!,
                id: 0,
                userId: userId,
                serviceId: widget.serviceId,
                staffId: widget.staffId,
                locationId: widget.locationId,
                loyaltyPointsEarned: widget.service.loyalty_points,
                status: 'Pending',
                service: null,
                user: null,
                clientName: '',
                staffName: '',
                location: '',
              );
              MyUtils utils = MyUtils();
              await ApiAuth.checkTokenAndNavigate(context);
              var result =
              await _apiService.createBooking(
                newBooking,
                userId: userId,
                serviceId: widget.serviceId,
                staffId: 1,
                locationId: 1,
                date: utils.formatDate(_date!),
                time: utils.formatTimeOfDay(_time!),
                status: 'Pending',
              );
              if (result != null) {
                setState(() {
                  _isSuccess = true;
                  _isLoading = false;
                  _errorMessage = '';
                });
              } else {
                setState(() {
                  _isSuccess = false;
                  _isLoading = false;
                  _errorMessage = 'Failed to create booking';
                });
              }
            } catch (e) {
              setState(() {
                _isSuccess = false;
                _isLoading = false;
                _errorMessage = 'Failed to create booking: $e';
              });
            }
          },
          child: Text('Book Session'),
        ),
      ),
          ],
        ),
      ),
    );
  }
}