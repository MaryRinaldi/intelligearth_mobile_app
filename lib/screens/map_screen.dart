import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'camera_view_page.dart';

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
  final MapController _mapController = MapController();
  String currentLayer = 'OpenStreetMap DE';
  bool _isMarkerSelected = false;

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
        SnackBar(
          content: Text('Nessuna immagine selezionata.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.darkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildLayerSelector(),
          _buildFloatingActionButtons(),
          if (_isMarkerSelected) _buildMarkerInfoPanel(),
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
        maxZoom: 17.0,
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all),
        onTap: (_, __) {
          if (_isMarkerSelected) {
            setState(() => _isMarkerSelected = false);
          }
        },
      ),
      children: [
        mapLayers[currentLayer]!,
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(widget.latitude, widget.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() => _isMarkerSelected = true);
                  _mapController.move(
                    LatLng(widget.latitude, widget.longitude),
                    17.0,
                  );
                },
                child: _buildCustomMarker(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomMarker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _isMarkerSelected ? 1.2 : 1.0),
      duration: AppTheme.animationFast,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 26,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXSmall,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: AppTheme.spacingXSmall),
            Expanded(
              child: Text(
                widget.questTitle,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        onTap: () => Navigator.maybePop(context),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 106),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppTheme.secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLayerSelector() {
    return Positioned(
      top: 100,
      right: AppTheme.spacingMedium,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: mapLayers.keys.map((String layer) {
            final isSelected = currentLayer == layer;
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusLarge),
                  onTap: () => setState(() => currentLayer = layer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: Text(
                      layer,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color:
                                isSelected ? Colors.white : AppTheme.darkColor,
                          ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: AppTheme.spacingMedium,
      bottom: AppTheme.spacingLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMapControlButton(
            icon: Icons.add,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildMapControlButton(
            icon: Icons.remove,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildMapControlButton(
            icon: Icons.my_location,
            onPressed: () => _mapController.move(
              LatLng(widget.latitude, widget.longitude),
              _mapController.camera.zoom,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          FloatingActionButton(
            onPressed: () => _openCamera(context),
            backgroundColor: AppTheme.accentColor.withValues(alpha: 106),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Icon(icon, color: AppTheme.darkColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerInfoPanel() {
    return AnimatedPositioned(
      duration: AppTheme.animationNormal,
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _isMarkerSelected ? 0 : -200,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusXLarge),
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMedium),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.questTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'Lat: ${widget.latitude.toStringAsFixed(6)}\nLong: ${widget.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  ElevatedButton.icon(
                    onPressed: () => _openCamera(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scatta una foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentColor.withValues(alpha: 106),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
