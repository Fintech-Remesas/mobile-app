part of 'send_bloc.dart';

abstract class SendEvent extends Equatable {
  const SendEvent();

  @override
  List<Object?> get props => [];
}

class SearchContacts extends SendEvent {
  final String query;

  const SearchContacts(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectRecipient extends SendEvent {
  final Contact contact;

  const SelectRecipient(this.contact);

  @override
  List<Object?> get props => [contact];
}

class ClearRecipient extends SendEvent {
  const ClearRecipient();
}

class RequestQuote extends SendEvent {
  final Contact contact;
  final double amount;
  final RemittanceDestination destination;

  const RequestQuote({
    required this.contact,
    required this.amount,
    required this.destination,
  });

  @override
  List<Object?> get props => [contact, amount, destination];
}

class ConfirmSend extends SendEvent {
  final Contact contact;
  final Quote quote;
  final RemittanceDestination destination;

  const ConfirmSend({
    required this.contact,
    required this.quote,
    required this.destination,
  });

  @override
  List<Object?> get props => [contact, quote, destination];
}
