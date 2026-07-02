import 'package:equatable/equatable.dart';

class TimelineStep extends Equatable {
  final int step;
  final String label;
  final String status;
  final String? timestamp;
  final String? detail;
  final String? txHash;
  final String? explorerUrl;
  final int? blockNumber;

  const TimelineStep({
    required this.step,
    required this.label,
    required this.status,
    this.timestamp,
    this.detail,
    this.txHash,
    this.explorerUrl,
    this.blockNumber,
  });

  @override
  List<Object?> get props =>
      [step, label, status, timestamp, detail, txHash, explorerUrl, blockNumber];
}
