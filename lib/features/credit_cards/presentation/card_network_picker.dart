import 'package:flutter/material.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_icon.dart';

class CardNetworkPicker extends StatelessWidget {
  const CardNetworkPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final CardNetwork? value;
  final ValueChanged<CardNetwork?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card network',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Not set'),
              selected: value == null,
              onSelected: (selected) {
                if (selected) {
                  onChanged(null);
                }
              },
            ),
            for (final network in CardNetwork.values)
              FilterChip(
                avatar: CardNetworkIcon(network: network, size: 14),
                label: Text(network.displayName),
                selected: value == network,
                onSelected: (selected) {
                  onChanged(selected ? network : null);
                },
              ),
          ],
        ),
      ],
    );
  }
}
