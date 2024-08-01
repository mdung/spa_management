import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa_management/screens/booking_list_screen.dart';
import 'package:spa_management/screens/create_staff_screen.dart';
import 'package:spa_management/screens/create_user_screen.dart';
import 'package:spa_management/screens/future_revenue_screen.dart';
import 'package:spa_management/screens/home_screen.dart';
import 'package:spa_management/screens/location_list_screen.dart';
import 'package:spa_management/screens/login_screen.dart';
import 'package:spa_management/screens/reward_history_screen.dart';
import 'package:spa_management/screens/reward_screen.dart';
import 'package:spa_management/screens/service_customer_screen.dart';
import 'package:spa_management/screens/service_list_screen.dart';
import 'package:spa_management/screens/staff_list_screen.dart';
import 'package:spa_management/screens/staff_performance_screen.dart';
import 'package:spa_management/screens/user_list_screen.dart';
import 'package:spa_management/services/api_service.dart';


void main() async {
  // Initializes shared preferences
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final _apiService = ApiService();
  // Check login status
  bool? isLoggedIn = await _apiService.checkLoginStatus();

  // Define the app's initial route
  String initialRoute;
  if (isLoggedIn != null && isLoggedIn) {
    initialRoute = '/service';
  } else {
    initialRoute = '/home';
  }

  // Run the app
  runApp(MyApp(initialRoute: initialRoute, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final bool? isLoggedIn;
  final int? userId; // Add userId field
  final int? userCategoryId; // Add userId field

  MyApp({required this.initialRoute, required this.isLoggedIn, this.userId,this.userCategoryId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relaxation station',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => HomeScreen(
          isLoggedIn: isLoggedIn ?? false,
          helloMessage: isLoggedIn == true ? 'Hello!' : null,
          id: userId ?? 0, userCategoryId: userCategoryId ?? 0,
        ),
        '/login': (context) => LoginScreen(),
        '/user_list': (context) => UserListScreen(),
        '/add_user': (context) => CreateUserScreen(isLoggedIn: true,),
        '/service_list': (context) => ServiceListScreen(),
        '/staff_list': (context) => StaffListScreen(),
        '/staff_performance': (context) => StaffPerformanceScreen(),
        '/add_staff': (context) => CreateStaffScreen(),
        '/future_revenue': (context) => FutureRevenueScreen(bookings: [],),
        '/location_list': (context) => LocationListScreen(),
        '/booking_list': (context) => BookingListScreen(
          isLoggedIn: isLoggedIn ?? false,
          helloMessage: isLoggedIn == true ? 'Hello!' : null,
          userId: userId ?? 0,
        ),
        '/register': (context) => CreateUserScreen(isLoggedIn: false,),
        '/service': (context) => ServiceCustomerScreen.empty(),
        '/rewards': (context) => RewardsScreen(
          isLoggedIn: isLoggedIn ?? false,
          helloMessage: isLoggedIn == true ? 'Hello!' : null,
          id: userId ?? 0,
        ),
        '/rewards_history': (context) => RewardsHistoryScreen(id: userId ?? 0, isLoggedIn: true,),
      },

    );
  }
}

