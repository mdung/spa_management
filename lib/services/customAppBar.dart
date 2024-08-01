import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;

  const CustomAppBar({required this.username});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('My App'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Hello, $username'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
