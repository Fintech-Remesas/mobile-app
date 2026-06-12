import '../repositories/settings_repository.dart';

class ToggleBiometricParams {
  final bool enabled;

  const ToggleBiometricParams({required this.enabled});
}

class ToggleBiometric {
  final SettingsRepository repository;

  ToggleBiometric(this.repository);

  Future<void> call(ToggleBiometricParams params) {
    return repository.toggleBiometric(params.enabled);
  }
}
