import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/remittance_remote_datasource.dart';
import '../../../../core/network/remittance_status_socket.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/usecases/get_transaction_detail.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final GetTransactionDetail getTransactionDetail;
  final RemittanceRemoteDataSource remittanceDataSource;
  final RemittanceStatusSocketService statusSocket;
  Timer? _pollTimer;
  int _timelineRetries = 0;
  String? _currentId;

  TransactionDetailBloc({
    required this.getTransactionDetail,
    required this.remittanceDataSource,
    required this.statusSocket,
  }) : super(const TransactionDetailInitial()) {
    on<LoadTransactionDetail>(_onLoad);
    on<RefreshTransactionDetail>(_onRefresh);
    on<_PollTick>(_onPollTick);
    on<_SocketStatusReceived>(_onSocketStatus);
  }

  Future<void> _onLoad(
    LoadTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    _timelineRetries = 0;
    _currentId = event.id;
    await _connectSocket(event.id);
    await _loadDetail(event.id, emit, showLoading: true);
  }

  Future<void> _onRefresh(
    RefreshTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final current = state;
    if (current is TransactionDetailLoaded) {
      await _loadDetail(current.detail.id, emit, showLoading: false);
    }
  }

  Future<void> _onPollTick(
    _PollTick event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final current = state;
    if (current is! TransactionDetailLoaded) return;
    await _loadDetail(current.detail.id, emit, showLoading: false);
  }

  void _onSocketStatus(
    _SocketStatusReceived event,
    Emitter<TransactionDetailState> emit,
  ) {
    if (_currentId == null || event.remittanceId != _currentId) return;
    add(const _PollTick());
  }

  Future<void> _connectSocket(String remittanceId) async {
    statusSocket.watchRemittance(remittanceId);
    await statusSocket.connect(
      onStatusUpdate: (update) {
        if (!isClosed) {
          add(_SocketStatusReceived(
            remittanceId: update.remittanceId,
            status: update.status,
          ));
        }
      },
    );
  }

  Future<void> _loadDetail(
    String id,
    Emitter<TransactionDetailState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) emit(const TransactionDetailLoading());
    try {
      var detail = await getTransactionDetail(GetTransactionDetailParams(id: id));

      final isTerminal = detail.status.toUpperCase() == 'COMPLETED' ||
          detail.status.toUpperCase() == 'FAILED' ||
          detail.status.toUpperCase() == 'CANCELLED';

      if (!isTerminal &&
          detail.timelineSteps.isEmpty &&
          _timelineRetries < 12) {
        _timelineRetries++;
        _schedulePoll(const Duration(seconds: 5));
      } else if (!isTerminal &&
          detail.hasTransactionHash &&
          detail.confirmationStatus != 'confirmed' &&
          detail.confirmationStatus != 'failed') {
        final status = await remittanceDataSource.fetchTxStatus(
          detail.transactionHash!,
        );
        if (status != null) {
          detail = TransactionDetail(
            id: detail.id,
            amount: detail.amount,
            status: detail.status,
            statusLabel: detail.statusLabel,
            recipient: detail.recipient,
            transactionHash: detail.transactionHash,
            network: detail.network,
            blockNumber: detail.blockNumber,
            confirmationStatus: status.status,
            blockTimestamp: detail.blockTimestamp,
            polygonscanUrl: detail.polygonscanUrl,
            depositCode: detail.depositCode,
            amountSourceCurrency: detail.amountSourceCurrency,
            errorMessage: detail.errorMessage,
            timelineSteps: detail.timelineSteps,
            isPolling: true,
          );
          if (status.status != 'confirmed' && status.status != 'failed') {
            _schedulePoll(const Duration(seconds: 10));
          }
        }
      } else if (!isTerminal && !statusSocket.isConnected) {
        _schedulePoll(const Duration(seconds: 10));
      }

      emit(TransactionDetailLoaded(detail));
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }

  void _schedulePoll(Duration delay) {
    _pollTimer?.cancel();
    _pollTimer = Timer(delay, () {
      if (!isClosed) add(const _PollTick());
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    statusSocket.disconnect();
    return super.close();
  }
}

class _PollTick extends TransactionDetailEvent {
  const _PollTick();
}

class _SocketStatusReceived extends TransactionDetailEvent {
  final String remittanceId;
  final String status;

  const _SocketStatusReceived({
    required this.remittanceId,
    required this.status,
  });

  @override
  List<Object?> get props => [remittanceId, status];
}
