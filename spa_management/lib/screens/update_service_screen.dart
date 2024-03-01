import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/services/api_service.dart';
import '../models/service_category.dart';
import 'package:spa_management/models/service_category.dart';


class UpdateServiceScreen extends StatefulWidget {
  final Service service;

  UpdateServiceScreen({required this.service});

  @override
  _UpdateServiceScreenState createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String? _serviceName;
  late ServiceCategory _selectedCategory;
  late String _name;
  late String _description;
  late String _duration;
  late String _benefit;
  late double _price;
  late String _staffMembers;
  late String _imageUrl;
  late int _categoryId;

  @override
  void initState() {
    super.initState();
    _name = widget.service.name;
    _description = widget.service.description;
    _duration = widget.service.duration;
    _benefit = widget.service.benefit;
    _price = widget.service.price;
    _staffMembers = widget.service.staffMembers;
    _imageUrl = widget.service.imageUrl;
    _categoryId = widget.service.categoryId;

    // Fetch the ServiceCategory object for the given categoryId
    _apiService.getServiceCategory(_categoryId).then((category) {
      setState(() {
        _selectedCategory = category;
      });
    });
  }



  Widget _buildCategoryDropdown() {
    return FutureBuilder(
      future: _apiService.getServiceCategories(),
      builder: (BuildContext context, AsyncSnapshot<List<ServiceCategory>> snapshot) {
        if (snapshot.hasData) {
          final categories = snapshot.data!;
          // Check if there's a category in the list with the same ID as the current category
          final hasSelectedCategory = categories.any((category) => category.id == _categoryId);
          // If the selected category is not in the list, add it to the list
          if (!hasSelectedCategory && _selectedCategory.id != -1) {
            categories.add(_selectedCategory);
          }
          return DropdownButtonFormField<ServiceCategory>(
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            value: hasSelectedCategory ? categories.firstWhere((category) => category.id == _categoryId) : _selectedCategory,
            onChanged: (category) {
              setState(() {
                _selectedCategory = category!;

              });
            },
            decoration: InputDecoration(
              labelText: 'Category',
            ),
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Service'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.service.name,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _serviceName = value;
                },
              ),
              TextFormField(
                initialValue: widget.service.description,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                initialValue: widget.service.price.toString(),
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: widget.service.duration,
                decoration: InputDecoration(
                  labelText: 'Duration',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  return null;
                },
                onSaved: (value) {
                  _duration = value!;
                },
              ),
              TextFormField(
                initialValue: widget.service.benefit,
                decoration: InputDecoration(
                  labelText: 'Benefit',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter benefit';
                  }
                  return null;
                },
                onSaved: (value) {
                  _benefit = value!;
                },
              ),
              _buildCategoryDropdown(),
              TextFormField(
                initialValue: widget.service.staffMembers,
                decoration: InputDecoration(
                  labelText: 'Staff Members',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter staff members';
                  }
                  return null;
                },
                onSaved: (value) {
                  _staffMembers = value!;
                },
              ),
              TextFormField(
                initialValue: widget.service.imageUrl,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
                onSaved: (value) {
                  _imageUrl = value!;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text('Update'),
                onPressed: () {
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                    _formKey.currentState?.save();
                    _apiService.updateService(
                      widget.service.id,
                      _serviceName,
                      _description,
                      _price,
                      _duration,
                      _benefit,
                      _selectedCategory.id,
                      _staffMembers,
                      _imageUrl
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}