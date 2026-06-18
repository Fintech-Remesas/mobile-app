part of 'kyc_bloc.dart';

abstract class KycEvent extends Equatable {
  const KycEvent();

  @override
  List<Object?> get props => [];
}

class SubmitKycRequested extends KycEvent {
  const SubmitKycRequested();
}

class CheckKycStatusRequested extends KycEvent {
  const CheckKycStatusRequested();
}
