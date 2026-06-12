import '../../domain/entities/wallet_summary.dart';

class WalletSummaryModel extends WalletSummary {
  const WalletSummaryModel({
    required super.balance,
    required super.currency,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}
