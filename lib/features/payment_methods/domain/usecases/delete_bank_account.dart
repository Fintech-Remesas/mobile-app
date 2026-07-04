import '../repositories/payment_methods_repository.dart';

class DeleteBankAccount {
  final PaymentMethodsRepository repository;

  DeleteBankAccount(this.repository);

  Future<void> call(String id) {
    return repository.deleteBankAccount(id);
  }
}
