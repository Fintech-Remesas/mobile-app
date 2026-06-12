import '../../../../core/usecases/usecase.dart';
import '../entities/contact.dart';
import '../repositories/transaction_repository.dart';

class GetContacts implements UseCase<List<Contact>, NoParams> {
  final TransactionRepository repository;

  GetContacts(this.repository);

  @override
  Future<List<Contact>> call(NoParams params) => repository.getContacts();
}
