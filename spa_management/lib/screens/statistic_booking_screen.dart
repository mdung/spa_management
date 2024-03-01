import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:io';
import '../services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
class BookingStatisticsScreen extends StatefulWidget {
  final int userId;
  final String startDate;
  final String endDate;

  BookingStatisticsScreen({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  _BookingStatisticsScreenState createState() => _BookingStatisticsScreenState();
}

class _BookingStatisticsScreenState extends State<BookingStatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _bookingStatsFuture;
  List<charts.Series<Map<String, dynamic>, String>>? _chartData;
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
    _bookingStatsFuture = _apiService.getBookingStatistics(widget.userId, startDate, endDate);
    _startDateController.text = startDate;
    _endDateController.text = endDate;
  }

  @override
  Widget build(BuildContext context) {
    final startDateController = TextEditingController(text: widget.startDate);
    final endDateController = TextEditingController(text: widget.endDate);

    Future<void> _selectDateRange() async {
      final initialStartDate = widget.startDate.isNotEmpty ? DateTime.parse(widget.startDate) : DateTime.now().subtract(Duration(days: 30));
      final initialEndDate = widget.endDate.isNotEmpty ? DateTime.parse(widget.endDate) : DateTime.now();

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
          _bookingStatsFuture = _apiService.getBookingStatistics(widget.userId, startDateController.text, endDateController.text);
        });
      }
    }

    Future<void> _generateReportPDF() async {
      final pdf = pdfWidgets.Document();
      final data = await _bookingStatsFuture;
      final format = PdfPageFormat.a4;
      pdf.addPage(
        pdfWidgets.MultiPage(
          pageFormat: format,
          margin: pdfWidgets.EdgeInsets.all(32),
          build: (context) => [
            pdfWidgets.Header(level: 0, child: pdfWidgets.Text('Booking Statistics Report')),
            pdfWidgets.Header(level: 1, child: pdfWidgets.Text('Date Range: ${_startDateController.text} - ${_endDateController.text}')),
            pdfWidgets.SizedBox(height: 16),
            pdfWidgets.Table.fromTextArray(
              headers: ['Date', 'Bookings'],
              data: data.map((e) => [e['date'], e['count']]).toList(),
            ),
          ],
        ),
      );
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/booking_statistics_report.pdf');
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report generated and saved as PDF')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Statistics'),
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
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDateRange(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDateRange(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _bookingStatsFuture,
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    _chartData = [
                      charts.Series<Map<String, dynamic>, String>(
                        id: 'Bookings',
                        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                        domainFn: (booking, _) => booking['date'],
                        measureFn: (booking, _) => booking['count'],
                        data: snapshot.data!,
                      )
                    ];
                    return Expanded(
                      child: charts.BarChart(
                        _chartData!,
                        animate: true,
                        animationDuration: Duration(milliseconds: 500),
                        domainAxis: charts.OrdinalAxisSpec(
                          renderSpec: charts.SmallTickRendererSpec(
                            labelRotation: 45,
                            labelAnchor: charts.TickLabelAnchor.centered,
                            labelJustification: charts.TickLabelJustification.outside,
                          ),
                        ),
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          renderSpec: charts.GridlineRendererSpec(
                            lineStyle: charts.LineStyleSpec(
                              dashPattern: [4, 4],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Text('No booking data available.');
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

}
