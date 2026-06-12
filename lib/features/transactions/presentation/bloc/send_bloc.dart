import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/get_contacts.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final GetContacts getContacts;

  SendBloc({required this.getContacts}) : super(const SendInitial()) {
    on<LoadContacts>(_onLoadContacts);
  }

  Future<void> _onLoadContacts(LoadContacts event, Emitter<SendState> emit) async {
    emit(const SendLoading());
    try {
      final contacts = await getContacts(const NoParams());
      emit(SendLoaded(contacts));
    } catch (e) {
      emit(SendError(e.toString()));
    }
  }
}
