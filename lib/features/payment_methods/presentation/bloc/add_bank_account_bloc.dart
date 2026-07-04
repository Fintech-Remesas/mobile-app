import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_bank_account.dart';

// Events
abstract class AddBankAccountEvent extends Equatable {
  const AddBankAccountEvent();

  @override
  List<Object?> get props => [];
}

class AddBankAccountSubmitted extends AddBankAccountEvent {
  final String bankName;
  final String accountNumber;
  final String accountType;
  final String currency;
  final String country;
  final String? alias;

  const AddBankAccountSubmitted({
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.country,
    this.alias,
  });

  @override
  List<Object?> get props => [
        bankName,
        accountNumber,
        accountType,
        currency,
        country,
        alias,
      ];
}

// States
abstract class AddBankAccountState extends Equatable {
  const AddBankAccountState();

  @override
  List<Object?> get props => [];
}

class AddBankAccountInitial extends AddBankAccountState {}

class AddBankAccountLoading extends AddBankAccountState {}

class AddBankAccountSuccess extends AddBankAccountState {}

class AddBankAccountFailure extends AddBankAccountState {
  final String message;
  const AddBankAccountFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AddBankAccountBloc extends Bloc<AddBankAccountEvent, AddBankAccountState> {
  final AddBankAccount addBankAccount;

  AddBankAccountBloc({required this.addBankAccount}) : super(AddBankAccountInitial()) {
    on<AddBankAccountSubmitted>(_onAddBankAccountSubmitted);
  }

  Future<void> _onAddBankAccountSubmitted(
    AddBankAccountSubmitted event,
    Emitter<AddBankAccountState> emit,
  ) async {
    emit(AddBankAccountLoading());
    try {
      await addBankAccount(AddBankAccountParams(
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        accountType: event.accountType,
        currency: event.currency,
        country: event.country,
        alias: event.alias,
      ));
      emit(AddBankAccountSuccess());
    } catch (e) {
      emit(AddBankAccountFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
