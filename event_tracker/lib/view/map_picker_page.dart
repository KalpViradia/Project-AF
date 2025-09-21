import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629); // India centroid as a neutral default
  final MapController _mapController = MapController();
  LatLng _selected = _defaultCenter;
  String? _selectedAddress;
  bool _reverseLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrapFromArgs();
  }

  Future<void> _bootstrapFromArgs() async {
    final args = Get.arguments;
    if (args is Map && args['address'] is String && (args['address'] as String).trim().isNotEmpty) {
      // Try to forward geocode provided address using Nominatim
      try {
        final result = await _forwardGeocodeNominatim(args['address'] as String);
        if (result != null) {
          _selected = result;
          _selectedAddress = args['address'] as String;
          setState(() {});
          _mapController.move(_selected, 15);
          return;
        }
      } catch (_) {
        // ignore and keep defaults
      }
    }
    // Fallback: try to center on the user's current location
    await _tryCenterOnUser();
  }

  Future<void> _onMapTap(LatLng latLng) async {
    setState(() {
      _selected = latLng;
      _reverseLoading = true;
      _selectedAddress = null;
      _error = null;
    });
    // Move/zoom to the tapped location
    _mapController.move(latLng, 15);
    try {
      final address = await _reverseGeocodeNominatim(latLng.latitude, latLng.longitude);
      setState(() {
        _selectedAddress = address ?? '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to resolve address';
        _selectedAddress = '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _reverseLoading = false;
      });
    }
  }

  Future<void> _tryCenterOnUser() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final me = LatLng(pos.latitude, pos.longitude);
      await _onMapTap(me);
    } catch (_) {
      // Ignore and keep default center
    }
  }

  Future<String?> _reverseGeocodeNominatim(double lat, double lon) async {
    final dio = Get.find<Dio>();
    final url = 'https://nominatim.openstreetmap.org/reverse';
    final resp = await dio.get(
      url,
      queryParameters: {
        'format': 'jsonv2',
        'lat': lat,
        'lon': lon,
      },
      options: kIsWeb
          ? null
          : Options(
              headers: {
                'User-Agent': 'EventTrackerFlutter/1.0 (https://example.com)'
              },
            ),
    );
    if (resp.statusCode == 200 && resp.data is Map) {
      final map = resp.data as Map;
      return map['display_name']?.toString();
    }
    return null;
  }

  Future<LatLng?> _forwardGeocodeNominatim(String query) async {
    final dio = Get.find<Dio>();
    final url = 'https://nominatim.openstreetmap.org/search';
    final resp = await dio.get(
      url,
      queryParameters: {
        'format': 'jsonv2',
        'q': query,
        'limit': 1,
      },
      options: kIsWeb
          ? null
          : Options(
              headers: {
                'User-Agent': 'EventTrackerFlutter/1.0 (https://example.com)'
              },
            ),
    );
    if (resp.statusCode == 200) {
      final data = resp.data;
      if (data is List && data.isNotEmpty) {
        final item = data.first as Map;
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 4,
                onTap: (tapPos, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.event_tracker',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.redAccent, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _reverseLoading
                          ? const Text('Resolving address...')
                          : Text(
                              _selectedAddress ?? 'Tap on the map to select a location',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_selectedAddress != null && !_reverseLoading)
                            ? () {
                                // Return the address with coordinates
                                Get.back(result: {
                                  'address': _selectedAddress,
                                  'latitude': _selected.latitude,
                                  'longitude': _selected.longitude,
                                  'pickedFromMap': true,
                                });
                              }
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Use this location'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
