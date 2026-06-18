import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/contact.dart';
import '../../domain/usecases/get_contacts.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final GetContacts getContacts;

  SendBloc({required this.getContacts}) : super(const SendInitial()) {
    on<SearchContacts>(_onSearchContacts);
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
      emit(SendError(e.toString()));
    }
  }
}
