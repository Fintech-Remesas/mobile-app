import '../repositories/transaction_repository.dart';

class ConfirmDepositParams {
  final String remittanceId;

  const ConfirmDepositParams({required this.remittanceId});
}

class ConfirmDeposit {
  final TransactionRepository repository;

  ConfirmDeposit(this.repository);

  Future<void> call(ConfirmDepositParams params) {
    return repository.confirmDeposit(params.remittanceId);
  }
}
