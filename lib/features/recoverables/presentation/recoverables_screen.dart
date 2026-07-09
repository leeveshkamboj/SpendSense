import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';

class RecoverablesScreen extends ConsumerWidget {
  const RecoverablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recoverables')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Outstanding by person'),
            SizedBox(height: 8),
            RecoverableSummaryCard(),
          ],
        ),
      ),
    );
  }
}
