import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../domain/usecases/deposit_funds.dart';
import 'crypto_deposit_event.dart';
import 'crypto_deposit_state.dart';

class CryptoDepositBloc extends Bloc<CryptoDepositEvent, CryptoDepositState> {
  final DepositFunds depositFunds;
  Timer? _timer;
  
  CryptoDepositBloc({required this.depositFunds}) : super(CryptoDepositInitial()) {
    on<FetchCryptoQuote>(_onFetchCryptoQuote);
    on<TimerTicked>(_onTimerTicked);
    on<SubmitCryptoDeposit>(_onSubmitCryptoDeposit);
  }

  Future<void> _onFetchCryptoQuote(
    FetchCryptoQuote event,
    Emitter<CryptoDepositState> emit,
  ) async {
    emit(CryptoDepositLoadingQuote());
    _timer?.cancel();
    
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=${event.cryptoId}&vs_currencies=usd'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[event.cryptoId] != null && data[event.cryptoId]['usd'] != null) {
          final priceUsd = (data[event.cryptoId]['usd'] as num).toDouble();
          final usdEquivalent = priceUsd * event.cryptoAmount;
          
          emit(CryptoDepositQuoteReady(
            cryptoId: event.cryptoId,
            cryptoAmount: event.cryptoAmount,
            usdEquivalent: usdEquivalent,
            secondsRemaining: 60,
          ));
          
          _startTimer();
        } else {
          emit(const CryptoDepositFailure('No se encontró el precio de la criptomoneda.'));
        }
      } else {
        emit(const CryptoDepositFailure('Error al obtener el precio. Intenta más tarde.'));
      }
    } catch (e) {
      emit(CryptoDepositFailure('Error de red al consultar el precio: $e'));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is CryptoDepositQuoteReady) {
        final currentState = state as CryptoDepositQuoteReady;
        if (currentState.secondsRemaining > 0) {
          add(TimerTicked(currentState.secondsRemaining - 1));
        } else {
          timer.cancel();
          // Cuando llega a 0, TimerTicked manejará el paso a Expired
          add(const TimerTicked(0));
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _onTimerTicked(
    TimerTicked event,
    Emitter<CryptoDepositState> emit,
  ) {
    if (state is CryptoDepositQuoteReady) {
      final currentState = state as CryptoDepositQuoteReady;
      if (event.secondsRemaining > 0) {
        emit(CryptoDepositQuoteReady(
          cryptoId: currentState.cryptoId,
          cryptoAmount: currentState.cryptoAmount,
          usdEquivalent: currentState.usdEquivalent,
          secondsRemaining: event.secondsRemaining,
        ));
      } else {
        emit(CryptoDepositQuoteExpired());
      }
    }
  }

  Future<void> _onSubmitCryptoDeposit(
    SubmitCryptoDeposit event,
    Emitter<CryptoDepositState> emit,
  ) async {
    _timer?.cancel();
    emit(CryptoDepositSubmitting());
    
    try {
      final desc = 'Crypto Deposit: ${event.cryptoAmount} ${event.cryptoId.toUpperCase()} (~\$${event.usdEquivalent.toStringAsFixed(2)})';
      
      await depositFunds(DepositFundsParams(
        amount: event.usdEquivalent,
        currency: 'USDC',
        cardId: 'crypto_${event.cryptoId}_${DateTime.now().millisecondsSinceEpoch}',
        description: desc,
      ));
      
      emit(CryptoDepositSuccess());
    } catch (e) {
      emit(CryptoDepositFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
