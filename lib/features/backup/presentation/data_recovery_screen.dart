import 'package:flutter/material.dart';

class DataRecoveryScreen extends StatefulWidget {
  const DataRecoveryScreen({
    required this.localBackups,
    required this.onRestore,
    required this.onExportSalvage,
    required this.onReset,
    super.key,
  });

  final List<String> localBackups;
  final ValueChanged<String> onRestore;
  final VoidCallback onExportSalvage;
  final VoidCallback onReset;

  @override
  State<DataRecoveryScreen> createState() => _DataRecoveryScreenState();
}

class _DataRecoveryScreenState extends State<DataRecoveryScreen> {
  late String? _selectedBackup =
      widget.localBackups.isEmpty ? null : widget.localBackups.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Recovery')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'SpendSense could not open your database. You can restore '
            'from a local backup, export salvageable data, or reset the app.',
          ),
          const SizedBox(height: 24),
          if (widget.localBackups.isEmpty)
            const Text('No local backups found')
          else ...[
            const Text('Local backup'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedBackup,
              items: [
                for (final path in widget.localBackups)
                  DropdownMenuItem(
                    value: path,
                    child: Text(_labelFor(path)),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedBackup = value),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _selectedBackup == null
                ? null
                : () => widget.onRestore(_selectedBackup!),
            child: const Text('Restore from backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onExportSalvage,
            child: const Text('Export salvageable data'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _confirmReset,
            child: const Text('Reset app'),
          ),
        ],
      ),
    );
  }

  String _labelFor(String path) {
    return path.split('/').last;
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset app?'),
        content: const Text(
          'This deletes all local data and returns to onboarding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onReset();
    }
  }
}
