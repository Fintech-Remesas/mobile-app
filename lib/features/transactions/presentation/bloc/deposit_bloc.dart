import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/remittance.dart';
import '../../domain/usecases/confirm_deposit.dart';
import '../../domain/usecases/get_remittance.dart';

part 'deposit_event.dart';
part 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final GetRemittance getRemittance;
  final ConfirmDeposit confirmDeposit;

  DepositBloc({
    required this.getRemittance,
    required this.confirmDeposit,
  }) : super(const DepositInitial()) {
    on<LoadDeposit>(_onLoad);
    on<ConfirmDepositRequested>(_onConfirm);
  }

  Future<void> _onLoad(LoadDeposit event, Emitter<DepositState> emit) async {
    emit(const DepositLoading());
    try {
      final remittance = await getRemittance(GetRemittanceParams(id: event.id));
      emit(DepositLoaded(remittance));
    } catch (e) {
      emit(DepositError(_messageFrom(e)));
    }
  }

  Future<void> _onConfirm(
    ConfirmDepositRequested event,
    Emitter<DepositState> emit,
  ) async {
    final current = state;
    if (current is! DepositLoaded) return;

    emit(DepositConfirming(current.remittance));
    try {
      await confirmDeposit(ConfirmDepositParams(remittanceId: event.id));
      final remittance = await getRemittance(GetRemittanceParams(id: event.id));
      emit(DepositConfirmed(remittance));
    } catch (e) {
      emit(DepositLoaded(current.remittance, errorMessage: _messageFrom(e)));
    }
  }

  String _messageFrom(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}
