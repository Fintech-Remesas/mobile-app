import '../../domain/entities/ledger_movement.dart';
import '../../domain/entities/transaction_preview.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/wallet_summary_model.dart';
import 'package:http/http.dart' as http;

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
    HomeRemoteDataSource? remoteDataSource,
  }) : remoteDataSource =
            remoteDataSource ?? HomeRemoteDataSourceImpl(client: http.Client());

  @override
  Future<WalletSummary> getWalletSummary() async {
    try {
      return await remoteDataSource.fetchWalletSummary('');
    } catch (e) {
      // Cuenta nueva o error de API: mostrar $0.00 en lugar del mock ficticio
      print('[HomeRepo] Balance API failed: $e — showing \$0.00');
      return const WalletSummaryModel(balance: 0.0, currency: 'USD');
    }
  }

  @override
  Future<List<TransactionPreview>> getRecentTransactions() {
    return localDataSource.fetchRecentTransactions();
  }

  @override
  Future<List<LedgerMovement>> getLedgerMovements() async {
    try {
      final movements = await remoteDataSource.fetchMovements('');
      return movements;
    } catch (e) {
      print('[HomeRepo] Movements remote failed: $e');
      // En caso de error, devolvemos lista vacía (sin fallback a mock para evitar confusión)
      return [];
    }
  }
}
