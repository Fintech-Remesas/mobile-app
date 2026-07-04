import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isOutgoing;
  final DateTime date;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isOutgoing,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, subtitle, amount, isOutgoing, date];
}
