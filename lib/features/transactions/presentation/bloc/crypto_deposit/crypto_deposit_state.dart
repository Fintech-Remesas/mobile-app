import 'package:equatable/equatable.dart';

abstract class CryptoDepositState extends Equatable {
  const CryptoDepositState();
  
  @override
  List<Object?> get props => [];
}

class CryptoDepositInitial extends CryptoDepositState {}

class CryptoDepositLoadingQuote extends CryptoDepositState {}

class CryptoDepositQuoteReady extends CryptoDepositState {
  final String cryptoId;
  final double cryptoAmount;
  final double usdEquivalent;
  final int secondsRemaining;

  const CryptoDepositQuoteReady({
    required this.cryptoId,
    required this.cryptoAmount,
    required this.usdEquivalent,
    required this.secondsRemaining,
  });

  @override
  List<Object?> get props => [cryptoId, cryptoAmount, usdEquivalent, secondsRemaining];
}

class CryptoDepositQuoteExpired extends CryptoDepositState {}

class CryptoDepositSubmitting extends CryptoDepositState {}

class CryptoDepositSuccess extends CryptoDepositState {}

class CryptoDepositFailure extends CryptoDepositState {
  final String error;

  const CryptoDepositFailure(this.error);

  @override
  List<Object?> get props => [error];
}
