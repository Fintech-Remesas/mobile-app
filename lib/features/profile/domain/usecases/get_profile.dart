import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<UserProfile> call(NoParams params) => repository.getProfile();
}
