import '../entities/contact.dart';
import '../repositories/transaction_repository.dart';

class GetContactsParams {
  final String query;

  const GetContactsParams({required this.query});
}

class GetContacts {
  final TransactionRepository repository;

  GetContacts(this.repository);

  Future<List<Contact>> call(GetContactsParams params) {
    return repository.getContacts(params.query);
  }
}
