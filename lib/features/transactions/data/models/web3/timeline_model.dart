class TimelineStepModel {
  final int step;
  final String label;
  final String status; // completed, in_progress, pending
  final DateTime? timestamp;
  final String? detail;
  final String? txHash;
  final String? explorerUrl;
  final int? blockNumber;

  TimelineStepModel({
    required this.step,
    required this.label,
    required this.status,
    this.timestamp,
    this.detail,
    this.txHash,
    this.explorerUrl,
    this.blockNumber,
  });

  factory TimelineStepModel.fromJson(Map<String, dynamic> json) {
    return TimelineStepModel(
      step: json['step'] ?? 0,
      label: json['label'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      detail: json['detail'],
      txHash: json['txHash'],
      explorerUrl: json['explorerUrl'],
      blockNumber: json['blockNumber'],
    );
  }
}

class TimelineModel {
  final String remittanceId;
  final String currentStatus;
  final String? txHash;
  final int? blockNumber;
  final String? explorerUrl;
  final List<TimelineStepModel> steps;

  TimelineModel({
    required this.remittanceId,
    required this.currentStatus,
    this.txHash,
    this.blockNumber,
    this.explorerUrl,
    required this.steps,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    var stepsJson = json['steps'] as List? ?? [];
    List<TimelineStepModel> stepsList = stepsJson.map((i) => TimelineStepModel.fromJson(i)).toList();

    return TimelineModel(
      remittanceId: json['remittanceId'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
      txHash: json['txHash'],
      blockNumber: json['blockNumber'],
      explorerUrl: json['explorerUrl'],
      steps: stepsList,
    );
  }
}
