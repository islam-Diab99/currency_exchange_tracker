import 'package:axis_assessment/core/network/dio_client.dart';
import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/features/rates/data/datasources/rates_local_data_source.dart';
import 'package:axis_assessment/features/rates/data/datasources/rates_remote_data_source.dart';
import 'package:axis_assessment/features/rates/data/repository/rates_repository_impl.dart';
import 'package:axis_assessment/features/rates/domain/repositories/rates_repository.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_latest_rates.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_rate_history.dart';
import 'package:axis_assessment/features/rates/presentation/bloc/rate_detail/rate_detail_bloc.dart';
import 'package:axis_assessment/features/rates/presentation/bloc/rates_list_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<Dio>(DioClient.create)
    ..registerLazySingleton<InternetConnection>(InternetConnection.new);

  // --- Core ---
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Open the cache box once and register it for the local data source to use.
  final box = await Hive.openBox<dynamic>(RatesLocalDataSourceImpl.boxName);
  sl.registerSingleton<Box<dynamic>>(box);

  // --- Rates: data ---
  sl
    ..registerLazySingleton<RatesRemoteDataSource>(
      () => RatesRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RatesLocalDataSource>(
      () => RatesLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RatesRepository>(
      () => RatesRepositoryImpl(remote: sl(), local: sl(), network: sl()),
    );

  // --- Rates: domain ---
  sl
    ..registerLazySingleton(() => GetLatestRates(sl()))
    ..registerLazySingleton(() => GetRateHistory(sl()));

  // --- Rates: presentation ---
  sl
    ..registerFactory(
      () => RatesListBloc(getLatestRates: sl(), networkInfo: sl()),
    )
    ..registerFactory(() => RateDetailBloc(getRateHistory: sl()));
}
