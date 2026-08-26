import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/rates_snapshot.dart';
import '../model/cached_rates_model.dart';

abstract interface class RatesLocalDataSource {
  Future<void> cacheSnapshot(RatesSnapshot snapshot);

  /// Reads the last cached snapshot. Throws [CacheException] if empty/unreadable.
  Future<RatesSnapshot> getCachedSnapshot();

  bool get hasCache;
}

class RatesLocalDataSourceImpl implements RatesLocalDataSource {
  RatesLocalDataSourceImpl(this._box);

  static const String boxName = 'rates_cache';
  static const String _key = 'latest_snapshot';

  final Box<dynamic> _box;

  @override
  bool get hasCache => _box.containsKey(_key);

  @override
  Future<void> cacheSnapshot(RatesSnapshot snapshot) =>
      _box.put(_key, CachedRatesModel.fromSnapshot(snapshot).toMap());

  @override
  Future<RatesSnapshot> getCachedSnapshot() async {
    final raw = _box.get(_key);
    if (raw is! Map) throw const CacheException();
    return CachedRatesModel.fromMap(raw).toSnapshot();
  }
}
