import 'package:flutter/material.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';

class CardNetworkIcon extends StatelessWidget {
  const CardNetworkIcon({
    required CardNetwork network,
    super.key,
    this.size = 20,
    this.fallbackColor,
  })  : _network = network,
        _rawNetwork = null;

  const CardNetworkIcon.optional({
    required String? network,
    super.key,
    this.size = 20,
    this.fallbackColor,
  })  : _network = null,
        _rawNetwork = network;

  final CardNetwork? _network;
  final String? _rawNetwork;
  final double size;
  final Color? fallbackColor;

  CardNetwork? get _resolved => _network ?? CardNetwork.parse(_rawNetwork);

  @override
  Widget build(BuildContext context) {
    final network = _resolved;
    if (network == null) {
      return Icon(
        Icons.credit_card,
        size: size,
        color: fallbackColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return switch (network) {
      CardNetwork.mastercard => _MastercardMark(size: size),
      CardNetwork.rupay => _RupayMark(size: size),
      _ => _TextNetworkBadge(network: network, size: size),
    };
  }
}

class _TextNetworkBadge extends StatelessWidget {
  const _TextNetworkBadge({
    required this.network,
    required this.size,
  });

  final CardNetwork network;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fontSize = network == CardNetwork.amex ? size * 0.34 : size * 0.42;

    return Container(
      height: size,
      constraints: BoxConstraints(minWidth: size * 1.5),
      padding: EdgeInsets.symmetric(horizontal: size * 0.22),
      decoration: BoxDecoration(
        color: network.brandColor,
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        network.shortLabel,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: network == CardNetwork.visa ? -0.4 : 0,
        ),
      ),
    );
  }
}

class _RupayMark extends StatelessWidget {
  const _RupayMark({required this.size});

  final double size;

  static const _navy = Color(0xFF002C77);
  static const _orange = Color(0xFFED6B22);
  static const _green = Color(0xFF097B3A);

  @override
  Widget build(BuildContext context) {
    final chevronWidth = size * 0.2;
    final chevronHeight = size * 0.72;

    return Container(
      width: size * 2.15,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.14),
      ),
      padding: EdgeInsets.only(
        left: size * 0.14,
        right: size * 0.1,
        top: size * 0.08,
        bottom: size * 0.08,
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'RuPay',
                style: TextStyle(
                  color: _navy,
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.3,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size * 0.52,
            height: chevronHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: _RupayChevron(
                    width: chevronWidth,
                    height: chevronHeight,
                    color: _green,
                  ),
                ),
                Positioned(
                  right: size * 0.12,
                  top: 0,
                  child: _RupayChevron(
                    width: chevronWidth,
                    height: chevronHeight,
                    color: _orange,
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

class _RupayChevron extends StatelessWidget {
  const _RupayChevron({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RupayChevronPainter(color: color),
    );
  }
}

class _RupayChevronPainter extends CustomPainter {
  const _RupayChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RupayChevronPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _MastercardMark extends StatelessWidget {
  const _MastercardMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final diameter = size * 0.82;

    return SizedBox(
      width: size * 1.45,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: (size - diameter) / 2,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: (size - diameter) / 2,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: const BoxDecoration(
                color: Color(0xFFF79E1B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
