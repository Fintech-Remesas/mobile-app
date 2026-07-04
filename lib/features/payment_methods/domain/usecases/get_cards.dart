import '../entities/payment_card.dart';
import '../repositories/payment_methods_repository.dart';

class GetCards {
  final PaymentMethodsRepository repository;

  GetCards(this.repository);

  Future<List<PaymentCard>> call() async {
    final list = await repository.getCards();
    return list.map((e) => PaymentCard.fromJson(e as Map<String, dynamic>)).toList();
  }
}
