import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  bool _isInitialized = false;

  Future<bool> initializeLocationService() async {
    if (_isInitialized) return true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    if (!_isInitialized) {
      final initialized = await initializeLocationService();
      if (!initialized) return null;
    }
    
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
} 