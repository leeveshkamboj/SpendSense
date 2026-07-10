import 'package:flutter/material.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_icon.dart';

class CreditCardAvatar extends StatelessWidget {
  const CreditCardAvatar({
    required this.colorValue,
    super.key,
    this.network,
    this.radius = 20,
  });

  final String? network;
  final int colorValue;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final iconSize = radius * 0.95;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.14),
      child: CardNetworkIcon.optional(
        network: network,
        size: iconSize,
        fallbackColor: color,
      ),
    );
  }
}
