class RemittanceModel {
  final String remittanceId;
  final String depositCode;
  final double amountUSD;
  final double feeAmount;
  final double amountDestination;
  final double amountSourceCurrency;
  final String message;
  final DateTime? expiresAt;
  final String status;
  final String? txHash;
  final String? userId;

  RemittanceModel({
    required this.remittanceId,
    required this.depositCode,
    required this.amountUSD,
    required this.feeAmount,
    required this.amountDestination,
    required this.amountSourceCurrency,
    required this.message,
    this.expiresAt,
    required this.status,
    this.txHash,
    this.userId,
  });

  factory RemittanceModel.fromJson(Map<String, dynamic> json) {
    return RemittanceModel(
      remittanceId: json['remittanceId'] ?? '',
      depositCode: json['depositCode'] ?? '',
      amountUSD: (json['amountUSD'] ?? 0).toDouble(),
      feeAmount: (json['feeAmount'] ?? 0).toDouble(),
      amountDestination: (json['amountDestination'] ?? 0).toDouble(),
      amountSourceCurrency: (json['amountSourceCurrency'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status: json['status'] ?? '',
      txHash: json['txHash'],
      userId: json['userId'],
    );
  }
}
