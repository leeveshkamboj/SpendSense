import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';

class ManualAddSuggestionListener extends ConsumerWidget {
  const ManualAddSuggestionListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(manualAddSuggestionProvider, (previous, next) {
      if (next == null) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'SpendSense could not parse a bank SMS. Add the transaction manually.',
          ),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ref.read(manualAddSuggestionProvider.notifier).state = null;
            },
          ),
        ),
      );
      ref.read(manualAddSuggestionProvider.notifier).state = null;
    });

    return child;
  }
}
