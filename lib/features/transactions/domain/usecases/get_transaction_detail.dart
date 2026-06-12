import '../entities/transaction_detail.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionDetailParams {
  final String id;

  const GetTransactionDetailParams({required this.id});
}

class GetTransactionDetail {
  final TransactionRepository repository;

  GetTransactionDetail(this.repository);

  Future<TransactionDetail> call(GetTransactionDetailParams params) {
    return repository.getTransactionDetail(params.id);
  }
}
