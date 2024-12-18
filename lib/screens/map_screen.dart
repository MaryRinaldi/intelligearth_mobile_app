import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
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

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  bool _isPanelExpanded = false;
  final MapController _mapController = MapController();
  String currentLayer = 'OpenStreetMap DE';

  final Map<String, TileLayer> mapLayers = {
    'OpenStreetMap DE': TileLayer(
      urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
      tileBuilder: (context, child, tile) => child,
    ),
    'Esri Satellite': TileLayer(
      urlTemplate:
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      userAgentPackageName: 'com.example.app',
      tileBuilder: (context, child, tile) => child,
    ),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _togglePanel() {
    if (_isPanelExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildLayerSelector(),
          _buildBottomPanel(),
          _buildCameraButton(),
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.latitude, widget.longitude),
        initialZoom: 13.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        mapLayers[currentLayer]!,
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(widget.latitude, widget.longitude),
              width: 40,
              height: 40,
              child: _buildCustomMarker(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomMarker() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      child: const Icon(
        Icons.location_on,
        color: AppTheme.lightColor,
        size: 24,
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
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
            Expanded(
              child: Text(
                'Go back to other quests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerSelector() {
    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: AppTheme.lightColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: mapLayers.keys.map((String layer) {
            final isSelected = currentLayer == layer;
            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? AppTheme.primaryColor : AppTheme.lightColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  elevation: isSelected ? 0 : 2,
                ),
                onPressed: () {
                  setState(() {
                    currentLayer = layer;
                  });
                },
                child: Text(
                  layer,
                  style: TextStyle(
                    color:
                        isSelected ? AppTheme.lightColor : AppTheme.darkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -20 && !_isPanelExpanded) {
                _togglePanel();
              } else if (details.primaryDelta! > 20 && _isPanelExpanded) {
                _togglePanel();
              }
            },
            child: Container(
              height: 300 * _slideAnimation.value + 80,
              decoration: BoxDecoration(
                color: AppTheme.lightColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.borderRadiusLarge),
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  _buildPanelHandle(),
                  Expanded(child: _buildPanelContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(39, 47, 64, 0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
    );
  }

  Widget _buildPanelContent() {
    // Implementa il contenuto del pannello qui
    return const Placeholder();
  }

  Widget _buildCameraButton() {
    return Positioned(
      right: AppTheme.spacingLarge,
      bottom: _isPanelExpanded ? 320 : 100,
      child: GestureDetector(
        onTap: () => _openCamera(context),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppTheme.softShadow,
          ),
          child: Image.asset(
            'assets/icons/camera.png',
            height: 40,
            width: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: AppTheme.spacingMedium,
      bottom: _isPanelExpanded ? 380 : 160,
      child: Column(
        children: [
          _MapControlButton(
            icon: Icons.add,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _MapControlButton(
            icon: Icons.remove,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _MapControlButton(
            icon: Icons.my_location,
            onPressed: () {
              _mapController.move(
                LatLng(widget.latitude, widget.longitude),
                15,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        boxShadow: AppTheme.softShadow,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: AppTheme.darkColor,
        tooltip: 'Map control',
      ),
    );
  }
}
