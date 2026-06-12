import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/settings_repository.dart';

class GetNotifications implements UseCase<List<AppNotification>, NoParams> {
  final SettingsRepository repository;

  GetNotifications(this.repository);

  @override
  Future<List<AppNotification>> call(NoParams params) {
    return repository.getNotifications();
  }
}
