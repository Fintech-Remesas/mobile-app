import '../entities/remittance.dart';
import '../repositories/transaction_repository.dart';

class GetRemittanceParams {
  final String id;

  const GetRemittanceParams({required this.id});
}

class GetRemittance {
  final TransactionRepository repository;

  GetRemittance(this.repository);

  Future<Remittance> call(GetRemittanceParams params) {
    return repository.getRemittance(params.id);
  }
}
