import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';

class AlertThresholdsSettingsScreen extends ConsumerStatefulWidget {
  const AlertThresholdsSettingsScreen({super.key});

  @override
  ConsumerState<AlertThresholdsSettingsScreen> createState() =>
      _AlertThresholdsSettingsScreenState();
}

class _AlertThresholdsSettingsScreenState
    extends ConsumerState<AlertThresholdsSettingsScreen> {
  final _seventyFiveController = TextEditingController();
  final _ninetyController = TextEditingController();
  final _oneHundredController = TextEditingController();

  @override
  void dispose() {
    _seventyFiveController.dispose();
    _ninetyController.dispose();
    _oneHundredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thresholds = ref.watch(alertThresholdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Spending alerts')),
      body: thresholds.when(
        data: (values) {
          _seventyFiveController.text = values.seventyFive.toString();
          _ninetyController.text = values.ninety.toString();
          _oneHundredController.text = values.oneHundred.toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Alert when monthly budget spend crosses:'),
              const SizedBox(height: 16),
              TextField(
                controller: _seventyFiveController,
                decoration: const InputDecoration(labelText: 'First threshold (%)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ninetyController,
                decoration: const InputDecoration(labelText: 'Second threshold (%)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _oneHundredController,
                decoration: const InputDecoration(labelText: 'Final threshold (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(),
                child: const Text('Save thresholds'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _save() async {
    final seventyFive = int.tryParse(_seventyFiveController.text);
    final ninety = int.tryParse(_ninetyController.text);
    final oneHundred = int.tryParse(_oneHundredController.text);
    if (seventyFive == null || ninety == null || oneHundred == null) {
      return;
    }

    await ref.read(budgetRepositoryProvider).setAlertThresholds(
          seventyFive: seventyFive,
          ninety: ninety,
          oneHundred: oneHundred,
        );
    ref.invalidate(alertThresholdsProvider);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

final alertThresholdsProvider = FutureProvider<BudgetAlertThresholdConfig>((ref) {
  return ref.watch(budgetRepositoryProvider).alertThresholds();
});
