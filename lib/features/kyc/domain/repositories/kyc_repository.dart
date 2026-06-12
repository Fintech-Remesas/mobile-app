import '../entities/kyc_status.dart';

abstract class KycRepository {
  Future<void> submitKyc();
  Future<KycStatus> checkKycStatus();
}
