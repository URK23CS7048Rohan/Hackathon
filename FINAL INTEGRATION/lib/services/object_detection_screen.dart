import 'package:flutter/material.dart';
import 'package:alzheimers_memory_aid/services/object_recognition_service.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  List<String> detectedObjects = [];

  void _detectObjects() async {
    ObjectRecognitionService objectRecognitionService =
        ObjectRecognitionService();
    List<String> objects = await objectRecognitionService.detectObjects();
    setState(() {
      detectedObjects = objects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Object Detection")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _detectObjects,
              child: Text("Detect Objects"),
            ),
            SizedBox(height: 20),
            Text("Detected Objects:", style: TextStyle(fontSize: 18)),
            ...detectedObjects
                .map((obj) => Text(obj, style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
