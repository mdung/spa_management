import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location.dart';


class MyUtils {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dateTime);
  }

  String formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  int getUnixTimestamp(String date, String time) {
    // Combine date and time strings
    String datetimeString = '$date $time';

    // Parse the combined datetime string using a formatter
    DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(datetimeString);

    // Calculate the Unix timestamp in seconds
    int unixTimestamp = dateTime.millisecondsSinceEpoch ~/ 1000;

    // Return the Unix timestamp
    return unixTimestamp;
  }



  String formatTime(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    var formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  BoxDecoration buildBackgroundImage(List<LocationSpa> locations, int selectedLocationIndex) {
    if (locations.isNotEmpty && locations[selectedLocationIndex].photo != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(locations[selectedLocationIndex].photo!),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/spa_background4.jpg'),
          fit: BoxFit.cover,
        ),
      );
    }
  }



}
