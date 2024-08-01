import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/location.dart';

class MapScreen extends StatelessWidget {
  final LocationSpa location;

  const MapScreen({Key? key, required this.location}) : super(key: key);

  void _launchMapsUrl() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _launchMapsUrl,
              child: Image.network(
                'https://maps.googleapis.com/maps/api/staticmap?center=${location.latitude},${location.longitude}&zoom=16&size=640x400&markers=color:red%7C${location.latitude},${location.longitude}&key=AIzaSyD9WqLH15kYkvNXqsyA2Aw5HNauJXBpiSs',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(location.id.toString()),
                  position: LatLng(location.latitude, location.longitude),
                  infoWindow: InfoWindow(
                    title: location.name,
                    snippet: location.address,
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
