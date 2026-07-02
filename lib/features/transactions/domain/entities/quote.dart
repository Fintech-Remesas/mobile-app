import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final double sourceAmount;
  final double destAmount;
  final String sourceCurrency;
  final String destCurrency;
  final double? exchangeRate;
  final double? platformFee;
  final DateTime? expiresAt;
  final String? status;

  const Quote({
    required this.id,
    required this.sourceAmount,
    required this.destAmount,
    required this.sourceCurrency,
    required this.destCurrency,
    this.exchangeRate,
    this.platformFee,
    this.expiresAt,
    this.status,
  });

  @override
  List<Object?> get props => [
        id,
        sourceAmount,
        destAmount,
        sourceCurrency,
        destCurrency,
        exchangeRate,
        platformFee,
        expiresAt,
        status,
      ];
}
