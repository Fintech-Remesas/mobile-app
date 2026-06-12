part of 'send_bloc.dart';

abstract class SendState extends Equatable {
  const SendState();

  @override
  List<Object?> get props => [];
}

class SendInitial extends SendState {
  const SendInitial();
}

class SendLoading extends SendState {
  const SendLoading();
}

class SendLoaded extends SendState {
  final List<Contact> contacts;

  const SendLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class SendError extends SendState {
  final String message;

  const SendError(this.message);

  @override
  List<Object?> get props => [message];
}
