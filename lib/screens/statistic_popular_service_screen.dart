import 'dart:io';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

class PopularServicesScreen extends StatefulWidget {
  PopularServicesScreen({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  final String? startDate;
  final String? endDate;


  @override
  _PopularServicesScreenState createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  late Future<List<Map<String, dynamic>>> _popularServicesFuture;
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
    _popularServicesFuture =
        _apiService.getMostPopularServices(startDate, endDate);
    _startDateController.text = startDate;
    _endDateController.text = endDate;
  }

  Future<void> _generateReportPDF() async {
    final pdf = pdfWidgets.Document();
    final data = await _popularServicesFuture;
    final format = PdfPageFormat.a4;
    pdf.addPage(
      pdfWidgets.MultiPage(
        pageFormat: format,
        margin: pdfWidgets.EdgeInsets.all(32),
        build: (context) => [
          pdfWidgets.Header(level: 0, child: pdfWidgets.Text('Popular Services Report')),
          pdfWidgets.Header(level: 1, child: pdfWidgets.Text('Date Range: ${_startDateController.text} - ${_endDateController.text}')),
          pdfWidgets.SizedBox(height: 16),
          pdfWidgets.Table.fromTextArray(
            headers: ['Service Name', 'Bookings'],
            data: data.map((e) => [e['service_name'], e['count']]).toList(),
          ),
        ],
      ),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/popular_services_report.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report generated and saved as PDF')),
    );
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
          _popularServicesFuture = _apiService.getMostPopularServices(startDateController.text, endDateController.text);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Services'),
        actions: [
          IconButton(
            onPressed: _generateReportPDF,
            icon: Icon(Icons.picture_as_pdf),
          ),
        ],
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
                  'Most popular services:',
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
              future: _popularServicesFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final data = snapshot.data!;
                    final series = [
                      charts.Series<Map<String, dynamic>, String>(
                        id: 'Services',
                        domainFn: (service, _) {
                          final name = (service['service_name'] as String);
                          final words = name.split(' ');
                          if (words.length >= 2) {
                            return '${words[0]} ${words[1]}';
                          } else {
                            return name;
                          }
                        },
                        measureFn: (service, _) => service['count'] as int,
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
                                final service = data[index];
                                return ServiceCard(
                                  name: service['service_name'],
                                  count: service['count'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('No popular services found.');
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

class ServiceCard extends StatelessWidget {
  final String? name;
  final int count;

  ServiceCard({
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
