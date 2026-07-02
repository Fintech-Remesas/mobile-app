import 'package:equatable/equatable.dart';

import 'history_item.dart';

class RemittanceSummary extends Equatable {
  final double totalAmountUSD;
  final int totalTransactions;
  final int completedCount;
  final int failedCount;

  const RemittanceSummary({
    required this.totalAmountUSD,
    required this.totalTransactions,
    required this.completedCount,
    required this.failedCount,
  });

  @override
  List<Object?> get props =>
      [totalAmountUSD, totalTransactions, completedCount, failedCount];
}

class HistoryPage extends Equatable {
  final List<HistoryItem> items;
  final int total;
  final int page;
  final int size;
  final RemittanceSummary? summary;

  const HistoryPage({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    this.summary,
  });

  bool get hasMore => (page + 1) * size < total;

  @override
  List<Object?> get props => [items, total, page, size, summary];
}
