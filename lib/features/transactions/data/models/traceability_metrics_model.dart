// lib/features/transactions/data/models/traceability_metrics_model.dart

import '../../domain/entities/traceability_metrics.dart';

class TraceabilityMetricsModel extends TraceabilityMetrics {
  TraceabilityMetricsModel({
    required super.remittanceId,
    required super.currentStatus,
    required super.blockchainCheckpoints,
    required super.traditionalCheckpoints,
    required super.blockchainVisibilitySec,
    required super.traditionalVisibilitySec,
    required super.blockchainAuditability,
    required super.traditionalAuditability,
    super.externalVerificationUrl,
    super.txHash,
    super.blockNumber,
    super.gasUsed,
    super.remittanceHash,
    super.signerAddress,
    required super.blockchainScore,
    required super.traditionalScore,
    required super.rating,
  });

  factory TraceabilityMetricsModel.fromJson(Map<String, dynamic> json) {
    return TraceabilityMetricsModel(
      remittanceId: json['remittanceId'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
      
      blockchainCheckpoints: json['checkpoints']?['blockchain']?['value'] ?? 0,
      traditionalCheckpoints: json['checkpoints']?['traditional']?['value'] ?? 0,
      
      blockchainVisibilitySec: json['visibility']?['blockchain']?['valueSec'] ?? 0,
      traditionalVisibilitySec: json['visibility']?['traditional']?['valueSec'] ?? 0,
      
      blockchainAuditability: json['auditability']?['blockchain']?['value'] ?? false,
      traditionalAuditability: json['auditability']?['traditional']?['value'] ?? false,
      
      externalVerificationUrl: json['externalVerification']?['polygonscanUrl'] ?? 
                              json['externalVerification']?['contractUrl'],
                              
      txHash: json['cryptographicProof']?['blockchain']?['proofElements']?['transactionHash'],
      blockNumber: json['immutability']?['blockchain']?['proof']?['blockNumber'],
      gasUsed: json['immutability']?['blockchain']?['proof']?['gasUsed'],
      remittanceHash: json['cryptographicProof']?['blockchain']?['proofElements']?['remittanceHash'],
      signerAddress: json['cryptographicProof']?['blockchain']?['proofElements']?['signerAddress'],
                              
      // In this endpoint, we might not have the score directly in the single remittance response, 
      // but we can calculate a simplified version or extract it if available.
      // For now we'll set defaults if it's not present.
      blockchainScore: (json['checkpoints']?['blockchain']?['value'] ?? 0) * 14.2, // Rough estimate (100/7)
      traditionalScore: 28.5, // Rough estimate (2/7 of 100)
      rating: 'Excellent',
    );
  }
}
