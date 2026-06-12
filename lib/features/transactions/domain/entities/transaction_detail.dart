import 'package:equatable/equatable.dart';

class TransactionDetail extends Equatable {
  final String id;
  final double amount;
  final String status;
  final String recipient;
  final String transactionHash;
  final String network;
  final int blockNumber;
  final String confirmationStatus;
  final DateTime blockTimestamp;

  const TransactionDetail({
    required this.id,
    required this.amount,
    required this.status,
    required this.recipient,
    required this.transactionHash,
    required this.network,
    required this.blockNumber,
    required this.confirmationStatus,
    required this.blockTimestamp,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        status,
        recipient,
        transactionHash,
        network,
        blockNumber,
        confirmationStatus,
        blockTimestamp,
      ];
}
