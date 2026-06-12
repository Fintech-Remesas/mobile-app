part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {
  const TransactionDetailInitial();
}

class TransactionDetailLoading extends TransactionDetailState {
  const TransactionDetailLoading();
}

class TransactionDetailLoaded extends TransactionDetailState {
  final TransactionDetail detail;

  const TransactionDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
