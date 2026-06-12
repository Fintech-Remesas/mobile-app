part of 'kyc_bloc.dart';

abstract class KycState extends Equatable {
  const KycState();

  @override
  List<Object?> get props => [];
}

class KycInitial extends KycState {
  const KycInitial();
}

class KycLoading extends KycState {
  const KycLoading();
}

class KycSubmitted extends KycState {
  const KycSubmitted();
}

class KycStatusLoaded extends KycState {
  final KycStatus status;

  const KycStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class KycError extends KycState {
  final String message;

  const KycError(this.message);

  @override
  List<Object?> get props => [message];
}
