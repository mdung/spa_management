import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spa_management/models/user_category.dart';
import 'package:spa_management/services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  final bool isLoggedIn;

  const CreateUserScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserCategory? _selectedUserCategory; // Use the imported UserCategory class here
  List<UserCategory> _userCategories = [];

  @override
  void initState() {
    super.initState();
    _getUserCategories();
  }

  void _getUserCategories() async {
    try {
      List<UserCategory> userCategories = await _apiService.getUserCategories();
      setState(() {
        _userCategories = userCategories;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void _createUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'user_category_id': _selectedUserCategory?.id?.toString() ?? '2', // provide a default value of '1' if _selectedUserCategory is null
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user'),
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
        title: Text('Create User'),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    widget.isLoggedIn
                        ? DropdownButtonFormField<UserCategory>(
                      value: _selectedUserCategory ?? _userCategories.first,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserCategory = value;
                        });
                      },
                      items: _userCategories
                          .map(
                            (category) => DropdownMenuItem<UserCategory>(
                          value: category,
                          child: Text(category.name),
                        ),
                      )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'User Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                    )
                        : SizedBox.shrink(),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _createUser();
                        }
                      },
                      child: Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}


