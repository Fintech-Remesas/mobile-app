import '../repositories/payment_methods_repository.dart';

class DeleteCard {
  final PaymentMethodsRepository repository;

  DeleteCard(this.repository);

  Future<void> call(String id) {
    return repository.deleteCard(id);
  }
}
