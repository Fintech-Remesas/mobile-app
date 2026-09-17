import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_detail.dart';
import '../../domain/usecases/get_transaction_detail.dart';
import '../../domain/usecases/get_traceability_metrics.dart';
import '../../domain/entities/traceability_metrics.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final GetTransactionDetail getTransactionDetail;
  final GetTraceabilityMetrics getTraceabilityMetrics;

  TransactionDetailBloc({
    required this.getTransactionDetail,
    required this.getTraceabilityMetrics,
  }) : super(const TransactionDetailInitial()) {
    on<LoadTransactionDetail>(_onLoad);
    on<LoadTraceabilityMetrics>(_onLoadMetrics);
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
      
      // Auto-load metrics if it's a crypto transaction (e.g. has a transaction hash or is outgoing)
      // We will try loading it based on the detail's ID since remittanceId is tied to it.
      add(LoadTraceabilityMetrics(detail.id));
      
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }

  Future<void> _onLoadMetrics(
    LoadTraceabilityMetrics event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransactionDetailLoaded) {
      try {
        final metrics = await getTraceabilityMetrics(
          GetTraceabilityMetricsParams(remittanceId: event.remittanceId),
        );
        emit(currentState.copyWith(traceabilityMetrics: metrics));
      } catch (e) {
        // If it fails (e.g. not a blockchain remittance, we just ignore and don't show the button)
        // print('Could not load metrics: $e');
      }
    }
  }
}
