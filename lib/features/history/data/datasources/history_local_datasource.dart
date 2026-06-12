import '../../../../core/data/mock_data_source.dart';
import '../models/history_item_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryItemModel>> fetchHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final MockDataSource mockDataSource;

  HistoryLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<List<HistoryItemModel>> fetchHistory() async {
    await mockDataSource.simulateDelay();
    return MockDataSource.historyTransactions
        .map(HistoryItemModel.fromJson)
        .toList();
  }
}
