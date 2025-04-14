import 'package:location/location.dart';

import 'base_location_service.dart';

class MobileLocationService implements BaseLocationService {
  final Location _location = Location();
  LocationData? _currentLocation;

  @override
  Future<void> initialize() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permissions are denied');
      }
    }
  }

  @override
  Future<double?> getLatitude() async {
    try {
      _currentLocation = await _location.getLocation();
      return _currentLocation?.latitude;
    } catch (e) {
      print("Mobile location error (latitude): $e");
      return null;
    }
  }

  @override
  Future<double?> getLongitude() async {
    try {
      _currentLocation ??= await _location.getLocation();
      return _currentLocation?.longitude;
    } catch (e) {
      print("Mobile location error (longitude): $e");
      return null;
    }
  }
}
