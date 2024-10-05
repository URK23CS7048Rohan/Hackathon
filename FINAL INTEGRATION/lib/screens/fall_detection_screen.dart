import 'package:flutter/material.dart';
import 'package:alzheimers_memory_aid/services/fall_detection_service.dart';

class FallDetectionScreen extends StatefulWidget {
  @override
  _FallDetectionScreenState createState() => _FallDetectionScreenState();
}

class _FallDetectionScreenState extends State<FallDetectionScreen> {
  FallDetectionService _fallDetectionService = FallDetectionService();
  bool fallDetected = false;

  @override
  void initState() {
    super.initState();
    _fallDetectionService.startMonitoring(() {
      setState(() {
        fallDetected = true;
      });
      // Additional action: Notify caregiver or send an alert
      // Example: Send notification to family/caregiver
    });
  }

  @override
  void dispose() {
    _fallDetectionService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fall Detection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(fallDetected ? "Fall Detected!" : "Monitoring for Falls...",
                style: TextStyle(fontSize: 24)),
            if (fallDetected)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    fallDetected = false; // Reset after detection
                  });
                },
                child: Text("Reset Detection"),
              ),
          ],
        ),
      ),
    );
  }
}
