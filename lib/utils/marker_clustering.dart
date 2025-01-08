import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

class MarkerClusterer {
  static const double clusterRadius = 80.0; // pixels

  static Future<Set<Marker>> clusterMarkers({
    required Set<Marker> markers,
    required double zoom,
    required Size screenSize,
    required GoogleMapController mapController,
  }) async {
    if (markers.isEmpty) return {};

    final Set<Marker> clusteredMarkers = {};
    final List<Marker> unclusteredMarkers = markers.toList();

    while (unclusteredMarkers.isNotEmpty) {
      final Marker baseMarker = unclusteredMarkers.removeAt(0);
      List<Marker> cluster = [baseMarker];

      final LatLng baseLatLng = baseMarker.position;
      final ScreenCoordinate basePoint =
          await mapController.getScreenCoordinate(baseLatLng);

      // Pre-calculate all screen coordinates
      List<ScreenCoordinate> points = await Future.wait(unclusteredMarkers
          .map((m) => mapController.getScreenCoordinate(m.position)));

      // Create list of markers to remove
      List<int> indexesToRemove = [];
      for (int i = 0; i < unclusteredMarkers.length; i++) {
        double distance = _getDistance(basePoint, points[i]);
        if (distance <= clusterRadius) {
          cluster.add(unclusteredMarkers[i]);
          indexesToRemove.add(i);
        }
      }

      // Remove markers from highest index to lowest to avoid shifting issues
      for (int i = indexesToRemove.length - 1; i >= 0; i--) {
        unclusteredMarkers.removeAt(indexesToRemove[i]);
      }

      if (cluster.length == 1) {
        clusteredMarkers.add(baseMarker);
      } else {
        Marker clusterMarker = await _createClusterMarker(cluster);
        clusteredMarkers.add(clusterMarker);
      }
    }

    return clusteredMarkers;
  }

  static double _getDistance(ScreenCoordinate point1, ScreenCoordinate point2) {
    return sqrt(
      pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2),
    );
  }

  static Future<Marker> _createClusterMarker(List<Marker> markers) async {
    final double avgLat =
        markers.map((m) => m.position.latitude).reduce((a, b) => a + b) /
            markers.length;
    final double avgLng =
        markers.map((m) => m.position.longitude).reduce((a, b) => a + b) /
            markers.length;

    // Create cluster icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(60, 60);
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 30, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: markers.length.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return Marker(
      markerId: MarkerId('cluster_${avgLat}_$avgLng'),
      position: LatLng(avgLat, avgLng),
      icon: BitmapDescriptor.bytes(bytes!.buffer.asUint8List()),
      infoWindow: InfoWindow(
        title: '${markers.length} locations',
        snippet: 'Tap to expand',
      ),
    );
  }
}
