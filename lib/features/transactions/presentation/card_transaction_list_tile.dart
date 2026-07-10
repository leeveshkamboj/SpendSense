import 'package:spendsense/core/formatting/merchant_display.dart';
import 'package:spendsense/core/formatting/transaction_amount_display.dart';
import 'package:spendsense/core/formatting/transaction_date_display.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardTransactionListTile extends StatelessWidget {
  const CardTransactionListTile({
    required this.transaction,
    required this.cardNickname,
    required this.colorValue,
    this.onTap,
    this.onLongPress,
  });

  final CardTransaction transaction;
  final String cardNickname;
  final int colorValue;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final label = formatMerchantLabel(transaction.merchant);
    final color = Color(colorValue);
    final scheme = Theme.of(context).colorScheme;
    final direction = cardTransactionDirection(transaction.kind);
    final amountColor = transactionDirectionColor(scheme, direction);

    return InkWell(
      onTap: onTap ?? () => context.push('/transactions/${transaction.id}'),
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                merchantInitial(label),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$cardNickname · '
                    '${formatTransactionSubtitle(transaction.transactionAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatSignedPaise(transaction.amountPaise, direction),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ),
                ),
                Text(
                  transactionDirectionLabel(direction),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (transaction.isRecoverable)
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  )
                else if (!transaction.isReviewed)
                  Icon(
                    Icons.fiber_new,
                    size: 16,
                    color: scheme.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
