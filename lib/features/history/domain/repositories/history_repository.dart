import '../entities/history_page.dart';

abstract class HistoryRepository {
  Future<HistoryPage> getTransactionHistoryPage({int page = 0, int size = 20});
}
