import 'package:flutter/material.dart';
import 'package:spa_management/screens/login_screen.dart';
import 'package:spa_management/widgets/menu_block.dart';

import 'api_service.dart';

class AuthenticatedWrapper extends StatefulWidget {
  final Widget child;

  AuthenticatedWrapper({required this.child});

  @override
  _AuthenticatedWrapperState createState() => _AuthenticatedWrapperState();
}

class _AuthenticatedWrapperState extends State<AuthenticatedWrapper> {
  bool isLoggedIn = false;
  int userId = 0;
  int userCategoryId = 0; // Define userCategoryId variable
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    bool status = await _apiService.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
      if (isLoggedIn) {
        userId = _apiService.userId;
        _apiService.getUserCategoryById(userId).then((value) {
          setState(() {
            userCategoryId = value.id; // set the value of userCategoryId here
          });
        });
        print('userId = $userId');
      }
    });
  }

  void onBookingCreated() {
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? Scaffold(
      drawer: MenuBlock(isLoggedIn: isLoggedIn, id: userId, userCategoryId: userCategoryId), // Pass id and userCategoryId to MenuBlock
      body: widget.child,
    )
        : LoginScreen();
  }
}
