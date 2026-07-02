import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/usecases/add_bank_account.dart';
import '../../domain/usecases/delete_bank_account.dart';
import '../../domain/usecases/get_bank_accounts.dart';

part 'bank_account_event.dart';
part 'bank_account_state.dart';

class BankAccountBloc extends Bloc<BankAccountEvent, BankAccountState> {
  final GetBankAccounts getBankAccounts;
  final AddBankAccount addBankAccount;
  final DeleteBankAccount deleteBankAccount;

  BankAccountBloc({
    required this.getBankAccounts,
    required this.addBankAccount,
    required this.deleteBankAccount,
  }) : super(const BankAccountInitial()) {
    on<LoadBankAccounts>(_onLoad);
    on<AddBankAccountRequested>(_onAdd);
    on<DeleteBankAccountRequested>(_onDelete);
  }

  Future<void> _onLoad(
    LoadBankAccounts event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(const BankAccountLoading());
    try {
      final accounts = await getBankAccounts();
      emit(BankAccountLoaded(accounts));
    } catch (e) {
      emit(BankAccountError(_messageFrom(e)));
    }
  }

  Future<void> _onAdd(
    AddBankAccountRequested event,
    Emitter<BankAccountState> emit,
  ) async {
    final current = state is BankAccountLoaded ? (state as BankAccountLoaded).accounts : <BankAccount>[];
    emit(BankAccountSubmitting(current));
    try {
      await addBankAccount(
        AddBankAccountParams(
          bankName: event.bankName,
          accountNumber: event.accountNumber,
          accountType: event.accountType,
          currency: event.currency,
          country: event.country,
          alias: event.alias,
        ),
      );
      final accounts = await getBankAccounts();
      emit(BankAccountLoaded(accounts, successMessage: 'Cuenta agregada'));
    } catch (e) {
      emit(BankAccountError(_messageFrom(e), accounts: current));
    }
  }

  Future<void> _onDelete(
    DeleteBankAccountRequested event,
    Emitter<BankAccountState> emit,
  ) async {
    final current = state is BankAccountLoaded ? (state as BankAccountLoaded).accounts : <BankAccount>[];
    emit(BankAccountSubmitting(current));
    try {
      await deleteBankAccount(event.bankAccountId);
      final accounts = await getBankAccounts();
      emit(BankAccountLoaded(accounts, successMessage: 'Cuenta eliminada'));
    } catch (e) {
      emit(BankAccountError(_messageFrom(e), accounts: current));
    }
  }

  String _messageFrom(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}
