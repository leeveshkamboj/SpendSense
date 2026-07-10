import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/location/presentation/transaction_location_picker_screen.dart';
import 'package:spendsense/features/location/presentation/transaction_location_preview.dart';

class TransactionLocationField extends ConsumerWidget {
  const TransactionLocationField({
    required this.location,
    required this.onChanged,
    super.key,
  });

  final TransactionLocation? location;
  final ValueChanged<TransactionLocation?> onChanged;

  Future<void> _pickLocation(BuildContext context) async {
    final picked = await showTransactionLocationPicker(
      context,
      initial: location,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  Future<void> _useCurrentLocation(BuildContext context, WidgetRef ref) async {
    final service = ref.read(geolocationServiceProvider);
    final position = await service.readCurrentPosition();
    if (!context.mounted || position == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read current location')),
        );
      }
      return;
    }

    final label = await service.reverseGeocode(position);
    onChanged(
      TransactionLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hasLocation = location != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (hasLocation) ...[
          if (location!.hasCoordinates)
            TransactionLocationPreview(location: location!),
          if (location!.hasCoordinates) const SizedBox(height: 8),
          Text(
            location!.displayLabel(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
        ] else
          Text(
            'No location set',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickLocation(context),
              icon: const Icon(Icons.map_outlined),
              label: Text(hasLocation ? 'Change on map' : 'Pick on map'),
            ),
            OutlinedButton.icon(
              onPressed: () => _useCurrentLocation(context, ref),
              icon: const Icon(Icons.my_location),
              label: const Text('Use current location'),
            ),
            if (hasLocation)
              TextButton.icon(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
          ],
        ),
      ],
    );
  }
}
