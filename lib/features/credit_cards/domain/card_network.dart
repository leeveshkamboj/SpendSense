import 'package:flutter/material.dart';

enum CardNetwork {
  visa(
    storageValue: 'visa',
    displayName: 'Visa',
    brandColor: Color(0xFF1A1F71),
    shortLabel: 'VISA',
  ),
  mastercard(
    storageValue: 'mastercard',
    displayName: 'Mastercard',
    brandColor: Color(0xFFEB001B),
    shortLabel: 'MC',
  ),
  rupay(
    storageValue: 'rupay',
    displayName: 'RuPay',
    brandColor: Color(0xFF097939),
    shortLabel: 'RuPay',
  ),
  amex(
    storageValue: 'amex',
    displayName: 'Amex',
    brandColor: Color(0xFF006FCF),
    shortLabel: 'AMEX',
  );

  const CardNetwork({
    required this.storageValue,
    required this.displayName,
    required this.brandColor,
    required this.shortLabel,
  });

  final String storageValue;
  final String displayName;
  final Color brandColor;
  final String shortLabel;

  static CardNetwork? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final normalized = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (normalized) {
      'visa' => CardNetwork.visa,
      'mastercard' || 'mc' => CardNetwork.mastercard,
      'rupay' => CardNetwork.rupay,
      'amex' || 'americanexpress' => CardNetwork.amex,
      _ => null,
    };
  }

  static String? canonicalStorageValue(String? raw) => parse(raw)?.storageValue;
}
