class QuoteModel {
  final String quoteId;
  final double amountUSD;
  final String sourceCurrency;
  final String destinationCurrency;
  final double exchangeRate;
  final double fee;
  final double feeAmount;
  final double gasFee;
  final double amountDestination;
  final double amountSourceCurrency;
  final double usdcPrice;
  final double commissionPct;
  final double amountReceivedUSD;
  final DateTime expiresAt;

  QuoteModel({
    required this.quoteId,
    required this.amountUSD,
    required this.sourceCurrency,
    required this.destinationCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.feeAmount,
    required this.gasFee,
    required this.amountDestination,
    required this.amountSourceCurrency,
    required this.usdcPrice,
    required this.commissionPct,
    required this.amountReceivedUSD,
    required this.expiresAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteId: json['quoteId']?.toString() ?? '',
      amountUSD: _toDouble(json['amountUSD']),
      sourceCurrency: json['sourceCurrency'] ?? 'USD',
      destinationCurrency: json['destinationCurrency'] ?? 'USD',
      exchangeRate: _toDouble(json['exchangeRate']),
      fee: _toDouble(json['fee'] ?? json['commissionPct'] ?? 0.025),
      feeAmount: _toDouble(json['feeAmount'] ?? json['commissionAmount']),
      gasFee: _toDouble(json['gasFee'] ?? json['gasFeeUSD']),
      amountDestination: _toDouble(json['amountDestination'] ?? json['amountReceivedUSD']),
      amountSourceCurrency: _toDouble(json['amountSourceCurrency']),
      usdcPrice: _toDouble(json['usdcPrice'], fallback: 1.0),
      commissionPct: _toDouble(json['commissionPct'] ?? json['fee'], fallback: 0.025),
      amountReceivedUSD: _toDouble(json['amountReceivedUSD'] ?? json['amountDestination']),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ?? DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }
}
