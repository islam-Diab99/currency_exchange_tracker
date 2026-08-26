import 'package:axis_assessment/core/api_constants.dart';
import 'package:axis_assessment/core/network/api_client.dart';
import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';

abstract interface class RatesRemoteDataSource {
  Future<RatesResponseModel> getLatestRates();
  Future<RatesResponseModel> getRatesForDate(DateTime date);
}

class RatesRemoteDataSourceImpl implements RatesRemoteDataSource {
  RatesRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<RatesResponseModel> getLatestRates() =>
      _fetch('${ApiConstants.latestBaseUrl}/${ApiConstants.ratesPath}');

  @override
  Future<RatesResponseModel> getRatesForDate(DateTime date) {
    final d = _format(date);
    return _fetch(
      '${ApiConstants.historicalBaseUrl(d)}/${ApiConstants.ratesPath}',
    );
  }

  // The client already maps transport/HTTP errors to AppException and guards an
  // empty body, so this just decodes the JSON into a model.
  Future<RatesResponseModel> _fetch(String url) async {
    final data = await _client.getJson(url);
    return RatesResponseModel.fromJson(data, base: ApiConstants.baseCurrency);
  }

  String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
