class QuoteModel {
  final String quoteId;
  final double amountUSD;
  final String sourceCurrency;
  final String destinationCurrency;
  final double exchangeRate;
  final double fee;
  final double feeAmount;
  final double amountDestination;
  final double amountSourceCurrency;
  final DateTime expiresAt;

  QuoteModel({
    required this.quoteId,
    required this.amountUSD,
    required this.sourceCurrency,
    required this.destinationCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.feeAmount,
    required this.amountDestination,
    required this.amountSourceCurrency,
    required this.expiresAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteId: json['quoteId'] ?? '',
      amountUSD: (json['amountUSD'] ?? 0).toDouble(),
      sourceCurrency: json['sourceCurrency'] ?? '',
      destinationCurrency: json['destinationCurrency'] ?? '',
      exchangeRate: (json['exchangeRate'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      feeAmount: (json['feeAmount'] ?? 0).toDouble(),
      amountDestination: (json['amountDestination'] ?? 0).toDouble(),
      amountSourceCurrency: (json['amountSourceCurrency'] ?? 0).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
