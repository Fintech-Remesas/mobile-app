import '../entities/contact.dart';
import '../repositories/transaction_repository.dart';

class SendRemittanceParams {
  final Contact recipient;
  final double amount;

  const SendRemittanceParams({
    required this.recipient,
    required this.amount,
  });
}

class SendRemittance {
  final TransactionRepository repository;

  SendRemittance(this.repository);

  Future<String> call(SendRemittanceParams params) {
    return repository.sendRemittance(
      recipient: params.recipient,
      amount: params.amount,
    );
  }
}
