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

class SendQuoting extends SendState {
  final Contact contact;
  final double amount;
  final RemittanceDestination destination;

  const SendQuoting(this.contact, this.amount, this.destination);

  @override
  List<Object?> get props => [contact, amount, destination];
}

class SendQuoteReady extends SendState {
  final Contact contact;
  final Quote quote;
  final RemittanceDestination destination;
  final String? errorMessage;

  const SendQuoteReady(
    this.contact,
    this.quote,
    this.destination, {
    this.errorMessage,
  });

  @override
  List<Object?> get props => [contact, quote, destination, errorMessage];
}

class SendSubmitting extends SendState {
  final Contact contact;
  final Quote quote;
  final RemittanceDestination destination;

  const SendSubmitting(this.contact, this.quote, this.destination);

  @override
  List<Object?> get props => [contact, quote, destination];
}

class SendSuccess extends SendState {
  final String remittanceId;
  final Contact contact;
  final Remittance remittance;

  const SendSuccess(this.remittanceId, this.contact, this.remittance);

  @override
  List<Object?> get props => [remittanceId, contact, remittance];
}

class SendError extends SendState {
  final String message;
  final Contact? contact;

  const SendError(this.message, {this.contact});

  @override
  List<Object?> get props => [message, contact];
}
