import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

class MapService {
  static const int _maxCacheSize = 20;
  final Map<String, _CachedDirections> _directionsCache = {};
  
  Future<Map<String, dynamic>> getDirections(LatLng origin, LatLng destination) async {
    final String cacheKey = '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';
    
    if (_directionsCache.containsKey(cacheKey)) {
      final cached = _directionsCache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp).inMinutes < 30) {
        return cached.data;
      } else {
        _directionsCache.remove(cacheKey);
      }
    }

    if (_directionsCache.length >= _maxCacheSize) {
      final oldestKey = _directionsCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _directionsCache.remove(oldestKey);
    }

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=walking'
        '&key=${AppConfig.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0]['legs'][0];
          final encodedPoints = data['routes'][0]['overview_polyline']['points'] as String;
          
          final points = await compute<String, List<LatLng>>(
            _decodePolyline,
            encodedPoints,
          );
          
          final result = {
            'points': points,
            'distance': route['distance']['text'],
            'duration': route['duration']['text'],
          };
          
          _directionsCache[cacheKey] = _CachedDirections(
            data: result,
            timestamp: DateTime.now(),
          );
          
          return result;
        }
      }
      throw Exception('Failed to get directions');
    } catch (e) {
      throw Exception('Error getting directions: $e');
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void clearCache() {
    _directionsCache.clear();
  }
}

class _CachedDirections {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CachedDirections({
    required this.data,
    required this.timestamp,
  });
}
