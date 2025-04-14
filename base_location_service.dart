abstract class BaseLocationService {
  Future<void> initialize();
  Future<double?> getLatitude();
  Future<double?> getLongitude();
}