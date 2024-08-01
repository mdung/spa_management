import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../widgets/menu_block.dart';
import 'package:intl/intl.dart';

import 'future_revenue_screen.dart';
class DashboardScreen extends StatefulWidget {
  final bool isLoggedIn;
  final int id; // new field for id
  final int userCategoryId;

  DashboardScreen(
      {Key? key, required this.isLoggedIn, required this.id, required this.userCategoryId})
      : super(key: key);


  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _timeFormat = DateFormat('h:mm a');
  final _apiService = ApiService();
  List<Booking> _bookings = [];
  List<Booking> _bookingsRevenu = [];
  bool _loggedIn = false;
  final List<Map<String, dynamic>> bookings = [    {      'date': '2022-04-01',      'time': '14:00',      'service': 'Swedish Massage',      'staff': 'John Doe'    },    {      'date': '2022-03-28',      'time': '11:30',      'service': 'Facial',      'staff': 'Jane Smith'    },    {      'date': '2022-03-25',      'time': '15:00',      'service': 'Pedicure',      'staff': 'Samantha Jones'    },  ];
  late  double revenue = 0.0;
  final int numBookings = 3;
  int nbBookingAvailable = 0;


  @override
  void initState() {
    super.initState();
    _loggedIn = widget.isLoggedIn;
    _getLastBookings();
  }

  Future<void> _getLastBookings() async {
    if (widget.id == 0) {
      // Get all bookings if user is manager
      _bookings = await _apiService.getBookings(0);
    } else {
      // Get bookings for current user
      final bookings = await _apiService.getBookings(0);
      // Filter out bookings that have already passed
      final now = DateTime.now();
      _bookings = bookings.where((booking) => booking.date.isAfter(now)).toList();
      _bookingsRevenu = _bookings;
      // Add service to each element in _bookingsRevenu
      for (final bookingR in _bookingsRevenu) {
        final serviceR = await _apiService.getService(bookingR.serviceId);
        bookingR.service = serviceR;
      }

    }

    // Calculate revenue for bookings in which the date and time are after now
    double revenue = 0.0;
    final revenueBookings = _bookings.where((booking) => booking.date.isAfter(DateTime.now()));
    for (final booking in revenueBookings) {
      final service = await _apiService.getService(booking.serviceId);
      revenue += service.price;
    }
    nbBookingAvailable= _bookings.length;
    // Sort bookings by datetime
    _bookings.sort((a, b) => a.date.compareTo(b.date));
    // Get the last 3 bookings
    _bookings = _bookings.reversed.take(numBookings).toList();

    // Update the revenue variable in the state
    setState(() {
      this.revenue = revenue;
    });
  }


  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        drawer: MenuBlock(
            isLoggedIn: _loggedIn, id: widget.id, userCategoryId: widget.userCategoryId),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _bookings.length,
                    itemBuilder: (BuildContext context, int index) {
                      final booking = _bookings[index];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.white),
                              SizedBox(width: 10.0),
                              Text(
                                _bookings.isNotEmpty ? _dateFormat.format(booking.date) : '-',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Icon(Icons.access_time, color: Colors.white),
                              SizedBox(width: 10.0),
                              Text(
                                _bookings.isNotEmpty ? _timeFormat.format(DateTime(0, 0, 0, booking.time.hour, booking.time.minute)) : '-',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Icon(Icons.work, color: Colors.white),
                              SizedBox(width: 10.0),
                              Text(
                                booking.serviceName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Icon(Icons.person, color: Colors.white),
                              SizedBox(width: 10.0),
                              Text(
                                booking.staffName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Divider(color: Colors.white),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.green,
              ),
              child: Column(
                children: [
                  Text(
                    'Number of Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    nbBookingAvailable.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureRevenueScreen(bookings: _bookingsRevenu),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.orange,
                ),
                child: Column(
                  children: [
                    Text(
                      'Revenue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    if (revenue != null) // Add a null check for revenue
                      TweenAnimationBuilder(
                        duration: Duration(seconds: 1),
                        tween: Tween(begin: 0.0, end: revenue),
                        builder: (context, double value, child) => Text(
                          '\$${value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
         ],
      ),
    );
  }

}