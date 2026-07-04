import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class WithdrawFundsParams extends Equatable {
  final double amount;
  final String currency;
  final String bankAccountId;
  final String description;

  const WithdrawFundsParams({
    required this.amount,
    required this.currency,
    required this.bankAccountId,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, currency, bankAccountId, description];
}

class WithdrawFunds implements UseCase<void, WithdrawFundsParams> {
  final TransactionRepository repository;

  WithdrawFunds(this.repository);

  @override
  Future<void> call(WithdrawFundsParams params) {
    return repository.withdraw(params.amount, params.currency, params.bankAccountId, params.description);
  }
}
