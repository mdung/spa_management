import 'package:flutter/material.dart';
import 'package:spa_management/models/booking.dart';
import 'package:spa_management/services/api_service.dart';
import 'package:intl/intl.dart';
import 'booking_create_screen.dart';
import 'booking_edit_screen.dart';

class BookingListScreen extends StatefulWidget {
  final int userId;
  final bool isLoggedIn;
  final String? helloMessage;
  const BookingListScreen({Key? key, this.helloMessage,required this.userId, required this.isLoggedIn}) : super(key: key);

  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _apiService = ApiService();

  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _apiService.getBookings(widget.userId);
  }

  void _deleteBooking(BuildContext context, Booking booking) async {
    bool result = await _apiService.deleteBooking(booking.id);
    if (result) {
      setState(() {
        _bookingsFuture = _apiService.getBookings(widget.userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              bool undoResult = await _apiService.addBookingById(booking.id);
              if (undoResult) {
                setState(() {
                  _bookingsFuture = _apiService.getBookings(widget.userId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking restored.'),
                  ),
                );
              }
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete booking.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings'),
      ),
      body: FutureBuilder(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Booking>? bookings = snapshot.data;
            return ListView.builder(
              itemCount: bookings?.length,
              itemBuilder: (context, index) {
                Booking booking = bookings![index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service: ${booking.serviceName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Date: ${DateFormat.yMd().format(booking.date)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Time: ${booking.time.format(context)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Client: ${booking.clientName}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Staff: ${booking.staffName}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Location: ${booking.location}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Points earned: ${booking.service?.loyalty_points ?? 0}',
                              style: TextStyle(fontSize: 16.0),
                            ),

                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditBookingScreen(booking: booking),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 16.0),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () async {
                                _deleteBooking(context, booking);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBookingScreen(),
            ),
          ).then((result) {
            if (result != null && result) {
              setState(() {
                _bookingsFuture = _apiService.getBookings(widget.userId);
              });
            }
          });
        },
      ),
    );
  }



}