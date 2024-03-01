import 'package:flutter/material.dart';
import 'package:spa_management/screens/home_screen.dart';
import 'package:spa_management/screens/staff_list_screen.dart';
import 'package:spa_management/services/api_service.dart';
import '../models/user.dart';
import '../models/user_category.dart';
import '../screens/booking_list_screen.dart';
import '../screens/dashboard.dart';
import '../screens/reward_history_screen.dart';
import '../screens/reward_screen.dart';
import '../screens/staff_performance_screen.dart';
import '../screens/statistic_booking_screen.dart';
import '../screens/statistic_popular_service_screen.dart';
import '../screens/statistic_popular_staff_screen.dart';
import '../screens/update_user_screen.dart';

class MenuBlock extends StatelessWidget {
  final bool isLoggedIn;
  final int id; // Add id field
  final int userCategoryId; // Add userCategoryId field
  MenuBlock({Key? key, required this.isLoggedIn, required this.id, required this.userCategoryId}) : super(key: key);

  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? FutureBuilder<UserCategory>(
      future: _apiService.getUserCategoryById(userCategoryId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userCategory = snapshot.data!;
          return Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('Relaxation Station'),
                  accountEmail: Text('info@yourapp.com'),
                  decoration: BoxDecoration(
                    color: Colors.teal, // set the background color of the header
                  ),
                  currentAccountPicture: Icon(
                    Icons.menu,
                    color: Colors.white, // set the color of the icon
                  ),
                ),
                if (userCategory.name != 'Manager')
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(isLoggedIn: true, id: id,userCategoryId:userCategoryId)),
                    );
                  },
                ),
                if (userCategory.name == 'Manager')
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DashboardScreen(isLoggedIn: true, id: id,userCategoryId:userCategoryId)),
                    );
                  },
                ),
                ExpansionTile(
                  leading: Icon(Icons.settings),
                  title: Text('Setting'),
                  children: [
                    ListTile(
                      title: Text('Update Profile'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FutureBuilder<User>(
                              future: _apiService.getUserById(id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return EditUserScreen(
                                    user: snapshot.data!,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        );
                      },

                    ),

                  ],
                ),
                ExpansionTile(
                  leading: Icon(Icons.card_giftcard),
                  title: Text('Rewards'),
                  children: [
                    ListTile(
                      title: Text('Rewards'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RewardsScreen(
                              isLoggedIn: true,
                              id: id,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text('Rewards History'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RewardsHistoryScreen(
                              isLoggedIn: true,
                              id: id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (userCategory.name == 'Manager')
                  ExpansionTile(
                    leading: Icon(Icons.people),
                    title: Text('User'),
                    children: [
                      ListTile(
                        title: Text('User List'),
                        onTap: () {
                          Navigator.pushNamed(context, '/user_list');
                        },
                      ),

                    ],
                  ),
                if (userCategory.name == 'Manager')
                  ExpansionTile(
                    leading: Icon(Icons.spa),
                    title: Text('Service'),
                    children: [
                      ListTile(
                        title: Text('Service List'),
                        onTap: () {
                          Navigator.pushNamed(context, '/service_list');
                        },
                      ),

                    ],
                  ),
                if (userCategory.name == 'Manager')
                  ExpansionTile(
                    leading: Icon(Icons.bar_chart),
                    title: Text('Statistic'),
                    children: [
                      ListTile(
                        title: Text('Staff List'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffListScreen(
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Staff Performance'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffPerformanceScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Booking Statistic'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingStatisticsScreen(userId: 0, startDate: '', endDate: '',),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Service Statistic'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  PopularServicesScreen(startDate: '', endDate: '',),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Staff Statistic'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  PopularStaffScreen(startDate: '', endDate: '',),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                if (userCategory.name == 'Manager')
                  ExpansionTile(
                    leading: Icon(Icons.location_city),
                    title: Text('Location'),
                    children: [
                      ListTile(
                        title: Text('Location List'),
                        onTap: () {
                          Navigator.pushNamed(context, '/location_list');
                        },
                      ),

                    ],
                  ),
                if (userCategory.name != 'Manager')
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Booking'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingListScreen(
                            userId: id,
                            isLoggedIn: true,
                          ),
                        ),
                      );
                    },
                  ),
                if (userCategory.name == 'Manager')
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Booking'),
                    onTap: () {
                      Navigator.pushNamed(context, '/booking_list');
                    },
                  ),

                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    bool result = await _apiService.logout();
                    if (result) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(isLoggedIn: false, id: 0, userCategoryId:userCategoryId)),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    )
        : Container();
  }

}
