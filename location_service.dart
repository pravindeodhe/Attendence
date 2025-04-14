import 'package:flutter/foundation.dart' show kIsWeb;
import 'base_location_service.dart';
import 'mobile_location_service.dart';
import 'web_location_service.dart';

class LocationService {
  final BaseLocationService _implementation;

  LocationService() : _implementation = kIsWeb ? WebLocationService() : MobileLocationService();

  Future<void> initialize() async {
    try {
      await _implementation.initialize();
    } catch (e) {
      print('LocationService initialization error: $e');
      rethrow;
    }
  }

  Future<double?> getLatitude() async {
    try {
      final lat = await _implementation.getLatitude();
      if (lat == null) {
        print('Warning: getLatitude() returned null');
      }
      return lat;
    } catch (e) {
      print('Error in getLatitude(): $e');
      rethrow;
    }
  }

  Future<double?> getLongitude() async {
    try {
      final long = await _implementation.getLongitude();
      if (long == null) {
        print('Warning: getLongitude() returned null');
      }
      return long;
    } catch (e) {
      print('Error in getLongitude(): $e');
      rethrow;
    }
  }
}