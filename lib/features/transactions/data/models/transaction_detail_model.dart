import '../../domain/entities/transaction_detail.dart';

class TransactionDetailModel extends TransactionDetail {
  const TransactionDetailModel({
    required super.id,
    required super.amount,
    required super.status,
    required super.recipient,
    required super.transactionHash,
    required super.network,
    required super.blockNumber,
    required super.confirmationStatus,
    required super.blockTimestamp,
    super.remittanceId,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      recipient: json['recipient'] as String,
      transactionHash: json['transactionHash'] as String? ?? '',
      network: json['network'] as String? ?? 'amoyTestnet',
      blockNumber: json['blockNumber'] as int? ?? 0,
      confirmationStatus: json['confirmationStatus'] as String? ?? 'confirmed',
      blockTimestamp: DateTime.parse(json['blockTimestamp'] as String),
      remittanceId: json['remittanceId'] as String?,
    );
  }
}
