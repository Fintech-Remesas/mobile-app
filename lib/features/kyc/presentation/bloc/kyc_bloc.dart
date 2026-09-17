import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../domain/entities/kyc_status.dart';
import '../../domain/usecases/check_kyc_status.dart';
import '../../domain/usecases/submit_kyc.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final SubmitKyc submitKyc;
  final CheckKycStatus checkKycStatus;
  final KycRepositoryImpl repository;

  KycBloc({
    required this.submitKyc,
    required this.checkKycStatus,
    required this.repository,
  }) : super(const KycInitial()) {
    on<SubmitKycRequested>(_onSubmitKyc);
    on<CheckKycStatusRequested>(_onCheckKycStatus);
    on<SimulateKycApproval>(_onSimulateApproval);
    on<SimulateKycRejection>(_onSimulateRejection);
  }

  Future<void> _onSubmitKyc(
    SubmitKycRequested event,
    Emitter<KycState> emit,
  ) async {
    emit(const KycLoading());
    try {
      // Simula el tiempo de validación biométrica/documental
      await Future.delayed(const Duration(seconds: 5));
      await submitKyc(const NoParams());
      emit(const KycSubmitted());
      emit(const KycStatusLoaded(KycStatus.approved));
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

  void _onSimulateApproval(SimulateKycApproval event, Emitter<KycState> emit) {
    repository.simulateApproval();
    emit(const KycStatusLoaded(KycStatus.approved));
  }

  void _onSimulateRejection(SimulateKycRejection event, Emitter<KycState> emit) {
    repository.simulateRejection();
    emit(const KycStatusLoaded(KycStatus.rejected));
  }
}
