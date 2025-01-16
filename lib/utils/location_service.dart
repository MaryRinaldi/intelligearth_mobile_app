import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final Logger _logger = Logger();

  static Future<bool> checkPermissions() async {
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

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await checkPermissions()) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      _logger.e('Errore nel recupero della posizione: $e');
      return null;
    }
  }
} 