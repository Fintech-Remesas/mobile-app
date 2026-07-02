import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/remittance_destination.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/remittance.dart';
import '../../domain/usecases/create_quote.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/send_remittance.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final GetContacts getContacts;
  final CreateQuote createQuote;
  final SendRemittance sendRemittance;

  SendBloc({
    required this.getContacts,
    required this.createQuote,
    required this.sendRemittance,
  }) : super(const SendInitial()) {
    on<SearchContacts>(_onSearchContacts);
    on<SelectRecipient>(_onSelectRecipient);
    on<ClearRecipient>(_onClearRecipient);
    on<RequestQuote>(_onRequestQuote);
    on<ConfirmSend>(_onConfirmSend);
  }

  Future<void> _onSearchContacts(
    SearchContacts event,
    Emitter<SendState> emit,
  ) async {
    if (event.query.trim().length < 2) {
      emit(const SendLoaded([]));
      return;
    }

    emit(const SendLoading());
    try {
      final contacts = await getContacts(GetContactsParams(query: event.query));
      emit(SendLoaded(contacts));
    } catch (e) {
      emit(SendError(_messageFrom(e)));
    }
  }

  void _onSelectRecipient(SelectRecipient event, Emitter<SendState> emit) {
    emit(SendRecipientSelected(event.contact));
  }

  void _onClearRecipient(ClearRecipient event, Emitter<SendState> emit) {
    emit(const SendLoaded([]));
  }

  Future<void> _onRequestQuote(
    RequestQuote event,
    Emitter<SendState> emit,
  ) async {
    emit(SendQuoting(event.contact, event.amount, event.destination));
    try {
      final quote = await createQuote(CreateQuoteParams(amount: event.amount));
      emit(SendQuoteReady(event.contact, quote, event.destination));
    } catch (e) {
      emit(SendError(_messageFrom(e), contact: event.contact));
    }
  }

  Future<void> _onConfirmSend(
    ConfirmSend event,
    Emitter<SendState> emit,
  ) async {
    emit(SendSubmitting(event.contact, event.quote, event.destination));
    try {
      final remittance = await sendRemittance(
        SendRemittanceParams(
          recipient: event.contact,
          quote: event.quote,
          destination: event.destination,
        ),
      );
      emit(SendSuccess(remittance.id, event.contact, remittance));
    } catch (e) {
      emit(
        SendQuoteReady(event.contact, event.quote, event.destination,
            errorMessage: _messageFrom(e)),
      );
    }
  }

  String _messageFrom(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}
