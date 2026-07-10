import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';

class BudgetSettingsScreen extends ConsumerStatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  ConsumerState<BudgetSettingsScreen> createState() =>
      _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends ConsumerState<BudgetSettingsScreen> {
  final _monthlyController = TextEditingController();
  final _foodController = TextEditingController();
  final _fuelController = TextEditingController();
  final _shoppingController = TextEditingController();

  @override
  void dispose() {
    _monthlyController.dispose();
    _foodController.dispose();
    _fuelController.dispose();
    _shoppingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = ref.read(budgetRepositoryProvider);
    final monthly = int.tryParse(_monthlyController.text);
    if (monthly != null) {
      await repository.setMonthlyLimit(monthly * 100);
    }

    for (final entry in {
      'Food': _foodController.text,
      'Fuel': _fuelController.text,
      'Shopping': _shoppingController.text,
    }.entries) {
      final limit = int.tryParse(entry.value);
      if (limit != null) {
        await repository.setCategoryBudget(
          category: entry.key,
          limitPaise: limit * 100,
        );
      }
    }

    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(categoryBudgetsProvider);
    invalidateDashboardAndWidgets(ref);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _monthlyController,
            decoration: const InputDecoration(
              labelText: 'Monthly budget (₹)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text(
            'Suggested category budgets',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          TextField(
            controller: _foodController,
            decoration: const InputDecoration(labelText: 'Food (₹)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _fuelController,
            decoration: const InputDecoration(labelText: 'Fuel (₹)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _shoppingController,
            decoration: const InputDecoration(labelText: 'Shopping (₹)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Save budgets'),
          ),
        ],
      ),
    );
  }
}
