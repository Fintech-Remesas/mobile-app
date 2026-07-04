import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DepositFundsParams extends Equatable {
  final double amount;
  final String currency;
  final String cardId;
  final String description;

  const DepositFundsParams({
    required this.amount,
    required this.currency,
    required this.cardId,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, currency, cardId, description];
}

class DepositFunds implements UseCase<void, DepositFundsParams> {
  final TransactionRepository repository;

  DepositFunds(this.repository);

  @override
  Future<void> call(DepositFundsParams params) {
    return repository.deposit(params.amount, params.currency, params.cardId, params.description);
  }
}
