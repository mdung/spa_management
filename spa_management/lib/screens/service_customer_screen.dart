import 'package:flutter/material.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/screens/service_detail_customer_screen.dart';
import 'package:spa_management/screens/login_screen.dart';
import 'package:spa_management/widgets/logout_button.dart';

import '../models/location.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../widgets/menu_block.dart';


class ServiceCustomerScreen extends StatefulWidget {
  const ServiceCustomerScreen({
    Key? key,
    required this.username,
    required this.isLoggedIn,
    required this.name,
    required this.id,
    required this.userCategoryId,
    required this.locations,  required this.selectedLocationIndex,
  }) : super(key: key);

  final String username;
  final String name;
  final int id;
  final int userCategoryId;
  final bool isLoggedIn;
  final List<LocationSpa> locations;
  final int selectedLocationIndex;

  // Constructor with no parameters
  ServiceCustomerScreen.empty()
      : username = '',
        isLoggedIn = false,
        name = '',
        id = 0,
        userCategoryId = 0,
        locations = const [],
        selectedLocationIndex = 0;

  @override
  _ServiceCustomerScreenState createState() => _ServiceCustomerScreenState();
}


class _ServiceCustomerScreenState extends State<ServiceCustomerScreen> {
  final _apiService = ApiService();
  late Future<List<Service>> _servicesFuture;
  final _myUtils = MyUtils();

  @override
  void initState() {
    super.initState();
    _servicesFuture = _apiService.getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        actions: [
          if (widget.isLoggedIn)
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                'Hello, ${widget.username}!',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
      drawer: widget.isLoggedIn ? MenuBlock(isLoggedIn: true,id: widget.id, userCategoryId: widget.userCategoryId) : null,

      body: Container(
        decoration: _myUtils.buildBackgroundImage(widget.locations, widget.selectedLocationIndex),
        child: Column(
          children: [
            SizedBox(height: 20),
            if (widget.isLoggedIn)
              Text(
                'Hello, ${widget.username}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            SizedBox(height: 50),
            Expanded(
              child: FutureBuilder<List<Service>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Service>? services = snapshot.data;
                    return ListView.builder(
                      itemCount: services!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailScreen(
                                  service: services[index],
                                  isLoggedIn: widget.isLoggedIn,
                                  id: widget.id,
                                  name: widget.name,
                                ),
                              ),
                            );
                          },
                            child: Card(
                            elevation: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(services[index].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        services[index].name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        services[index].description,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Duration: ${services[index].duration}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Price: ${services[index].price}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load services.'),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
