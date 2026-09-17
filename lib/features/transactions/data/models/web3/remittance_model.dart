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
  final String? senderCountry;
  final String? recipientCountry;
  final String? destinationWalletAddress;
  final String? blockchainTxHash;
  final int? blockNumber;

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
    this.senderCountry,
    this.recipientCountry,
    this.destinationWalletAddress,
    this.blockchainTxHash,
    this.blockNumber,
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
      senderCountry: json['senderCountry']?.toString(),
      recipientCountry: json['recipientCountry']?.toString(),
      destinationWalletAddress: json['destinationWalletAddress']?.toString(),
      blockchainTxHash: json['blockchainTxHash']?.toString(),
      blockNumber: json['blockNumber'] != null ? int.tryParse(json['blockNumber'].toString()) : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
