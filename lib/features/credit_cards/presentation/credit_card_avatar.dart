import 'package:flutter/material.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';
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
    final parsed = CardNetwork.parse(network);
    final diameter = radius * 2;

    if (parsed == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.14),
        child: Icon(
          Icons.credit_card,
          size: radius * 0.95,
          color: color,
        ),
      );
    }

    // Network marks are wider than tall — use a rounded rect so they aren't clipped.
    final width = switch (parsed) {
      CardNetwork.rupay => diameter * 1.55,
      CardNetwork.mastercard => diameter * 1.2,
      _ => diameter * 1.35,
    };

    return Container(
      width: width,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius * 0.4),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: radius * 0.18,
        vertical: radius * 0.22,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: CardNetworkIcon(
          network: parsed,
          size: diameter * 0.7,
          fallbackColor: color,
        ),
      ),
    );
  }
}
