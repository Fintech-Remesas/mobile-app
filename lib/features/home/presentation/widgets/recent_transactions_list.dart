import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../domain/entities/transaction_preview.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransactionPreview> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  String _formatAmount(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    final value = amount.abs().toStringAsFixed(2);
    return '$sign\$$value';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: tx.isOutgoing
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                child: Icon(
                  tx.isOutgoing
                      ? LucideIcons.arrowUpRight
                      : LucideIcons.arrowDownLeft,
                  color: tx.isOutgoing ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              title: Text(tx.title),
              subtitle: Text(tx.subtitle),
              trailing: Text(
                _formatAmount(tx.amount),
                style: TextStyle(
                  color: tx.isOutgoing ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => context.push('/transaction/${tx.id}'),
            );
          },
        ),
      ],
    );
  }
}
