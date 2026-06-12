import '../../domain/entities/transfer_limits.dart';

class TransferLimitsModel extends TransferLimits {
  const TransferLimitsModel({
    required super.dailyUsed,
    required super.dailyTotal,
    required super.monthlyUsed,
    required super.monthlyTotal,
  });

  factory TransferLimitsModel.fromJson(Map<String, dynamic> json) {
    return TransferLimitsModel(
      dailyUsed: (json['dailyUsed'] as num).toDouble(),
      dailyTotal: (json['dailyTotal'] as num).toDouble(),
      monthlyUsed: (json['monthlyUsed'] as num).toDouble(),
      monthlyTotal: (json['monthlyTotal'] as num).toDouble(),
    );
  }
}
