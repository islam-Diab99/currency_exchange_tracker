import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/core/usecases/usecase.dart';
import 'package:axis_assessment/features/rates/data/datasources/rates_local_data_source.dart';
import 'package:axis_assessment/features/rates/data/datasources/rates_remote_data_source.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_latest_rates.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_rate_history.dart';
import 'package:mocktail/mocktail.dart';

class MockRatesRemoteDataSource extends Mock
    implements RatesRemoteDataSource {}

class MockRatesLocalDataSource extends Mock implements RatesLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockGetLatestRates extends Mock implements GetLatestRates {}

class MockGetRateHistory extends Mock implements GetRateHistory {}

/// Registers fallback values for the custom types passed to `any()`. Call once
/// from `setUpAll` before stubbing/verifying methods that take these.
void registerTestFallbacks() {
  registerFallbackValue(
    RatesSnapshot(rates: const [], lastUpdated: DateTime(2026)),
  );
  registerFallbackValue(DateTime(2026));
  registerFallbackValue(const NoParams());
  registerFallbackValue(const RateHistoryParams(currencyCode: 'usd'));
}
