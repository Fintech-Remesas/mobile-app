import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isOutgoing;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isOutgoing,
  });

  @override
  List<Object?> get props => [id, title, subtitle, amount, isOutgoing];
}
