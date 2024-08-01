import 'package:flutter/material.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/screens/service_detail_screen.dart';
import 'package:spa_management/screens/update_service_screen.dart';
import 'package:spa_management/services/api_service.dart';

class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late List<Service> _services = [];
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _getServices();
  }

  void _getServices() async {
    print("Getting services...");
    final services = await _apiService.getServices();
    setState(() {
      _services = services;
      print("Services updated: $_services");
    });
  }




  void _navigateToAddServiceScreen(BuildContext context) async {
    final newService = Service(
      id: 0,
      name: '',
      description: '',
      price: 0.0,
      duration: '',
      benefit: '',
      categoryId: 0,
      loyalty_points: 0,
      staffMembers: '',
      imageUrl: '',
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateServiceScreen(service: newService)),
    );
    if (result == true) {
      _getServices();
    }
  }


  void _navigateToUpdateServiceScreen(BuildContext context, Service service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateServiceScreen(service: service)),
    );
    if (result == true) {
      _getServices();
    }
  }

  void _deleteService(BuildContext context, int serviceId) async {
    print("Deleting service with ID $serviceId");
    try {
      final success = await _apiService.deleteService(serviceId);
      if (success) {
        await _apiService.deleteService(serviceId);
        print("Service deleted from database");
        _getServices();
        print("Services list updated: $_services");
      } else {
        print("Error deleting service: server returned an error");
      }
    } catch (error) {
      print("Error deleting service: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: _services == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return ListTile(
            title: Text(service.name),
            subtitle: Text('Price: \$${service.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _navigateToUpdateServiceScreen(context, service),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteService(context, service.id),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: service)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToAddServiceScreen(context),
      ),
    );
  }
}



