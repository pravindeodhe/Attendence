import 'package:geolocator/geolocator.dart';

import 'base_location_service.dart';

class WebLocationService implements BaseLocationService {
  @override
  Future<void> initialize() async {
    // Web doesn't need special initialization
  }

  @override
  Future<double?> getLatitude() async {
    try {
      final position = await _getCurrentPosition();
      return position.latitude;
    } catch (e) {
      print("Web location error (latitude): $e");
      return null;
    }
  }

  @override
  Future<double?> getLongitude() async {
    try {
      final position = await _getCurrentPosition();
      return position.longitude;
    } catch (e) {
      print("Web location error (longitude): $e");
      return null;
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled in your browser');
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable them in your browser settings.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 10),
    );
  }
}