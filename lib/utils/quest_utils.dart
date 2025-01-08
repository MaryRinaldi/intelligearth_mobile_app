import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class QuestUtils {
  // Geofencing
  static bool isInQuestArea(
      LatLng userLocation, LatLng questLocation, double radiusInMeters) {
    return calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          questLocation.latitude,
          questLocation.longitude,
        ) <=
        radiusInMeters;
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Custom Info Window Widget
  static Widget buildCustomInfoWindow({
    required String title,
    required String description,
    required String distance,
    required VoidCallback onDirectionsPressed,
    required VoidCallback onStartQuestPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 106),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Distance: $distance',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onDirectionsPressed,
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onStartQuestPressed,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Geofence Circle
  static Circle createQuestGeofence({
    required String questId,
    required LatLng center,
    required double radiusInMeters,
    required bool isActive,
  }) {
    return Circle(
      circleId: CircleId('geofence_$questId'),
      center: center,
      radius: radiusInMeters,
      fillColor: isActive
          ? Colors.green.withValues(alpha: 106)
          : Colors.red.withValues(alpha: 106),
      strokeColor: isActive ? Colors.green : Colors.red,
      strokeWidth: 2,
    );
  }

  // Distance formatting
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }
}
