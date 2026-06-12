part of 'send_bloc.dart';

abstract class SendEvent extends Equatable {
  const SendEvent();

  @override
  List<Object?> get props => [];
}

class LoadContacts extends SendEvent {
  const LoadContacts();
}
