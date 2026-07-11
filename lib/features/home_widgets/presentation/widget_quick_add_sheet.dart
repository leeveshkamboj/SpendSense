import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_icon.dart';
import 'package:spendsense/features/home_widgets/presentation/quick_add_host.dart';
import 'package:spendsense/features/home_widgets/presentation/widget_quick_add_save.dart';

/// Compact transaction form shown over the Android launcher.
class WidgetQuickAddSheet extends ConsumerStatefulWidget {
  const WidgetQuickAddSheet({
    this.initialKind,
    this.onFinished,
    super.key,
  });

  /// When null, reads kind from the QuickAddActivity method channel.
  final String? initialKind;

  /// Override for tests instead of finishing the Android activity.
  final VoidCallback? onFinished;

  @override
  ConsumerState<WidgetQuickAddSheet> createState() =>
      _WidgetQuickAddSheetState();
}

class _WidgetQuickAddSheetState extends ConsumerState<WidgetQuickAddSheet> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();

  var _kind = 'expense';
  var _ready = false;
  var _saving = false;
  int? _selectedCardId;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final kind = widget.initialKind ?? await readQuickAddInitialKind();
    if (!mounted) {
      return;
    }
    setState(() {
      _kind = kind == 'income' || kind == 'refund' ? 'refund' : 'expense';
      _ready = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
      return;
    }
    await finishQuickAddActivity();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    final result = await saveWidgetQuickAdd(
      read: ref.read,
      widgetRef: ref,
      request: WidgetQuickAddSaveRequest(
        kind: _kind,
        amountText: _amountController.text,
        merchantText: _merchantController.text,
        cardId: _selectedCardId,
      ),
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case WidgetQuickAddSaveSuccess():
        await _close();
      case WidgetQuickAddSaveFailure(:final message):
        setState(() {
          _saving = false;
          _errorText = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = ref.watch(activeCreditCardsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !_saving) {
            _close();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (!_ready || _saving) ? null : _close,
                  child: const ColoredBox(color: Colors.black54),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: theme.colorScheme.surface,
                    elevation: 8,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: _buildSheetBody(theme, cards),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetBody(
    ThemeData theme,
    AsyncValue<List<CreditCard>> cards,
  ) {
    if (!_ready) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return cards.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 120,
        child: Center(child: Text('Could not load cards')),
      ),
      data: (cardList) {
        if (cardList.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'Add a credit card in SpendSense first',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _close,
                child: const Text('Close'),
              ),
            ],
          );
        }

        final selectedId = _selectedCardId ?? cardList.first.id;
        if (_selectedCardId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _selectedCardId != null) {
              return;
            }
            setState(() => _selectedCardId = selectedId);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _kind == 'refund' ? 'Quick add income' : 'Quick add expense',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: selectedId,
              decoration: const InputDecoration(
                labelText: 'Card',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final card in cardList)
                  DropdownMenuItem(
                    value: card.id,
                    child: Row(
                      children: [
                        CardNetworkIcon.optional(
                          network: card.network,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(card.nickname),
                      ],
                    ),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(() => _selectedCardId = value);
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _merchantController,
              enabled: !_saving,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Merchant (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _close,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
