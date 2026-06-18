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
