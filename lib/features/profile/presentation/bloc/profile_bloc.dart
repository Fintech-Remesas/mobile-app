import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/logout.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final Logout logout;

  ProfileBloc({required this.getProfile, required this.logout})
      : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final profile = await getProfile(const NoParams());
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<ProfileState> emit) async {
    try {
      await logout(const NoParams());
      emit(const ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
