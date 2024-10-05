import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class FallDetectionService {
  StreamSubscription? _accelerometerSubscription;
  final double threshold = 20.0; // Adjust based on experimentation

  void startMonitoring(Function onFallDetected) {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration =
          event.x * event.x + event.y * event.y + event.z * event.z;

      if (acceleration > threshold) {
        onFallDetected();
      }
    });
  }

  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
  }
}
