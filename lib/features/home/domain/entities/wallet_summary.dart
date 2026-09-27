import 'package:equatable/equatable.dart';

class WalletSummary extends Equatable {
  final double balance;
  final String currency;
  final bool bonusEligible;

  const WalletSummary({
    required this.balance,
    required this.currency,
    this.bonusEligible = false,
  });

  @override
  List<Object?> get props => [balance, currency, bonusEligible];
}
