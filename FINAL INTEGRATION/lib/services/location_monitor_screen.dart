import 'package:flutter/material.dart';
import 'package:alzheimers_memory_aid/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMonitorScreen extends StatefulWidget {
  @override
  _LocationMonitorScreenState createState() => _LocationMonitorScreenState();
}

void _navigateHome() async {
  const url =
      'https://www.google.com/maps/dir/?api=1&destination=37.7749,-122.4194'; // Replace with actual home coordinates
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _LocationMonitorScreenState extends State<LocationMonitorScreen> {
  LocationService _locationService = LocationService();
  bool outsideSafeZone = false;

  void _checkSafeZone() async {
    bool isOutside = await _locationService.isUserOutsideSafeZone();
    setState(() {
      outsideSafeZone = isOutside;
    });

    if (isOutside) {
      // Trigger navigation or send alert to caregivers
      // Example: "You've walked outside of your usual area, should I help you return?"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Safe Zone")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(outsideSafeZone ? "Outside Safe Zone!" : "Inside Safe Zone",
                style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: _checkSafeZone,
              child: Text("Check Location"),
            ),
          ],
        ),
      ),
    );
  }
}
