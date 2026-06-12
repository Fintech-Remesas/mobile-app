import 'package:equatable/equatable.dart';

class WalletSummary extends Equatable {
  final double balance;
  final String currency;

  const WalletSummary({
    required this.balance,
    required this.currency,
  });

  @override
  List<Object?> get props => [balance, currency];
}
