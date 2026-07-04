import '../../domain/entities/ledger_movement.dart';

/// Modelo de datos que parsea la respuesta JSON del endpoint
/// GET /api/v1/movements/user/{userId} del Sagiro Ledger Service.
///
/// Estructura de respuesta del servidor:
/// {
///   "transactionId": "uuid",
///   "type": "TRANSFER",
///   "status": "COMPLETED",
///   "description": "...",
///   "accountId": "uuid",
///   "amount": -150.00,
///   "balanceAfter": 4100.00,
///   "createdAt": "2026-04-25T17:00:00-05:00"
/// }
class LedgerMovementModel extends LedgerMovement {
  const LedgerMovementModel({
    required super.transactionId,
    required super.type,
    required super.status,
    super.description,
    required super.accountId,
    required super.amount,
    required super.balanceAfter,
    required super.createdAt,
  });

  factory LedgerMovementModel.fromJson(Map<String, dynamic> json) {
    return LedgerMovementModel(
      transactionId: json['transactionId'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      accountId: json['accountId'] as String,
      amount: _parseDouble(json['amount']),
      balanceAfter: _parseDouble(json['balanceAfter']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
