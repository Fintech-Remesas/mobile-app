import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_detail.dart';
import '../../domain/usecases/get_transaction_detail.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final GetTransactionDetail getTransactionDetail;

  TransactionDetailBloc({required this.getTransactionDetail})
      : super(const TransactionDetailInitial()) {
    on<LoadTransactionDetail>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(const TransactionDetailLoading());
    try {
      final detail = await getTransactionDetail(
        GetTransactionDetailParams(id: event.id),
      );
      emit(TransactionDetailLoaded(detail));
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }
}
