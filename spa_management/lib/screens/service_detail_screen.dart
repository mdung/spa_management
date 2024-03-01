import 'package:flutter/material.dart';
import 'package:spa_management/models/service.dart';
import 'package:spa_management/services/api_service.dart';
import 'package:spa_management/widgets/dialogs.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  ServiceDetailScreen({required this.service});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    var name;
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Detail'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.network(
                widget.service.imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.service.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.service.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Duration: ${widget.service.duration}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Price: ${widget.service.price}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Benefit: ${widget.service.benefit}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Category: ${widget.service.categoryId}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Staff Members: ${widget.service.staffMembers}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Dialogs.showConfirmationDialog(
                      context,
                      'Delete Service',
                      'Are you sure you want to delete this service?',
                          () async {
                        bool result = await _apiService.deleteService(widget.service.id);
                        if (result) {
                          Navigator.pop(context, true);
                        }
                      },
                    );
                  },
                )


                ,
                ElevatedButton(
                  child: Text('Edit'),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/update_service',
                      arguments: widget.service,
                    );
                    if (result == true) {
                      setState(() {
                        // Refresh the service data
                        widget.service.reload();
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
