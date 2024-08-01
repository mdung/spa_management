import 'package:flutter/material.dart';
import 'package:spa_management/screens/service_customer_screen.dart';
import 'package:spa_management/screens/login_screen.dart';
import 'package:spa_management/screens/create_user_screen.dart';
import '../models/location.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../widgets/menu_block.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? helloMessage;
  final bool isLoggedIn;
  final int id; // new field for id
  final int userCategoryId; // new field for id

  const HomeScreen({Key? key, this.helloMessage, required this.isLoggedIn,required this.id,required this.userCategoryId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _helloMessage;
  bool _loggedIn = false;
  late List<LocationSpa> _locations = [];
  int _selectedLocationIndex = 1;
  final _apiService = ApiService();
  final _myUtils = MyUtils();

  @override
  void initState() {
    super.initState();
    _helloMessage = widget.helloMessage;
    _loggedIn = widget.isLoggedIn;
    _selectedLocationIndex = 0;
    _fetchLocations();
  }

  void _handleLogout() {
    setState(() {
      _loggedIn = false;
    });
    Navigator.pop(context, _loggedIn);
  }

  void _fetchLocations() async {
    try {
      final locations = (await _apiService.getLocations()).cast<LocationSpa>();
      setState(() {
        print('Printing locations:');
        locations.forEach((location) {
          print('Location ID: ${location.id}');
          print('Location Name: ${location.name}');
          print('Location Photo URL: ${location.photo}');
          print('Location Address: ${location.address}');
        });
        _locations = locations;
      });
    } catch (e) {
      print('Error loading locations: $e');
      throw Exception('Failed to load locations.');
    }
  }


  void _handleLocationChange(int? value) {
    setState(() {
      _selectedLocationIndex = value!;
    });
    _buildBackgroundImage();
  }


  BoxDecoration _buildBackgroundImage() {
    if (_locations.isNotEmpty && _locations[_selectedLocationIndex].photo != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_locations[_selectedLocationIndex].photo!),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/spa_background4.jpg'),
          fit: BoxFit.cover,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      drawer: MenuBlock(isLoggedIn: _loggedIn, id: widget.id, userCategoryId: widget.userCategoryId),
      body: Container(
        decoration: _myUtils.buildBackgroundImage(_locations, _selectedLocationIndex),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            DropdownButton(
            value: _selectedLocationIndex,
            items: _locations.map(
                  (location) => DropdownMenuItem(
                value: _locations.indexOf(location),
                child: Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Text(
                      location.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
            onChanged: _handleLocationChange,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 32,
            underline: Container(),
            elevation: 8,
            isExpanded: true,
          ),
              InkResponse(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(location: _locations[_selectedLocationIndex]),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Icon(
                    Icons.map,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ),


              SizedBox(height: 20),
              Text(
                'Welcome to ${_locations[_selectedLocationIndex].name}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Relax and enjoy the soothing atmosphere',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                child: Text(
                  'Services',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceCustomerScreen(
                        id: widget.id,
                        isLoggedIn: widget.isLoggedIn, username: '', name: '', userCategoryId: widget.userCategoryId,locations: _locations,selectedLocationIndex: _selectedLocationIndex,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              if (_helloMessage == null && !_loggedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text('Login'),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            setState(() {
                              _helloMessage = 'Hello!';
                              _loggedIn = true;
                            });
                          }
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      child: Text('Register'),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateUserScreen(isLoggedIn: false,),
                          ),
                        );
                      },
                    ),
                  ],
                ),

              if (_helloMessage != null)
                Column(
                  children: [
                    Text(
                      _helloMessage!,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }


}
