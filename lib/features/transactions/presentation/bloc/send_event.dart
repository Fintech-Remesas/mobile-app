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

class SubmitSend extends SendEvent {
  final double amount;

  const SubmitSend(this.amount);

  @override
  List<Object?> get props => [amount];
}
