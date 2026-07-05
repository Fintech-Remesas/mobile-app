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
  final String? senderName;
  final String? recipientName;

  RemittanceModel({
    required this.remittanceId,
    required this.depositCode,
    required this.amountUSD,
    required this.feeAmount,
    required this.amountDestination,
    required this.amountSourceCurrency,
    required this.message,
    this.expiresAt,
    this.status = '',
    this.txHash,
    this.userId,
    this.senderName,
    this.recipientName,
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
      senderName: json['senderName']?.toString(),
      recipientName: json['recipientName']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
