import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/reports/data/report_providers.dart';
import 'package:spendsense/features/reports/domain/report_export_service.dart';
import 'package:spendsense/features/reports/domain/report_format.dart';

class ReportExportScreen extends ConsumerStatefulWidget {
  const ReportExportScreen({super.key});

  @override
  ConsumerState<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends ConsumerState<ReportExportScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Export transactions, billing cycles, budgets, analytics, '
            'and recoverable breakdown by person.',
          ),
          const SizedBox(height: 16),
          for (final format in ReportFormat.values) ...[
            FilledButton(
              onPressed: _busy ? null : () => _export(context, format),
              child: Text('Export ${format.label}'),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, ReportFormat format) async {
    setState(() => _busy = true);
    final repository = ref.read(reportRepositoryProvider);
    final service = ref.read(reportExportServiceProvider);
    final snapshot = await repository.buildSnapshot(asOf: DateTime.now());
    final result = await service.export(format: format, snapshot: snapshot);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    switch (result) {
      case ReportExportSuccess(:final filePath):
        await service.shareExportedFile(filePath);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${format.label} report ready to share')),
        );
      case ReportExportFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
    }
  }
}

extension on ReportFormat {
  String get label => switch (this) {
        ReportFormat.pdf => 'PDF',
        ReportFormat.csv => 'CSV',
        ReportFormat.excel => 'Excel',
      };
}
