part of 'rate_detail_bloc.dart';

enum RateDetailStatus { initial, loading, success, failure }

class RateDetailState extends Equatable {
  const RateDetailState({
    this.status = RateDetailStatus.initial,
    this.points = const [],
    this.errorMessage,
  });

  final RateDetailStatus status;
  final List<RatePoint> points;
  final String? errorMessage;

  bool get hasData => points.isNotEmpty;

  RateDetailState copyWith({
    RateDetailStatus? status,
    List<RatePoint>? points,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RateDetailState(
      status: status ?? this.status,
      points: points ?? this.points,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, points, errorMessage];
}
