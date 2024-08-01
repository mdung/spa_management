import 'package:flutter/material.dart';
import 'package:spa_management/models/user.dart';
import 'package:spa_management/screens/create_user_screen.dart';
import 'package:spa_management/screens/update_user_screen.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = [];
  bool _loading = true;
  ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    await ApiAuth.checkTokenAndNavigate(context);
    try {
      List<User> users = await _apiService.getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void _editUser(BuildContext context, User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );
    if (result == true) {
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteUser(BuildContext context, User user) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('DELETE'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      try {
        await _apiService.deleteUser(user.id);
        setState(() {
          _users.remove(user);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_users[index].name),
            subtitle: Text(_users[index].email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _editUser(context, _users[index]);
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    _deleteUser(context, _users[index]);
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUserScreen(isLoggedIn: true,),
            ),
          ).then((success) {
            if (success == true) {
              _loadUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
