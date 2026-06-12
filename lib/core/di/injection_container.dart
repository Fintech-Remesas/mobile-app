import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_transaction_history.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_recent_transactions.dart';
import '../../features/home/domain/usecases/get_wallet_summary.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/kyc/data/datasources/kyc_local_datasource.dart';
import '../../features/kyc/data/repositories/kyc_repository_impl.dart';
import '../../features/kyc/domain/repositories/kyc_repository.dart';
import '../../features/kyc/domain/usecases/check_kyc_status.dart';
import '../../features/kyc/domain/usecases/submit_kyc.dart';
import '../../features/kyc/presentation/bloc/kyc_bloc.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/logout.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_biometric_enabled.dart';
import '../../features/settings/domain/usecases/get_limits.dart';
import '../../features/settings/domain/usecases/get_notifications.dart';
import '../../features/settings/domain/usecases/toggle_biometric.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/get_contacts.dart';
import '../../features/transactions/domain/usecases/get_transaction_detail.dart';
import '../../features/transactions/presentation/bloc/send_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_detail_bloc.dart';
import '../data/mock_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => MockDataSource());

  // Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerFactory(
    () => AuthBloc(login: sl(), registerUser: sl(), verifyOtp: sl()),
  );

  // KYC
  sl.registerLazySingleton<KycLocalDataSourceImpl>(
    () => KycLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<KycRepositoryImpl>(
    () => KycRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<KycRepository>(() => sl<KycRepositoryImpl>());
  sl.registerLazySingleton(() => SubmitKyc(sl()));
  sl.registerLazySingleton(() => CheckKycStatus(sl()));
  sl.registerFactory(
    () => KycBloc(
      submitKyc: sl(),
      checkKycStatus: sl(),
      repository: sl<KycRepositoryImpl>(),
    ),
  );

  // Home
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWalletSummary(sl()));
  sl.registerLazySingleton(() => GetRecentTransactions(sl()));
  sl.registerFactory(
    () => HomeBloc(
      getWalletSummary: sl(),
      getRecentTransactions: sl(),
    )..add(const LoadHome()),
  );

  // Transactions
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetContacts(sl()));
  sl.registerLazySingleton(() => GetTransactionDetail(sl()));
  sl.registerFactory(
    () => SendBloc(getContacts: sl())..add(const LoadContacts()),
  );
  sl.registerFactory(() => TransactionDetailBloc(getTransactionDetail: sl()));

  // History
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetTransactionHistory(sl()));
  sl.registerFactory(
    () => HistoryBloc(getTransactionHistory: sl())..add(const LoadHistory()),
  );

  // Profile
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerFactory(
    () => ProfileBloc(getProfile: sl(), logout: sl())..add(const LoadProfile()),
  );

  // Settings
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetLimits(sl()));
  sl.registerLazySingleton(() => GetBiometricEnabled(sl()));
  sl.registerLazySingleton(() => ToggleBiometric(sl()));
  sl.registerFactory(() => SettingsBloc(
        getNotifications: sl(),
        getLimits: sl(),
        getBiometricEnabled: sl(),
        toggleBiometric: sl(),
      ));
}
