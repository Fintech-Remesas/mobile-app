part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class NotificationsLoaded extends SettingsState {
  final List<AppNotification> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class LimitsLoaded extends SettingsState {
  final TransferLimits limits;

  const LimitsLoaded(this.limits);

  @override
  List<Object?> get props => [limits];
}

class SecurityLoaded extends SettingsState {
  final bool biometricEnabled;

  const SecurityLoaded({required this.biometricEnabled});

  @override
  List<Object?> get props => [biometricEnabled];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
