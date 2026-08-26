import 'package:equatable/equatable.dart';

/// One (date, rate) sample for the chart. [rate] is EGP per one foreign unit.
class RatePoint extends Equatable {
  const RatePoint({required this.date, required this.rate});

  final DateTime date;
  final double rate;

  @override
  List<Object?> get props => [date, rate];
}
