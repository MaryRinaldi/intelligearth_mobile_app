import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('Warning: Google Maps API key is not set in .env file');
      // Return the hardcoded key as fallback
      return 'AIzaSyBrFCXdN23NOlq6qD9U5smpWjk8H9sVFfs';
    }
    return key;
  }

  // Prevent instantiation and extension
  AppConfig._();

  static bool get isProduction => kReleaseMode;

  static String get mapsApiKey => googleMapsApiKey;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: Could not load .env file: $e');
      // Continue without .env file, will use fallback values
    }
  }
}