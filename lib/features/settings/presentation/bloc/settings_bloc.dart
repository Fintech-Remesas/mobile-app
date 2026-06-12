import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/transfer_limits.dart';
import '../../domain/usecases/get_biometric_enabled.dart';
import '../../domain/usecases/get_limits.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/toggle_biometric.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetNotifications getNotifications;
  final GetLimits getLimits;
  final GetBiometricEnabled getBiometricEnabled;
  final ToggleBiometric toggleBiometric;

  SettingsBloc({
    required this.getNotifications,
    required this.getLimits,
    required this.getBiometricEnabled,
    required this.toggleBiometric,
  }) : super(const SettingsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadLimits>(_onLoadLimits);
    on<LoadSecuritySettings>(_onLoadSecurity);
    on<ToggleBiometricRequested>(_onToggleBiometric);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final notifications = await getNotifications(const NoParams());
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onLoadLimits(LoadLimits event, Emitter<SettingsState> emit) async {
    emit(const SettingsLoading());
    try {
      final limits = await getLimits(const NoParams());
      emit(LimitsLoaded(limits));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onLoadSecurity(
    LoadSecuritySettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final enabled = await getBiometricEnabled(const NoParams());
      emit(SecurityLoaded(biometricEnabled: enabled));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleBiometric(
    ToggleBiometricRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await toggleBiometric(ToggleBiometricParams(enabled: event.enabled));
      emit(SecurityLoaded(biometricEnabled: event.enabled));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
