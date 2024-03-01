import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import '../models/staff_performance.dart';
import '../services/api_auth.dart';
import '../services/api_service.dart';

class StaffPerformanceScreen extends StatefulWidget {
  @override
  _StaffPerformanceScreenState createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  ApiService _apiService = ApiService();
  List<StaffPerformance> _staffPerformanceList = [];
  final _formKey = GlobalKey<FormState>();
  final _staffIdController = TextEditingController();
  final _metricNameController = TextEditingController();
  final _metricValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStaffPerformance();
  }

  void _fetchStaffPerformance() async {
    await ApiAuth.checkTokenAndNavigate(context);
    List<StaffPerformance> staffPerformanceList = await _apiService.getStaffPerformance();
    setState(() {
      _staffPerformanceList = staffPerformanceList;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      StaffPerformance newStaffPerformance = StaffPerformance(
        id: 0, // ID will be assigned by the server
        staffId: int.parse(_staffIdController.text),
        metricName: _metricNameController.text,
        metricValue: int.parse(_metricValueController.text),
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );
      await _apiService.createStaffPerformance(newStaffPerformance);
      _fetchStaffPerformance();
      _staffIdController.clear();
      _metricNameController.clear();
      _metricValueController.clear();
    }
  }

  List<charts.Series<StaffPerformance, String>> _createSeries() {
    return [
      charts.Series<StaffPerformance, String>(
        id: 'Staff Performance Metrics',
        data: _staffPerformanceList,
        domainFn: (StaffPerformance staffPerformance, _) =>
        staffPerformance.metricName,
        measureFn: (StaffPerformance staffPerformance, _) =>
        staffPerformance.metricValue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Performance'),
      ),
      body: Column(
        children: [
          Expanded(
            child: charts.BarChart(
              _createSeries(),
              animate: true,
              animationDuration: Duration(milliseconds: 500),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _staffIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Staff ID',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a staff ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _metricNameController,
                    decoration: InputDecoration(
                      labelText: 'Metric Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a metric name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _metricValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Metric Value',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a metric value';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Add Staff Performance Metric'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
