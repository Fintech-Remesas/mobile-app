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
      remittanceId: json['remittanceId']?.toString() ?? '',
      depositCode: json['depositCode']?.toString() ?? '',
      amountUSD: _toDouble(json['amountUSD']),
      feeAmount: _toDouble(json['feeAmount']),
      amountDestination: _toDouble(json['amountDestination']),
      amountSourceCurrency: _toDouble(json['amountSourceCurrency'] ?? json['simulatedAmountPEN']),
      message: json['message']?.toString() ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      status: json['status']?.toString() ?? '',
      txHash: json['txHash']?.toString(),
      userId: json['userId']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
