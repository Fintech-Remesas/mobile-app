import '../entities/quote.dart';
import '../repositories/transaction_repository.dart';

class CreateQuoteParams {
  final double amount;

  const CreateQuoteParams({required this.amount});
}

class CreateQuote {
  final TransactionRepository repository;

  CreateQuote(this.repository);

  Future<Quote> call(CreateQuoteParams params) {
    return repository.createQuote(amount: params.amount);
  }
}
