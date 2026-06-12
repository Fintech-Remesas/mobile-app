import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_summary.dart';
import '../repositories/home_repository.dart';

class GetWalletSummary implements UseCase<WalletSummary, NoParams> {
  final HomeRepository repository;

  GetWalletSummary(this.repository);

  @override
  Future<WalletSummary> call(NoParams params) {
    return repository.getWalletSummary();
  }
}
