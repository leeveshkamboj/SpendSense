import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  static const assetPath = 'assets/icons/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.22;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'SpendSense',
      ),
    );
  }
}

class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({
    required this.title,
    super.key,
    this.logoSize = 28,
  });

  final String title;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 10),
        Flexible(child: Text(title)),
      ],
    );
  }
}

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key, this.logoSize = 88});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(height: 12),
        Text(
          'SpendSense',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
