import 'package:equatable/equatable.dart';

/// Entidad que representa un movimiento del ledger (asiento contable)
/// obtenido del endpoint GET /api/v1/movements/user/{userId}
class LedgerMovement extends Equatable {
  final String transactionId;
  final String type;       // DEPOSIT, WITHDRAWAL, TRANSFER, REFUND, SETTLEMENT
  final String status;     // PENDING, COMPLETED, FAILED, REVERSED
  final String? description;
  final String accountId;
  final double amount;       // Negativo = débito, Positivo = crédito
  final double balanceAfter;
  final DateTime createdAt;

  const LedgerMovement({
    required this.transactionId,
    required this.type,
    required this.status,
    this.description,
    required this.accountId,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isIncoming => amount > 0;

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return 'Depósito';
      case 'WITHDRAWAL':
        return 'Retiro';
      case 'TRANSFER':
        return isIncoming ? 'Transferencia recibida' : 'Transferencia enviada';
      case 'REFUND':
        return 'Reembolso';
      case 'SETTLEMENT':
        return 'Liquidación';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [
        transactionId,
        type,
        status,
        description,
        accountId,
        amount,
        balanceAfter,
        createdAt,
      ];
}
