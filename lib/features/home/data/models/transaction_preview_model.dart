import '../../domain/entities/transaction_preview.dart';

class TransactionPreviewModel extends TransactionPreview {
  const TransactionPreviewModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.isOutgoing,
  });

  factory TransactionPreviewModel.fromJson(Map<String, dynamic> json) {
    return TransactionPreviewModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      isOutgoing: json['isOutgoing'] as bool,
    );
  }
}
