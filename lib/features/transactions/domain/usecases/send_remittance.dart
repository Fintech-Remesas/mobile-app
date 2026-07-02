import '../entities/contact.dart';
import '../entities/quote.dart';
import '../entities/remittance.dart';
import '../entities/remittance_destination.dart';
import '../repositories/transaction_repository.dart';

class SendRemittanceParams {
  final Contact recipient;
  final Quote quote;
  final RemittanceDestination destination;

  const SendRemittanceParams({
    required this.recipient,
    required this.quote,
    required this.destination,
  });
}

class SendRemittance {
  final TransactionRepository repository;

  SendRemittance(this.repository);

  Future<Remittance> call(SendRemittanceParams params) {
    return repository.createRemittance(
      quoteId: params.quote.id,
      destination: params.destination,
    );
  }
}
