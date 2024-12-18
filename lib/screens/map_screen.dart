import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_view_page.dart';
import 'quest_page.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.questTitle,
  });

  final double latitude;
  final double longitude;
  final String questTitle;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String currentLayer = 'OpenStreetMap DE';

  final Map<String, TileLayer> mapLayers = {
    'OpenStreetMap DE': TileLayer(
      urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
    ),
    'Esri Satellite': TileLayer(
      urlTemplate:
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      userAgentPackageName: 'com.example.app',
    ),
  };

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (!context.mounted) return;

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraViewPage(imagePath: pickedFile.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna immagine selezionata.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuestPage()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/icons/quest.png',
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Go back to other quests',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 13.0,
            ),
            children: [
              mapLayers[currentLayer]!,
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 80,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: mapLayers.keys.map((String layer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentLayer == layer ? Colors.blue : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        setState(() {
                          currentLayer = layer;
                        });
                      },
                      child: Text(
                        layer,
                        style: TextStyle(
                          color: currentLayer == layer
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => _openCamera(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/camera.png',
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
