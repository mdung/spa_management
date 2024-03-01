import 'package:flutter/material.dart';
import 'package:spa_management/models/location.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class CreateLocationScreen extends StatefulWidget {
  @override
  _CreateLocationScreenState createState() => _CreateLocationScreenState();
}

class _CreateLocationScreenState extends State<CreateLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _loading = false;
  final _location = LocationSpa(id: 0, name: '', address: '', city: '', state: '', zip: '', latitude: 0, longitude: 0);

  String? _name;
  String? _address;
  String? _state;
  String? _city;
  String? _zip;

  void _submit() async {
    print('_name: $_name');
    print('_address: $_address');
    print('_city: $_city');
    print('_state: $_state');
    print('_zip: $_zip');
    if (_formKey.currentState == null) {
      print('_formKey.currentState is null');
    }
    if (_name == null) {
      print('_name is null');
    }
    if (_address == null) {
      print('_address is null');
    }
    if (_city == null) {
      print('_city is null');
    }
    if (_state == null) {
      print('_state is null');
    }
    if (_zip == null) {
      print('_zip is null');
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        await ApiAuth.checkTokenAndNavigate(context);
        final location = await _apiService.createLocation(
          name: _name!,
          address: _address!,
          city: _city!,
          state: _state!,
          zip: _zip!,
        );
        setState(() {
          _loading = false;
        });
        Navigator.pop(context, true);
      } catch (e) {
        print('Error creating location: $e');
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create location'),
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
        title: Text('Create Location'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
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
                onSaved: (value) => _location.name = value!,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => _location.address = value!,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'City',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
                onSaved: (value) => _location.city = value!,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'State',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a state';
                  }
                  return null;
                },
                onSaved: (value) => _location.state = value!,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Zip',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a zip code';
                  }
                  return null;
                },
                onSaved: (value) => _location.zip = value!,
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text('CREATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
