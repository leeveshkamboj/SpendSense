import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onFreshStart,
    required this.onRestore,
    super.key,
  });

  final VoidCallback onFreshStart;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Welcome to SpendSense',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Track spending by billing cycle, capture bank SMS automatically, '
                'and stay on top of your bills.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onFreshStart,
                child: const Text('Start fresh'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRestore,
                child: const Text('Restore from backup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
