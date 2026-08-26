import 'package:axis_assessment/core/network/dio_client.dart';
import 'package:axis_assessment/core/network/network_info.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl..registerLazySingleton<Dio>(DioClient.create)
    ..registerLazySingleton<InternetConnection>(InternetConnection.new);

  // --- Core ---
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));


 
}
