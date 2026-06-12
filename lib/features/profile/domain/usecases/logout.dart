import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class Logout implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  Logout(this.repository);

  @override
  Future<void> call(NoParams params) => repository.logout();
}
