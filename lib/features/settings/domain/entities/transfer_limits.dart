import 'package:equatable/equatable.dart';

class TransferLimits extends Equatable {
  final double dailyUsed;
  final double dailyTotal;
  final double monthlyUsed;
  final double monthlyTotal;

  const TransferLimits({
    required this.dailyUsed,
    required this.dailyTotal,
    required this.monthlyUsed,
    required this.monthlyTotal,
  });

  double get dailyProgress => dailyUsed / dailyTotal;
  double get monthlyProgress => monthlyUsed / monthlyTotal;

  @override
  List<Object?> get props => [dailyUsed, dailyTotal, monthlyUsed, monthlyTotal];
}
