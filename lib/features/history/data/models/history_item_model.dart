import '../../domain/entities/history_item.dart';

class HistoryItemModel extends HistoryItem {
  const HistoryItemModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.isOutgoing,
    required super.date,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      isOutgoing: json['isOutgoing'] as bool,
      date: DateTime.now(), // dummy for mock
    );
  }
}
