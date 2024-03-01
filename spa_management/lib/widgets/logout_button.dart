import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final bool isLoggedIn;
  final void Function()? onPressed;

  const LogoutButton({Key? key, required this.isLoggedIn, this.onPressed, required Future<Null> Function() onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoggedIn,
      child: IconButton(
        icon: Icon(Icons.logout),
        onPressed: onPressed,
      ),
    );
  }
}
