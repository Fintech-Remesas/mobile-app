import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/ledger_movement.dart';

class LedgerMovementsList extends StatelessWidget {
  final List<LedgerMovement> movements;

  const LedgerMovementsList({super.key, required this.movements});

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatted = formatter.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Ayer, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM, h:mm a').format(date);
    }
  }

  IconData _getIcon(LedgerMovement movement) {
    switch (movement.type.toUpperCase()) {
      case 'DEPOSIT':
        return LucideIcons.arrowDownLeft;
      case 'WITHDRAWAL':
        return LucideIcons.arrowUpRight;
      case 'TRANSFER':
        return movement.isIncoming
            ? LucideIcons.arrowDownLeft
            : LucideIcons.arrowUpRight;
      case 'REFUND':
        return LucideIcons.refreshCw;
      case 'SETTLEMENT':
        return LucideIcons.landmark;
      default:
        return LucideIcons.arrowLeftRight;
    }
  }

  Color _getColor(LedgerMovement movement) {
    return movement.isIncoming ? const Color(0xFF10B981) : const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transacciones Recientes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (movements.isNotEmpty)
              Text(
                '${movements.length} movimientos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (movements.isEmpty)
          _buildEmptyState(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.15),
            ),
            itemBuilder: (context, index) {
              final m = movements[index];
              final color = _getColor(m);
              return _MovementTile(
                movement: m,
                icon: _getIcon(m),
                color: color,
                formattedAmount: _formatAmount(m.amount),
                formattedDate: _formatDate(m.createdAt),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            LucideIcons.clipboardList,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Sin transacciones aún',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final LedgerMovement movement;
  final IconData icon;
  final Color color;
  final String formattedAmount;
  final String formattedDate;

  const _MovementTile({
    required this.movement,
    required this.icon,
    required this.color,
    required this.formattedAmount,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Ícono con fondo circular
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // Descripción y fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description?.isNotEmpty == true
                      ? movement.description!
                      : movement.typeLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedAmount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              _StatusChip(status: movement.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _chipColor {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'FAILED':
        return const Color(0xFFEF4444);
      case 'REVERSED':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Completado';
      case 'PENDING':
        return 'Pendiente';
      case 'FAILED':
        return 'Fallido';
      case 'REVERSED':
        return 'Revertido';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
