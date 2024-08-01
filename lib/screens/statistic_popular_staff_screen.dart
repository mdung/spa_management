import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../services/api_service.dart';

class PopularStaffScreen extends StatefulWidget {
  PopularStaffScreen({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  final String? startDate;
  final String? endDate;

  @override
  _PopularStaffScreenState createState() => _PopularStaffScreenState();
}

class _PopularStaffScreenState extends State<PopularStaffScreen> {
  late Future<List<Map<String, dynamic>>> _popularStaffFuture;
  final _apiService = ApiService();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    final startDate = currentDate.subtract(Duration(days: 30)).toString();
    final endDate = currentDate.toString();
    _popularStaffFuture =
        _apiService.getMostPopularStaff(startDate, endDate);
    _startDateController.text = startDate;
    _endDateController.text = endDate;
  }

 @override
  Widget build(BuildContext context) {
    final startDateController = TextEditingController(text: widget.startDate);
    final endDateController = TextEditingController(text: widget.endDate);

    Future<void> _selectDateRange() async {
      final initialStartDate = widget.startDate?.isNotEmpty == true
          ? DateTime.parse(widget.startDate!)
          : DateTime.now().subtract(Duration(days: 30));
      final initialEndDate = widget.endDate?.isNotEmpty == true
          ? DateTime.parse(widget.endDate!)
          : DateTime.now();


      final dateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2022),
        lastDate: DateTime(2024),
        initialDateRange: DateTimeRange(start: initialStartDate, end: initialEndDate),
      );

      if (dateRange != null) {
        startDateController.text = dateRange.start.toString().substring(0, 10);
        endDateController.text = dateRange.end.toString().substring(0, 10);

        setState(() {
          _popularStaffFuture = _apiService.getMostPopularStaff(startDateController.text, endDateController.text);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Staff'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Most popular staff:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDateRange,
                  child: Text('Select Date Range'),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _popularStaffFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final data = snapshot.data!;
                    final series = [
                      charts.Series<Map<String, dynamic>, String>(
                        id: 'Staff',
                        domainFn: (staff, _) => staff['staff_name'] as String,
                        measureFn: (staff, _) => staff['count'] as int,
                        data: data,
                      )
                    ];
                    return Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: charts.BarChart(
                              series,
                              animate: true,
                              barGroupingType: charts.BarGroupingType.grouped,
                              behaviors: [charts.SeriesLegend()],
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final staff = data[index];
                                return StaffCard(
                                  name: staff['staff_name'],
                                  count: staff['count'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('No popular staff found.');
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final String? name;
  final int count;

  StaffCard({
    this.name = 'Unknown',
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name ?? ''),
        subtitle: Text('$count bookings'),
      ),
    );
  }
}