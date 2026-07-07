import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

// Export LatLng so it is natively visible in all importing files
export 'package:latlong2/latlong.dart' show LatLng;

class CameraPosition {
  final ll.LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;
  const CameraPosition({
    required this.target,
    this.zoom = 10,
    this.bearing = 0,
    this.tilt = 0,
  });
}

class CameraUpdate {
  final ll.LatLng? target;
  final double? zoom;
  CameraUpdate._({this.target, this.zoom});
  static CameraUpdate newCameraPosition(CameraPosition position) => CameraUpdate._(target: position.target, zoom: position.zoom);
  static CameraUpdate newLatLng(ll.LatLng latLng) => CameraUpdate._(target: latLng);
  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) => CameraUpdate._();
  static CameraUpdate newLatLngZoom(ll.LatLng latLng, double zoom) => CameraUpdate._(target: latLng, zoom: zoom);
}

class LatLngBounds {
  final ll.LatLng southwest;
  final ll.LatLng northeast;
  LatLngBounds({required this.southwest, required this.northeast});
}

enum MapType { normal, satellite, terrain, hybrid, none }

class MinMaxZoomPreference {
  final double? min;
  final double? max;
  const MinMaxZoomPreference(this.min, this.max);
  static const MinMaxZoomPreference unbound = MinMaxZoomPreference(null, null);
}

class BitmapDescriptor {
  const BitmapDescriptor();
  static Future<BitmapDescriptor> fromAssetImage(dynamic config, String assetName) async {
    return const BitmapDescriptor();
  }
  static BitmapDescriptor fromBytes(dynamic bytes) {
    return const BitmapDescriptor();
  }
}

class InfoWindow {
  final String? title;
  final String? snippet;
  const InfoWindow({this.title, this.snippet});
}

class MarkerId {
  final String value;
  const MarkerId(this.value);
  @override
  bool operator ==(Object other) => other is MarkerId && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

class Marker {
  final MarkerId markerId;
  final ll.LatLng position;
  final BitmapDescriptor? icon;
  final VoidCallback? onTap;
  final bool draggable;
  final bool visible;
  final Offset? anchor;
  final double rotation;
  final double zIndex;
  final bool flat;
  final InfoWindow infoWindow;

  const Marker({
    required this.markerId,
    required this.position,
    this.icon,
    this.onTap,
    this.draggable = false,
    this.visible = true,
    this.anchor,
    this.rotation = 0.0,
    this.zIndex = 0.0,
    this.flat = false,
    this.infoWindow = const InfoWindow(),
  });
}

class PolylineId {
  final String value;
  const PolylineId(this.value);
  @override
  bool operator ==(Object other) => other is PolylineId && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

class Polyline {
  final PolylineId polylineId;
  final List<ll.LatLng> points;
  final Color color;
  final int width;
  const Polyline({
    required this.polylineId,
    required this.points,
    this.color = Colors.blue,
    this.width = 5,
  });
}

class GoogleMapController {
  final fm.MapController fmController;
  GoogleMapController(this.fmController);

  Future<void> animateCamera(CameraUpdate update) async {
    if (update.target != null) {
      fmController.move(update.target!, update.zoom ?? fmController.camera.zoom);
    }
  }

  Future<void> moveCamera(CameraUpdate update) async {
    if (update.target != null) {
      fmController.move(update.target!, update.zoom ?? fmController.camera.zoom);
    }
  }

  Future<LatLngBounds> getVisibleRegion() async {
    return LatLngBounds(
      southwest: fmController.camera.visibleBounds.southWest,
      northeast: fmController.camera.visibleBounds.northEast,
    );
  }

  Future<double> getZoomLevel() async {
    return fmController.camera.zoom;
  }

  Future<Uint8List?> takeSnapshot() async {
    return null;
  }

  Future<void> setMapStyle(String style) async {}

  void dispose() {}
}

class GoogleMap extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final void Function(GoogleMapController)? onMapCreated;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool zoomGesturesEnabled;
  final MinMaxZoomPreference minMaxZoomPreference;
  final void Function(CameraPosition)? onCameraMove;
  final VoidCallback? onCameraIdle;
  final void Function(ll.LatLng)? onTap;
  final void Function(ll.LatLng)? onLongPress;
  final bool compassEnabled;
  final VoidCallback? onCameraMoveStarted;
  final bool indoorViewEnabled;
  final bool mapToolbarEnabled;

  const GoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.onMapCreated,
    this.markers,
    this.polylines,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.zoomGesturesEnabled = true,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbound,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.compassEnabled = false,
    this.onCameraMoveStarted,
    this.indoorViewEnabled = false,
    this.mapToolbarEnabled = false,
  });

  @override
  State<GoogleMap> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  late final fm.MapController _fmController;
  late final GoogleMapController _gController;

  @override
  void initState() {
    super.initState();
    _fmController = fm.MapController();
    _gController = GoogleMapController(_fmController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapCreated?.call(_gController);
    });
  }

  Widget _buildMarkerIcon(Marker marker) {
    final id = marker.markerId.value.toLowerCase();
    
    if (id.contains('pickup') || id.contains('from')) {
      return const Icon(
        Icons.location_on,
        color: Colors.green,
        size: 38,
      );
    } else if (id.contains('destination') || id.contains('to')) {
      return const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 38,
      );
    } else if (id.contains('driver') || id.contains('delivery') || id.contains('car') || id.contains('bike')) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: const Icon(
          Icons.directions_car,
          color: Colors.amber,
          size: 20,
        ),
      );
    } else if (id.contains('user') || id.contains('current')) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          width: 14,
          height: 14,
        ),
      );
    }

    return const Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 34,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmMarkers = (widget.markers ?? {}).map((m) {
      return fm.Marker(
        point: m.position,
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: m.onTap,
          child: _buildMarkerIcon(m),
        ),
      );
    }).toList();

    final fmPolylines = (widget.polylines ?? {}).map((p) {
      return fm.Polyline(
        points: p.points,
        color: p.color,
        strokeWidth: p.width.toDouble(),
      );
    }).toList();

    return Container(
      color: const Color(0xFFCFE3F5),
      child: Stack(
        children: [
          fm.FlutterMap(
            mapController: _fmController,
            options: fm.MapOptions(
              initialCenter: widget.initialCameraPosition.target,
              initialZoom: widget.initialCameraPosition.zoom,
              minZoom: 3.0,
              maxZoom: 19.0,
              interactionOptions: const fm.InteractionOptions(
                flags: fm.InteractiveFlag.pinchZoom |
                       fm.InteractiveFlag.doubleTapZoom |
                       fm.InteractiveFlag.drag |
                       fm.InteractiveFlag.scrollWheelZoom,
              ),
              onPositionChanged: (position, hasGesture) {
                if (widget.onCameraMove != null && position.center != null) {
                  widget.onCameraMove!(CameraPosition(
                    target: position.center!,
                    zoom: position.zoom ?? 10.0,
                  ));
                }
              },
              onTap: (tapPosition, point) => widget.onTap?.call(point),
              onLongPress: (tapPosition, point) => widget.onLongPress?.call(point),
            ),
            children: [
              fm.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.zekdrive.app',
                maxNativeZoom: 19,
              ),
              if (fmPolylines.isNotEmpty)
                fm.PolylineLayer(polylines: fmPolylines),
              if (fmMarkers.isNotEmpty)
                fm.MarkerLayer(markers: fmMarkers),
            ],
          ),
          // Boutons zoom +/-
          if (widget.zoomControlsEnabled)
            Positioned(
              right: 12,
              bottom: 120,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onTap: () => _fmController.move(
                      _fmController.camera.center,
                      (_fmController.camera.zoom + 1).clamp(3.0, 19.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _ZoomButton(
                    icon: Icons.remove,
                    onTap: () => _fmController.move(
                      _fmController.camera.center,
                      (_fmController.camera.zoom - 1).clamp(3.0, 19.0),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bouton zoom flottant
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
