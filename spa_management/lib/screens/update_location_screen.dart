import 'package:flutter/material.dart';
import 'package:spa_management/models/location.dart';
import 'package:spa_management/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_auth.dart';

class EditLocationScreen extends StatefulWidget {
  final LocationSpa location;

  EditLocationScreen({required this.location});

  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _photoController; // Add this line
  String? _photoUrl; // Add this line
  bool _photoChanged = false; // Add this line

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location.name);
    _addressController = TextEditingController(text: widget.location.address);
    _cityController = TextEditingController(text: widget.location.city);
    _stateController = TextEditingController(text: widget.location.state);
    _zipController = TextEditingController(text: widget.location.zip);
    _photoController = TextEditingController(text: widget.location.photo); // Add this line
    _photoUrl = widget.location.photo; // Add this line
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _photoController.dispose(); // Add this line
    super.dispose();
  }

  void _updateLocation() async {
    await ApiAuth.checkTokenAndNavigate(context);
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        String? photoUrl;
        if (_photoChanged) {
          photoUrl = await _apiService.uploadLocationPhoto(_photoController.text);
        } else {
          photoUrl = _photoUrl;
        }
        await _apiService.updateLocation(widget.location.id,
          _nameController.text,
          _addressController.text,
          _cityController.text,
          _stateController.text,
          _zipController.text,
          photoUrl,
        );
        setState(() {
          _loading = false;
        });
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectPhoto() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoController.text = pickedFile.path;
        _photoChanged = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Location'),
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'City',
                ),
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'State',
                ),
                controller: _stateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'ZIP',
                ),
                controller: _zipController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Photo',
                ),
                controller: _photoController,
                enabled: false,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose Photo', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: _selectPhoto,
                    child: Text('Select', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateLocation,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
