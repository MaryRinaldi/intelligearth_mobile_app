import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intelligearth_mobile/models/quest_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../config/map_style.dart';
import 'camera_view_page.dart';
import 'quest_detail_screen.dart';
import '../services/map_service.dart';
import 'package:logger/logger.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  final bool showBackButton;
  final List<QuestMarker>? markers;
  final String? description;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.showBackButton = true,
    this.markers,
    this.description,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;
  bool _isMarkerSelected = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  final MapService _mapService = MapService();
  final logger = Logger();
  String? _routeDistance;
  String? _routeDuration;

  // Posizione di default (Roma - Colosseo)
  static const LatLng _defaultLocation = LatLng(41.8902, 12.4922);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    _startLocationUpdates();
    _initializeMarkers();

    // Add accuracy circle for current location
    if (_currentPosition != null) {
      _updateLocationCircle();
    }
  }

  void _updateLocationCircle() {
    if (_currentPosition != null) {
      setState(() {
        _circles.clear();
        _circles.add(
          Circle(
            circleId: const CircleId('currentLocation'),
            center:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            radius: _currentPosition!.accuracy,
            fillColor: Colors.red.withValues(alpha: 106),
            strokeColor: Colors.redAccent,
            strokeWidth: 1,
          ),
        );
      });
    }
  }

  void _initializeMarkers() {
    _markers = {
      if (widget.markers != null)
        ...widget.markers!.map(
          (marker) => Marker(
            markerId: MarkerId(marker.title),
            position: LatLng(marker.latitude, marker.longitude),
            infoWindow: InfoWindow(title: marker.title),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              marker.isCompleted
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueViolet,
            ),
            onTap: () {
              setState(() => _isMarkerSelected = true);
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(marker.latitude, marker.longitude),
                  17.0,
                ),
              );
            },
          ),
        )
      else
        Marker(
          markerId: const MarkerId('quest'),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(title: widget.title),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
    };
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      timeLimit: Duration(seconds: 30),
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (mounted) {
          final distance = _currentPosition == null ? double.infinity :
            Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              position.latitude,
              position.longitude,
            );
          
          if (distance > 10) {
            setState(() {
              _currentPosition = position;
              _updateLocationCircle();
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionStreamSubscription?.cancel();
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
          content: const Text('Nessuna immagine selezionata.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.darkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
      );
    }
  }

  Future<void> _getDirections() async {
    if (_currentPosition == null) return;
    
    try {
      final result = await _mapService.getDirections(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(widget.latitude, widget.longitude)
      );
      
      setState(() {
        _routeDistance = result['distance'];
        _routeDuration = result['duration'];
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: result['points'],
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } catch (e) {
      logger.e('Error getting directions: $e');
    }
  }

  double _calculateDistance() {
    if (_currentPosition == null) return double.infinity;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.latitude,
      widget.longitude,
    );
  }

  bool _isWithinPhotoDistance() {
    final distance = _calculateDistance();
    return distance <= 50; // 50 meters
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: AppTheme.animationFast,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: _buildMap(),
        ),
        if (widget.showBackButton) _buildTopBar(),
        _buildFloatingActionButtons(),
        if (_isMarkerSelected) _buildMarkerInfoPanel(),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : _defaultLocation,
        zoom: widget.markers != null ? 11.0 : 13.0,
      ),
      mapType: _currentMapType,
      markers: _markers,
      circles: _circles,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      liteModeEnabled: false,
      style: MapStyle.mapStyle,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      onCameraMove: (_) {
        if (_isMarkerSelected) {
          setState(() => _isMarkerSelected = false);
        }
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
                widget.title,
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

  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: AppTheme.spacingMedium,
      bottom: AppTheme.spacingLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              heroTag: 'zoom_in',
              mini: true,
              onPressed: () {
                _mapController?.animateCamera(CameraUpdate.zoomIn());
              },
              child: const Icon(Icons.add, size: 20),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              heroTag: 'zoom_out',
              mini: true,
              onPressed: () {
                _mapController?.animateCamera(CameraUpdate.zoomOut());
              },
              child: const Icon(Icons.remove, size: 20),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              heroTag: 'layer_selector',
              mini: true,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXSmall),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Normale'),
                          leading: Radio<MapType>(
                            value: MapType.normal,
                            groupValue: _currentMapType,
                            onChanged: (value) {
                              setState(() => _currentMapType = value!);
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() => _currentMapType = MapType.normal);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Satellite'),
                          leading: Radio<MapType>(
                            value: MapType.satellite,
                            groupValue: _currentMapType,
                            onChanged: (value) {
                              setState(() => _currentMapType = value!);
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() => _currentMapType = MapType.satellite);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Ibrida'),
                          leading: Radio<MapType>(
                            value: MapType.hybrid,
                            groupValue: _currentMapType,
                            onChanged: (value) {
                              setState(() => _currentMapType = value!);
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() => _currentMapType = MapType.hybrid);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Icon(Icons.layers, size: 20),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              heroTag: 'location',
              mini: true,
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerInfoPanel() {
    final distance = _calculateDistance();
    final isWithinRange = _isWithinPhotoDistance();
    
    return AnimatedPositioned(
      duration: AppTheme.animationNormal,
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _isMarkerSelected ? 0 : -300,
      child: Container(
        height: 300,
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
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  if (_routeDistance != null && _routeDuration != null) ...[
                    Row(
                      children: [
                        Icon(Icons.directions_walk, 
                          size: 16, 
                          color: AppTheme.accentColor
                        ),
                        const SizedBox(width: AppTheme.spacingXSmall),
                        Text(
                          _routeDistance!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textOnLightColor.withValues(alpha: 179),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        Icon(Icons.access_time, 
                          size: 16, 
                          color: AppTheme.accentColor
                        ),
                        const SizedBox(width: AppTheme.spacingXSmall),
                        Text(
                          _routeDuration!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textOnLightColor.withValues(alpha: 179),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                  ],
                  Text(
                    'Distanza: ${(distance / 1000).toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  if (widget.description != null) ...[
                    Text(
                      widget.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestDetailScreen(
                              quest: Quest(
                                title: widget.title,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                                description: widget.description ?? '',
                                imagePath: 'assets/images/quest_default.jpg',
                              ),
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Read more...',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Indicazioni'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isWithinRange 
                            ? () => _openCamera(context)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Devi essere a meno di 50 metri dal punto per scattare una foto. Usa le indicazioni per raggiungerlo.'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.darkColor,
                                    action: SnackBarAction(
                                      label: 'Indicazioni',
                                      textColor: Colors.white,
                                      onPressed: _getDirections,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                    ),
                                  ),
                                );
                              },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scatta Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isWithinRange
                              ? AppTheme.accentColor.withValues(alpha: 106)
                              : AppTheme.accentColor.withValues(alpha: 77),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                            ),
                          ),
                        ),
                      ),
                    ],
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
