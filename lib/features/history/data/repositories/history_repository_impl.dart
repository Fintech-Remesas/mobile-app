import 'package:intl/intl.dart';

import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HistoryItem>> getTransactionHistory() async {
    final movements = await remoteDataSource.fetchMovements('');
    
    // Sort descending by date
    movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return movements.map((movement) {
      final isOutgoing = movement.amount < 0;
      final dateStr = DateFormat('MMM d, yyyy').format(movement.createdAt);
      
      return HistoryItem(
        id: movement.transactionId,
        title: movement.description ?? movement.type,
        subtitle: dateStr,
        amount: movement.amount,
        isOutgoing: isOutgoing,
        date: movement.createdAt, // Need to add this to HistoryItem
      );
    }).toList();
  }
}
