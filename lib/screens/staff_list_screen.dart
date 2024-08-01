import 'package:flutter/material.dart';
import 'package:spa_management/models/staff.dart';
import 'package:spa_management/screens/create_staff_screen.dart';
import 'package:spa_management/screens/update_staff_screen.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';
class StaffListScreen extends StatefulWidget {
  @override
  _StaffListScreenState createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<Staff> _staff = [];
  bool _loading = true;
  ApiService _apiService = ApiService();

  String _token = ''; // Add token variable

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  void _loadStaff() async {
    await ApiAuth.checkTokenAndNavigate(context);
    try {
      _token = (await _apiService.getToken())!;
      print('Token: $_token');
      List<Staff> staff = (await _apiService.getStaff()).cast<Staff>();
      setState(() {
        _staff = staff;
        _loading = false;
      });
    } catch (e) {
      print('Error loading staff: $e');
    }
  }


  void _editStaff(BuildContext context, Staff staff) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStaffScreen(staff: staff),
      ),
    );
    if (result == true) {
      _loadStaff();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Staff updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteStaff(BuildContext context, Staff staff) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Staff'),
          content: Text('Are you sure you want to delete this staff?'),
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
        if (staff.id != null) {
          await _apiService.deleteStaff(staff.id);
        }
        setState(() {
          _staff.remove(staff);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Staff deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting staff: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete staff'),
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
          title: Text('Staff List'),
        ),
        body: _loading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: _staff.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_staff[index].name),
              subtitle: Text(_staff[index].position ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _editStaff(context, _staff[index]);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteStaff(context, _staff[index]);
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
                builder: (context) => CreateStaffScreen(),
              ),
            ).then((success) {
              if (success == true) {
                _loadStaff();
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
