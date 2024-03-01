import 'package:flutter/material.dart';
import 'package:spa_management/models/location.dart';
import 'package:spa_management/screens/create_location_screen.dart';
import 'package:spa_management/screens/update_location_screen.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class LocationListScreen extends StatefulWidget {
  @override
  _LocationListScreenState createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  List<LocationSpa> _locations = [];
  bool _loading = true;
  ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() async {
    await ApiAuth.checkTokenAndNavigate(context);
    try {
      List<LocationSpa> locations = (await _apiService.getLocations()).cast<LocationSpa>();
      setState(() {
        _locations = locations;
        _loading = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  void _editLocation(BuildContext context, LocationSpa location) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLocationScreen(location: location),
      ),
    );
    if (result == true) {
      _loadLocations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteLocation(BuildContext context, LocationSpa location) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Location'),
          content: Text('Are you sure you want to delete this location?'),
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
        await _apiService.deleteLocation(location.id);
        setState(() {
          _locations.remove(location);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete location'),
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
          title: Text('Location List'),
        ),
        body: _loading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: _locations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_locations[index].name),
              subtitle: Text(_locations[index].address),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _editLocation(context, _locations[index]);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteLocation(context, _locations[index]);
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
          builder: (context) => CreateLocationScreen(),
          ),
        ).then((success) {
          if (success == true) {
            _loadLocations();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location created successfully'),
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


