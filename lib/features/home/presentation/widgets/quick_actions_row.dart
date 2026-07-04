import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickActionsRow extends StatelessWidget {
  final bool enabled;

  const QuickActionsRow({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: enabled ? () => context.push('/deposit') : null,
            icon: const Icon(LucideIcons.arrowUpCircle),
            label: const Text('Deposit'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? () => context.push('/withdraw') : null,
            icon: const Icon(LucideIcons.arrowDownCircle),
            label: const Text('Withdraw'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
