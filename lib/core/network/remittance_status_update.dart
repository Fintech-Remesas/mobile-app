import 'package:equatable/equatable.dart';

class RemittanceStatusUpdate extends Equatable {
  final String remittanceId;
  final String status;
  final String? txHash;
  final int? blockNumber;
  final String? explorerUrl;
  final String? detail;
  final String? timestamp;

  const RemittanceStatusUpdate({
    required this.remittanceId,
    required this.status,
    this.txHash,
    this.blockNumber,
    this.explorerUrl,
    this.detail,
    this.timestamp,
  });

  factory RemittanceStatusUpdate.fromSocketData(dynamic data) {
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return RemittanceStatusUpdate(
      remittanceId: map['remittanceId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      txHash: map['txHash'] as String?,
      blockNumber: (map['blockNumber'] as num?)?.toInt(),
      explorerUrl: map['explorerUrl'] as String?,
      detail: map['detail'] as String?,
      timestamp: map['timestamp'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [remittanceId, status, txHash, blockNumber, explorerUrl, detail, timestamp];
}
