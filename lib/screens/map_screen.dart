import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mappa")),
      body: Center(
        child: Text("Latitudine: $latitude, Longitudine: $longitude"),
      ),
    );
  }
}
