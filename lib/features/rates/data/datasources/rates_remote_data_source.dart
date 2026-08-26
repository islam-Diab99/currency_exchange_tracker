import 'package:axis_assessment/core/api_constants.dart';
import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:dio/dio.dart';

abstract interface class RatesRemoteDataSource {
  Future<RatesResponseModel> getLatestRates();
  Future<RatesResponseModel> getRatesForDate(DateTime date);
}

class RatesRemoteDataSourceImpl implements RatesRemoteDataSource {
  RatesRemoteDataSourceImpl(this._dio);
  final Dio _dio;

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

  Future<RatesResponseModel> _fetch(String url) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(url);
      final data = res.data;
      if (data == null) throw const ParseException('Empty response');
      return RatesResponseModel.fromJson(data, base: ApiConstants.baseCurrency);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
