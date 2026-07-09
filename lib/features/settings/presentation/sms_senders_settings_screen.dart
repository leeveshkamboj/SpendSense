import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/sms_capture/data/sms_sender_providers.dart';

class SmsSendersSettingsScreen extends ConsumerStatefulWidget {
  const SmsSendersSettingsScreen({super.key});

  @override
  ConsumerState<SmsSendersSettingsScreen> createState() =>
      _SmsSendersSettingsScreenState();
}

class _SmsSendersSettingsScreenState
    extends ConsumerState<SmsSendersSettingsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final senders = ref.watch(smsSendersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS senders')),
      body: senders.when(
        data: (rows) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Only SMS from these senders are imported and monitored.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add custom sender',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addSender(),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _addSender(),
            ),
            const SizedBox(height: 16),
            for (final sender in rows)
              ListTile(
                title: Text(sender.address),
                subtitle: Text(sender.isBuiltIn ? 'Built-in' : 'Custom'),
                trailing: sender.isBuiltIn
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeSender(sender.id),
                      ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _addSender() async {
    final address = _controller.text.trim();
    if (address.isEmpty) {
      return;
    }
    await ref.read(smsSenderRepositoryProvider).addCustomSender(address);
    _controller.clear();
    ref.invalidate(smsSendersProvider);
  }

  Future<void> _removeSender(int id) async {
    await ref.read(smsSenderRepositoryProvider).removeCustomSender(id);
    ref.invalidate(smsSendersProvider);
  }
}
