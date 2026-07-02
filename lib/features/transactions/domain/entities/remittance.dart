import 'package:equatable/equatable.dart';

class Remittance extends Equatable {
  final String id;
  final String? quoteId;
  final String status;
  final String? depositCode;
  final double? amountUSD;
  final double? feeAmount;
  final double? amountSourceCurrency;
  final double? simulatedAmountPEN;
  final double? amountDestination;
  final String? message;
  final String? expiresAt;
  final String? txHash;
  final String? explorerUrl;
  final int? blockNumber;
  final String? errorMessage;
  final String? createdAt;

  const Remittance({
    required this.id,
    this.quoteId,
    required this.status,
    this.depositCode,
    this.amountUSD,
    this.feeAmount,
    this.amountSourceCurrency,
    this.simulatedAmountPEN,
    this.amountDestination,
    this.message,
    this.expiresAt,
    this.txHash,
    this.explorerUrl,
    this.blockNumber,
    this.errorMessage,
    this.createdAt,
  });

  double? get depositAmountPEN => simulatedAmountPEN ?? amountSourceCurrency;

  @override
  List<Object?> get props => [
        id,
        quoteId,
        status,
        depositCode,
        amountUSD,
        feeAmount,
        amountSourceCurrency,
        simulatedAmountPEN,
        amountDestination,
        message,
        expiresAt,
        txHash,
        explorerUrl,
        blockNumber,
        errorMessage,
        createdAt,
      ];
}
