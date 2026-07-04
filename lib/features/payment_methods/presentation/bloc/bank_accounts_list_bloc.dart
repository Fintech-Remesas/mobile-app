import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bank_account.dart';
import '../../domain/usecases/delete_bank_account.dart';
import '../../domain/usecases/get_bank_accounts.dart';

// Events
abstract class BankAccountsListEvent extends Equatable {
  const BankAccountsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankAccounts extends BankAccountsListEvent {}

class DeleteBankAccountRequested extends BankAccountsListEvent {
  final String id;
  const DeleteBankAccountRequested(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class BankAccountsListState extends Equatable {
  const BankAccountsListState();

  @override
  List<Object?> get props => [];
}

class BankAccountsListInitial extends BankAccountsListState {}

class BankAccountsListLoading extends BankAccountsListState {}

class BankAccountsListLoaded extends BankAccountsListState {
  final List<BankAccount> accounts;
  const BankAccountsListLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class BankAccountsListFailure extends BankAccountsListState {
  final String message;
  const BankAccountsListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BankAccountDeleteSuccess extends BankAccountsListState {}

class BankAccountDeleteFailure extends BankAccountsListState {
  final String message;
  const BankAccountDeleteFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BankAccountsListBloc extends Bloc<BankAccountsListEvent, BankAccountsListState> {
  final GetBankAccounts getBankAccounts;
  final DeleteBankAccount deleteBankAccount;

  BankAccountsListBloc({
    required this.getBankAccounts,
    required this.deleteBankAccount,
  }) : super(BankAccountsListInitial()) {
    on<LoadBankAccounts>(_onLoadBankAccounts);
    on<DeleteBankAccountRequested>(_onDeleteBankAccountRequested);
  }

  Future<void> _onLoadBankAccounts(
    LoadBankAccounts event,
    Emitter<BankAccountsListState> emit,
  ) async {
    emit(BankAccountsListLoading());
    try {
      final accounts = await getBankAccounts();
      emit(BankAccountsListLoaded(accounts));
    } catch (e) {
      emit(BankAccountsListFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteBankAccountRequested(
    DeleteBankAccountRequested event,
    Emitter<BankAccountsListState> emit,
  ) async {
    try {
      await deleteBankAccount(event.id);
      emit(BankAccountDeleteSuccess());
      add(LoadBankAccounts());
    } catch (e) {
      emit(BankAccountDeleteFailure(e.toString().replaceFirst('Exception: ', '')));
      add(LoadBankAccounts());
    }
  }
}
