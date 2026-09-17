// lib/features/transactions/domain/entities/traceability_metrics.dart

class TraceabilityMetrics {
  final String remittanceId;
  final String currentStatus;
  
  // Checkpoints
  final int blockchainCheckpoints;
  final int traditionalCheckpoints;
  
  // Visibility
  final int blockchainVisibilitySec;
  final int traditionalVisibilitySec;
  
  // Auditability
  final bool blockchainAuditability;
  final bool traditionalAuditability;
  final String? externalVerificationUrl;
  // Real Blockchain Proofs
  final String? txHash;
  final int? blockNumber;
  final String? gasUsed;
  final String? remittanceHash;
  final String? signerAddress;
  
  // Score
  final double blockchainScore;
  final double traditionalScore;
  final String rating;

  TraceabilityMetrics({
    required this.remittanceId,
    required this.currentStatus,
    required this.blockchainCheckpoints,
    required this.traditionalCheckpoints,
    required this.blockchainVisibilitySec,
    required this.traditionalVisibilitySec,
    required this.blockchainAuditability,
    required this.traditionalAuditability,
    this.externalVerificationUrl,
    this.txHash,
    this.blockNumber,
    this.gasUsed,
    this.remittanceHash,
    this.signerAddress,
    required this.blockchainScore,
    required this.traditionalScore,
    required this.rating,
  });
}
