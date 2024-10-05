import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> monitorSafeZone(Position homePosition, double radius) async {
    Position userPosition = await getCurrentLocation();
    double distance = Geolocator.distanceBetween(homePosition.latitude,
        homePosition.longitude, userPosition.latitude, userPosition.longitude);
    if (distance > radius) {
      // Notify caregiver or user
      print('User has left the safe zone');
    }
  }
}
