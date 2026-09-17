import 'package:equatable/equatable.dart';

abstract class CryptoDepositEvent extends Equatable {
  const CryptoDepositEvent();

  @override
  List<Object?> get props => [];
}

class FetchCryptoQuote extends CryptoDepositEvent {
  final String cryptoId;
  final double cryptoAmount;

  const FetchCryptoQuote({required this.cryptoId, required this.cryptoAmount});

  @override
  List<Object?> get props => [cryptoId, cryptoAmount];
}

class TimerTicked extends CryptoDepositEvent {
  final int secondsRemaining;

  const TimerTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

class SubmitCryptoDeposit extends CryptoDepositEvent {
  final String cryptoId;
  final double cryptoAmount;
  final double usdEquivalent;

  const SubmitCryptoDeposit({
    required this.cryptoId,
    required this.cryptoAmount,
    required this.usdEquivalent,
  });

  @override
  List<Object?> get props => [cryptoId, cryptoAmount, usdEquivalent];
}
