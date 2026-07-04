import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/withdraw_funds.dart';

abstract class WithdrawEvent extends Equatable {
  const WithdrawEvent();
  @override
  List<Object?> get props => [];
}

class SubmitWithdraw extends WithdrawEvent {
  final double amount;
  final String currency;
  final String bankAccountId;
  final String description;

  const SubmitWithdraw({
    required this.amount,
    required this.currency,
    required this.bankAccountId,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, currency, bankAccountId, description];
}

abstract class WithdrawState extends Equatable {
  const WithdrawState();
  @override
  List<Object?> get props => [];
}

class WithdrawInitial extends WithdrawState {}

class WithdrawLoading extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {}

class WithdrawFailure extends WithdrawState {
  final String error;
  const WithdrawFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final WithdrawFunds withdrawFunds;

  WithdrawBloc({required this.withdrawFunds}) : super(WithdrawInitial()) {
    on<SubmitWithdraw>(_onSubmitWithdraw);
  }

  Future<void> _onSubmitWithdraw(SubmitWithdraw event, Emitter<WithdrawState> emit) async {
    emit(WithdrawLoading());
    try {
      await withdrawFunds(WithdrawFundsParams(
        amount: event.amount,
        currency: event.currency,
        bankAccountId: event.bankAccountId,
        description: event.description,
      ));
      emit(WithdrawSuccess());
    } catch (e) {
      emit(WithdrawFailure(e.toString()));
    }
  }
}
