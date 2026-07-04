import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/deposit_funds.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();
  @override
  List<Object?> get props => [];
}

class SubmitDeposit extends DepositEvent {
  final double amount;
  final String currency;
  final String cardId;
  final String description;

  const SubmitDeposit({
    required this.amount,
    required this.currency,
    required this.cardId,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, currency, cardId, description];
}

abstract class DepositState extends Equatable {
  const DepositState();
  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {}

class DepositLoading extends DepositState {}

class DepositSuccess extends DepositState {}

class DepositFailure extends DepositState {
  final String error;
  const DepositFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final DepositFunds depositFunds;

  DepositBloc({required this.depositFunds}) : super(DepositInitial()) {
    on<SubmitDeposit>(_onSubmitDeposit);
  }

  Future<void> _onSubmitDeposit(SubmitDeposit event, Emitter<DepositState> emit) async {
    emit(DepositLoading());
    try {
      await depositFunds(DepositFundsParams(
        amount: event.amount,
        currency: event.currency,
        cardId: event.cardId,
        description: event.description,
      ));
      emit(DepositSuccess());
    } catch (e) {
      emit(DepositFailure(e.toString()));
    }
  }
}
