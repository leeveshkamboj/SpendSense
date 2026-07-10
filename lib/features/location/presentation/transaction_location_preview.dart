import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';

const _defaultCenter = LatLng(12.9716, 77.5946);

class TransactionLocationPreview extends StatelessWidget {
  const TransactionLocationPreview({
    required this.location,
    super.key,
  });

  final TransactionLocation location;

  @override
  Widget build(BuildContext context) {
    final coordinates = location.coordinates;
    if (coordinates == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coordinates,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.spendsense.spendsense',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: coordinates,
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
    );
  }
}

LatLng defaultMapCenter([TransactionLocation? location]) {
  return location?.coordinates ?? _defaultCenter;
}
