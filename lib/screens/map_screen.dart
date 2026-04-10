import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/center_store.dart';
import '../l10n/app_localizations.dart';
import '../models/center.dart';
import '../widgets/center_image.dart';
import '../widgets/language_toggle_button.dart';
import 'center_detail.dart';

class CenterMapScreen extends StatefulWidget {
  const CenterMapScreen({super.key});

  @override
  State<CenterMapScreen> createState() => _CenterMapScreenState();
}

class _CenterMapScreenState extends State<CenterMapScreen> {
  GoogleMapController? _mapController;
  final ScrollController _cardsController = ScrollController();
  String? _selectedCenterId;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  bool _isLocating = false;
  BitmapDescriptor? _centerMarkerIcon;
  BitmapDescriptor? _selectedCenterMarkerIcon;
  BitmapDescriptor? _currentLocationMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _cardsController.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    final centerMarkerIcon = await _createCenterMarkerDescriptor(
      fillColor: const Color(0xFFEA4335),
      borderColor: Colors.white,
      iconColor: Colors.white,
      size: 44,
    );
    final selectedCenterMarkerIcon = await _createCenterMarkerDescriptor(
      fillColor: const Color(0xFF2563EB),
      borderColor: Colors.white,
      iconColor: Colors.white,
      size: 50,
    );
    final currentLocationMarkerIcon = await _createCurrentLocationDescriptor();
    if (!mounted) return;
    setState(() {
      _centerMarkerIcon = centerMarkerIcon;
      _selectedCenterMarkerIcon = selectedCenterMarkerIcon;
      _currentLocationMarkerIcon = currentLocationMarkerIcon;
    });
  }

  Future<BitmapDescriptor> _createCenterMarkerDescriptor({
    required Color fillColor,
    required Color borderColor,
    required Color iconColor,
    required double size,
  }) async {
    final pixelRatio = math.max(
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
      2.0,
    );
    final scaledSize = size * pixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = scaledSize;
    final height = scaledSize * 1.22;
    final circleRadius = scaledSize * 0.28;
    final center = Offset(width / 2, circleRadius + 6);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final fillPaint = Paint()..color = fillColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledSize * 0.055;

    final path = Path()
      ..moveTo(center.dx, height - 8)
      ..lineTo(center.dx - circleRadius * 0.78, center.dy + circleRadius * 0.64)
      ..arcToPoint(
        Offset(center.dx + circleRadius * 0.78, center.dy + circleRadius * 0.64),
        radius: Radius.circular(circleRadius * 1.3),
      )
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.22), 10, false);
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawCircle(center, circleRadius, fillPaint);
    canvas.drawCircle(center, circleRadius, borderPaint);
    canvas.drawPath(path, borderPaint);

    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.storefront_rounded.codePoint),
      style: TextStyle(
        fontSize: scaledSize * 0.3,
        color: iconColor,
        fontFamily: Icons.storefront_rounded.fontFamily,
        package: Icons.storefront_rounded.fontPackage,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
          width.ceil(),
          height.ceil(),
        );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }

  Future<BitmapDescriptor> _createCurrentLocationDescriptor() async {
    final pixelRatio = math.max(
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
      2.0,
    );
    const size = 46.0;
    final scaledSize = size * pixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(scaledSize / 2, scaledSize / 2);

    final haloPaint = Paint()..color = const Color(0xFF4285F4).withValues(alpha: 0.16);
    final ringPaint = Paint()..color = Colors.white;
    final strokePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * pixelRatio;
    final dotPaint = Paint()..color = const Color(0xFF4285F4);

    canvas.drawCircle(center, 17 * pixelRatio, haloPaint);
    canvas.drawCircle(center, 9.5 * pixelRatio, ringPaint);
    canvas.drawCircle(center, 9.5 * pixelRatio, strokePaint);
    canvas.drawCircle(center, 4.8 * pixelRatio, dotPaint);

    final image = await recorder.endRecording().toImage(
          scaledSize.ceil(),
          scaledSize.ceil(),
        );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }

  void _showLocationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _startLocationStream() {
    if (_positionStreamSubscription != null) return;
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<void> _loadCurrentLocation({
    bool moveCamera = false,
    bool showErrors = false,
  }) async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showErrors) {
          _showLocationMessage('Location service is off.');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (showErrors) {
          _showLocationMessage('Location permission is required.');
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) {
        if (showErrors) {
          _showLocationMessage('Could not get your location.');
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
      _startLocationStream();
      if (moveCamera) {
        await _moveCamera(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.8,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _moveCamera({
    required LatLng target,
    double zoom = 15,
  }) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _moveToCurrentLocation() {
    final position = _currentPosition;
    if (position == null) {
      _loadCurrentLocation(moveCamera: true, showErrors: true);
      return;
    }
    _loadCurrentLocation();
    _moveCamera(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15.8,
    );
  }

  void _selectCenter(List<EsportCenter> centers, EsportCenter center) {
    setState(() {
      _selectedCenterId = center.id;
    });
    _moveCamera(
      target: LatLng(center.latitude, center.longitude),
      zoom: 15,
    );

    final index = centers.indexWhere((item) => item.id == center.id);
    if (index >= 0 && _cardsController.hasClients) {
      _cardsController.animateTo(
        index * 252,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Set<Marker> _buildMarkers(
    BuildContext context,
    List<EsportCenter> centers,
    EsportCenter selectedCenter,
  ) {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'You'),
          icon: _currentLocationMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    for (final center in centers) {
      final isSelected = center.id == selectedCenter.id;
      markers.add(
        Marker(
          markerId: MarkerId(center.id),
          position: LatLng(center.latitude, center.longitude),
          infoWindow: InfoWindow(
            title: center.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CenterDetail(center: center),
                ),
              );
            },
          ),
          icon: isSelected
              ? (_selectedCenterMarkerIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure))
              : (_centerMarkerIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
          anchor: const Offset(0.5, 0.92),
          zIndexInt: isSelected ? 2 : 1,
          onTap: () => _selectCenter(centers, center),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    final position = _currentPosition;
    if (position == null) return const <Circle>{};
    return <Circle>{
      Circle(
        circleId: const CircleId('current_location_accuracy'),
        center: LatLng(position.latitude, position.longitude),
        radius: math.max(position.accuracy, 32),
        fillColor: const Color(0xFF4285F4).withValues(alpha: 0.12),
        strokeColor: const Color(0xFF4285F4).withValues(alpha: 0.22),
        strokeWidth: 1,
      ),
    };
  }

  String? _distanceLabelFor(EsportCenter center) {
    final position = _currentPosition;
    if (position == null) return null;

    final distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      center.latitude,
      center.longitude,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }

    final distanceInKm = distanceInMeters / 1000;
    final decimals = distanceInKm >= 10 ? 0 : 1;
    return '${distanceInKm.toStringAsFixed(decimals)} km';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    const bottomNavEstimatedHeight = 64.0;
    final cardBottomOffset = bottomSafeArea + bottomNavEstimatedHeight;

    return ValueListenableBuilder<List<EsportCenter>>(
      valueListenable: CenterStore.centersNotifier,
      builder: (context, centers, _) {
        if (centers.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.mapTitle),
              actions: const [LanguageToggleButton()],
            ),
            body: Center(
              child: Text(
                l10n.noCentersFound,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        final selectedCenter = centers.cast<EsportCenter?>().firstWhere(
              (center) => center?.id == _selectedCenterId,
              orElse: () => centers.first,
            )!;

        final initialTarget = LatLng(
          selectedCenter.latitude,
          selectedCenter.longitude,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.mapTitle),
            actions: const [LanguageToggleButton()],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 13.2,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                buildingsEnabled: true,
                indoorViewEnabled: true,
                trafficEnabled: false,
                markers: _buildMarkers(context, centers, selectedCenter),
                circles: _buildCircles(),
                onTap: (_) => FocusScope.of(context).unfocus(),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: FloatingActionButton.small(
                  heroTag: 'map_focus_selected',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1F2937),
                  onPressed: _moveToCurrentLocation,
                  child: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1F2937),
                          ),
                        )
                      : const Icon(Icons.my_location_rounded),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: cardBottomOffset,
                child: SizedBox(
                  height: 124,
                  child: ListView.separated(
                    controller: _cardsController,
                    scrollDirection: Axis.horizontal,
                    itemCount: centers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final center = centers[index];
                      final isSelected = center.id == selectedCenter.id;
                      final distanceLabel = _distanceLabelFor(center);
                      return SizedBox(
                        width: 234,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _selectCenter(centers, center),
                          onDoubleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CenterDetail(center: center),
                              ),
                            );
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            scale: isSelected ? 1 : 0.96,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: isSelected ? 0.98 : 0.95,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : Colors.black.withValues(alpha: 0.06),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isSelected ? 0.18 : 0.1,
                                    ),
                                    blurRadius: isSelected ? 24 : 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CenterImage(
                                  imageBase64: center.profileImageBase64,
                                  width: 64,
                                  height: double.infinity,
                                  borderRadius: 12,
                                ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                center.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 180),
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? const Color(0xFF2563EB)
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                         Text(
                                           center.address,
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                           style: const TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 11,
                                            height: 1.2,
                                           ),
                                         ),
                                         if (distanceLabel != null) ...[
                                           const SizedBox(height: 2),
                                           Text(
                                             distanceLabel,
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                             style: const TextStyle(
                                               color: Color(0xFF6B7280),
                                               fontSize: 10.5,
                                               fontWeight: FontWeight.w600,
                                             ),
                                           ),
                                         ],
                                         const Spacer(),
                                         Text(
                                           l10n.pricePerHourLabel(center.price),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          l10n.pcCountLabel(center.pcCount),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
