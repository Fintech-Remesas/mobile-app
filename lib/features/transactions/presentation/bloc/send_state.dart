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

class SendRecipientSelected extends SendState {
  final Contact contact;

  const SendRecipientSelected(this.contact);

  @override
  List<Object?> get props => [contact];
}

class SendSubmitting extends SendState {
  final Contact contact;
  final double amount;

  const SendSubmitting(this.contact, this.amount);

  @override
  List<Object?> get props => [contact, amount];
}

class SendSuccess extends SendState {
  final String remittanceId;
  final Contact contact;

  const SendSuccess(this.remittanceId, this.contact);

  @override
  List<Object?> get props => [remittanceId, contact];
}

class SendError extends SendState {
  final String message;
  final Contact? contact;

  const SendError(this.message, {this.contact});

  @override
  List<Object?> get props => [message, contact];
}
