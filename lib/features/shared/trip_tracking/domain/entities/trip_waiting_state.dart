import 'package:equatable/equatable.dart';

class TripWaitingState extends Equatable {
  final bool active;
  final DateTime? startedAt;

  const TripWaitingState({required this.active, this.startedAt});

  const TripWaitingState.inactive() : active = false, startedAt = null;

  factory TripWaitingState.fromJson(Map<String, dynamic> json) =>
      TripWaitingState(
        active: json['active'] as bool? ?? false,
        startedAt: json['startedAt'] == null
            ? null
            : DateTime.parse(json['startedAt'] as String).toUtc(),
      );

  Map<String, dynamic> toJson() => {
    'active': active,
    'startedAt': startedAt?.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [active, startedAt];
}
