import 'package:flutter/material.dart';
import 'package:spa_management/models/staff.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class CreateStaffScreen extends StatefulWidget {
  @override
  _CreateStaffScreenState createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  final _staff = Staff(id: 0, name: '', position: '', bio: '', imageUrl: '', email: '', phone: '', address: '', photo: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Staff'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _staff.name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Position',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a position';
                  }
                  return null;
                },
                onSaved: (value) => _staff.position = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Bio',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
                onSaved: (value) => _staff.bio = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) => _staff.email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone',
                ),
                onSaved: (value) => _staff.phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                onSaved: (value) => _staff.address = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Photo URL',
                ),
                onSaved: (value) => _staff.photo = value!,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await ApiAuth.checkTokenAndNavigate(context);
                      await _apiService.createStaff(_staff);
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create staff member'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('CREATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
