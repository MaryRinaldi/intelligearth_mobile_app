import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intelligearth_mobile/models/quest_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'camera_view_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quest_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? questTitle;
  final bool showBackButton;
  final List<QuestMarker>? markers;
  final String? description;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.questTitle,
    this.showBackButton = false,
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
  bool _isFullScreen = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  // Posizione di default (Roma - Colosseo)
  static const LatLng _defaultLocation = LatLng(41.8902, 12.4922);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    _checkLocationPermission();
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
            fillColor: AppTheme.accentColor.withValues(alpha: 106),
            strokeColor: AppTheme.accentColor,
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
          infoWindow: InfoWindow(title: widget.questTitle ?? ''),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
    };
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _updateLocationCircle();
          });
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

  Future<void> _openGoogleMapsDirections() async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${widget.latitude},${widget.longitude}&travelmode=walking'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
            top: _isFullScreen ? 0 : MediaQuery.of(context).padding.top,
          ),
          child: _buildMap(),
        ),
        if (widget.showBackButton && !_isFullScreen) _buildTopBar(),
        _buildFloatingActionButtons(),
        if (_isMarkerSelected && !_isFullScreen) _buildMarkerInfoPanel(),
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
      markers: {
        ..._markers,
        if (_currentPosition != null)
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: const InfoWindow(title: 'La tua posizione'),
          ),
      },
      circles: _circles,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      onTap: (_) {
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
                widget.questTitle ?? '',
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
          FloatingActionButton(
            heroTag: 'fullscreen',
            onPressed: () {
              setState(() => _isFullScreen = !_isFullScreen);
            },
            child:
                Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          FloatingActionButton(
            heroTag: 'layer_selector',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
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
            child: const Icon(Icons.layers),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          FloatingActionButton(
            heroTag: 'location',
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
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _openCamera(context),
            child: const Icon(Icons.camera_alt),
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
                    widget.questTitle ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
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
                        // Navigate to quest details with proper data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestDetailScreen(
                              quest: Quest(
                                title: widget.questTitle ?? '',
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                                description: widget.description ?? '',
                                imagePath: 'assets/images/quest_default.jpg', // You might want to add this as a parameter
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
                          onPressed: _openGoogleMapsDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Indicazioni'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
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
                                      onPressed: _openGoogleMapsDirections,
                                    ),
                                  ),
                                );
                              },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scatta Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isWithinRange
                              ? AppTheme.accentColor
                              : AppTheme.accentColor.withValues(alpha: 106),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
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
