import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
class FutureRevenueScreen extends StatefulWidget {
  final List<Booking> bookings;

  const FutureRevenueScreen({Key? key, required this.bookings}) : super(key: key);

  @override
  _FutureRevenueScreenState createState() => _FutureRevenueScreenState();
}

class _FutureRevenueScreenState extends State<FutureRevenueScreen> with TickerProviderStateMixin {
  final _apiService = ApiService();
  late AnimationController _controller;
  late Animation<double> _animation;
  double _revenue = 0;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller and animation
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Calculate revenue
    _calculateRevenue();

    // Start the animation
    _controller.forward();
  }

  Future<void> _calculateRevenue() async {
    double revenue = 0;
    for (final booking in widget.bookings) {
      final service = await _apiService.getService(booking.serviceId);
      revenue += service.price;
    }
    setState(() {
      _revenue = revenue;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Future Revenue'),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookings for Future Revenue:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.bookings.length,
                  itemBuilder: (BuildContext context, int index) {
                    final booking = widget.bookings[index];
                    final isOdd = index % 2 == 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: isOdd ? Colors.grey[200] : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'No: ${index + 1}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  Text(
                                    'Date: ${DateFormat.yMd().format(booking.date)}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  Text(
                                    'Time: ${booking.time.format(context)}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Service: ${booking.serviceName}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  Text(
                                    'Staff: ${booking.staffName}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price: \$${booking.service?.price?.toStringAsFixed(2) ?? ''}',
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
