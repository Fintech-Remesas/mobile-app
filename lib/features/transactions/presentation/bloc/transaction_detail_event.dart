part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionDetail extends TransactionDetailEvent {
  final String id;

  const LoadTransactionDetail(this.id);

  @override
  List<Object?> get props => [id];
}
