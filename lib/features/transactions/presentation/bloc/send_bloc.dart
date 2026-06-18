import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/send_remittance.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final GetContacts getContacts;
  final SendRemittance sendRemittance;

  SendBloc({
    required this.getContacts,
    required this.sendRemittance,
  }) : super(const SendInitial()) {
    on<SearchContacts>(_onSearchContacts);
    on<SelectRecipient>(_onSelectRecipient);
    on<ClearRecipient>(_onClearRecipient);
    on<SubmitSend>(_onSubmitSend);
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

  Contact? _contactFromState(SendState state) {
    if (state is SendRecipientSelected) return state.contact;
    if (state is SendSubmitting) return state.contact;
    if (state is SendError && state.contact != null) return state.contact;
    return null;
  }

  Future<void> _onSubmitSend(
    SubmitSend event,
    Emitter<SendState> emit,
  ) async {
    final contact = _contactFromState(state);
    if (contact == null) return;

    if (event.amount <= 0) {
      emit(SendError('Ingresa un monto mayor a 0', contact: contact));
      return;
    }

    emit(SendSubmitting(contact, event.amount));
    try {
      final remittanceId = await sendRemittance(
        SendRemittanceParams(
          recipient: contact,
          amount: event.amount,
        ),
      );
      emit(SendSuccess(remittanceId, contact));
    } catch (e) {
      emit(SendError(_messageFrom(e), contact: contact));
    }
  }

  String _messageFrom(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}
