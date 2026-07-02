import 'package:equatable/equatable.dart';

import 'timeline_step.dart';

class TransactionDetail extends Equatable {
  final String id;
  final double amount;
  final String status;
  final String statusLabel;
  final String recipient;
  final String? transactionHash;
  final String network;
  final int blockNumber;
  final String confirmationStatus;
  final DateTime blockTimestamp;
  final String? polygonscanUrl;
  final String? depositCode;
  final double? amountSourceCurrency;
  final String? errorMessage;
  final List<TimelineStep> timelineSteps;
  final bool isPolling;

  const TransactionDetail({
    required this.id,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.recipient,
    this.transactionHash,
    required this.network,
    required this.blockNumber,
    required this.confirmationStatus,
    required this.blockTimestamp,
    this.polygonscanUrl,
    this.depositCode,
    this.amountSourceCurrency,
    this.errorMessage,
    this.timelineSteps = const [],
    this.isPolling = false,
  });

  bool get hasTransactionHash =>
      transactionHash != null && transactionHash!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        amount,
        status,
        statusLabel,
        recipient,
        transactionHash,
        network,
        blockNumber,
        confirmationStatus,
        blockTimestamp,
        polygonscanUrl,
        depositCode,
        amountSourceCurrency,
        errorMessage,
        timelineSteps,
        isPolling,
      ];
}
