import 'package:flutter/material.dart';
import 'package:spa_management/models/staff.dart';
import 'package:spa_management/services/api_service.dart';

class UpdateStaffScreen extends StatefulWidget {
  final Staff staff;
  UpdateStaffScreen({required this.staff});

  @override
  _UpdateStaffScreenState createState() => _UpdateStaffScreenState();
}

class _UpdateStaffScreenState extends State<UpdateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _bioController;
  late TextEditingController _imageUrlController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.name);
    _emailController = TextEditingController(text: widget.staff.email);
    _phoneController = TextEditingController(text: widget.staff.phone);
    _positionController = TextEditingController(text: widget.staff.position);
    _bioController = TextEditingController(text: widget.staff.bio);
    _imageUrlController = TextEditingController(text: widget.staff.imageUrl);
    _addressController = TextEditingController(text: widget.staff.address);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Staff'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _positionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _imageUrlController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      Staff staff = Staff(
                        id: widget.staff.id,
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text, position: '', bio: '', imageUrl: '', photo: '', address: '',
                      );
                      await _apiService.updateStaff(staff);
                      Navigator.pop(context, true);
                    } catch (e) {
                      print('Error updating staff: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update staff'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('Update Staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
