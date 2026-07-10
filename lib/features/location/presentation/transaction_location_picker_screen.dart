import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/location/presentation/transaction_location_preview.dart';

Future<TransactionLocation?> showTransactionLocationPicker(
  BuildContext context, {
  TransactionLocation? initial,
}) {
  return Navigator.of(context).push<TransactionLocation>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => TransactionLocationPickerScreen(initial: initial),
    ),
  );
}

class TransactionLocationPickerScreen extends ConsumerStatefulWidget {
  const TransactionLocationPickerScreen({this.initial, super.key});

  final TransactionLocation? initial;

  @override
  ConsumerState<TransactionLocationPickerScreen> createState() =>
      _TransactionLocationPickerScreenState();
}

class _TransactionLocationPickerScreenState
    extends ConsumerState<TransactionLocationPickerScreen> {
  final _mapController = MapController();
  final _labelController = TextEditingController();
  LatLng? _selected;
  bool _loadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial?.coordinates ?? defaultMapCenter(widget.initial);
    _labelController.text = widget.initial?.label ?? '';
  }

  @override
  void dispose() {
    _mapController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingCurrentLocation = true);
    try {
      final service = ref.read(geolocationServiceProvider);
      final position = await service.readCurrentPosition();
      if (!mounted || position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not read current location')),
          );
        }
        return;
      }

      setState(() => _selected = position);
      _mapController.move(position, 16);

      final label = await service.reverseGeocode(position);
      if (!mounted || label == null) {
        return;
      }
      if (_labelController.text.trim().isEmpty) {
        _labelController.text = label;
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCurrentLocation = false);
      }
    }
  }

  void _confirmSelection() {
    final selected = _selected;
    if (selected == null) {
      return;
    }

    final label = _labelController.text.trim();
    Navigator.of(context).pop(
      TransactionLocation(
        latitude: selected.latitude,
        longitude: selected.longitude,
        label: label.isEmpty ? null : label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? defaultMapCenter(widget.initial);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selected,
                initialZoom: 15,
                onTap: (_, point) => setState(() => _selected = point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.spendsense.spendsense',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: scheme.error,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tap the map to move the pin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Location label',
                      hintText: 'Store, neighbourhood, or address',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed:
                        _loadingCurrentLocation ? null : _useCurrentLocation,
                    icon: _loadingCurrentLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _loadingCurrentLocation
                          ? 'Finding location…'
                          : 'Use current location',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
