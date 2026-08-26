import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  const Currency({required this.code, required this.name, required this.flag});

  /// ISO 4217 code, e.g. `USD`.
  final String code;

  final String name;

  final String flag;

  String get responseKey => code.toLowerCase();

  @override
  List<Object?> get props => [code, name, flag];
}
