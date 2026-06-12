part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends SettingsEvent {
  const LoadNotifications();
}

class LoadLimits extends SettingsEvent {
  const LoadLimits();
}

class LoadSecuritySettings extends SettingsEvent {
  const LoadSecuritySettings();
}

class ToggleBiometricRequested extends SettingsEvent {
  final bool enabled;

  const ToggleBiometricRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
