import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_refresh_notifier.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/kyc_status.dart';
import '../../domain/usecases/check_kyc_status.dart';
import '../../domain/usecases/submit_kyc.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final SubmitKyc submitKyc;
  final CheckKycStatus checkKycStatus;

  KycBloc({
    required this.submitKyc,
    required this.checkKycStatus,
  }) : super(const KycInitial()) {
    on<SubmitKycRequested>(_onSubmitKyc);
    on<CheckKycStatusRequested>(_onCheckKycStatus);
  }

  Future<void> _onSubmitKyc(
    SubmitKycRequested event,
    Emitter<KycState> emit,
  ) async {
    emit(const KycLoading());
    try {
      await submitKyc(const NoParams());
      sl<AuthRefreshNotifier>().notifyAuthChanged();
      emit(const KycSubmitted());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  Future<void> _onCheckKycStatus(
    CheckKycStatusRequested event,
    Emitter<KycState> emit,
  ) async {
    emit(const KycLoading());
    try {
      final status = await checkKycStatus(const NoParams());
      emit(KycStatusLoaded(status));
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }
}
