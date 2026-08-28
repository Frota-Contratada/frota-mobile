import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/tracked_position.dart';

class TripPositionBuffer {
  static const _prefix = 'trip_tracking_positions_';
  static const maxItems = 500;
  final SharedPreferences preferences;

  TripPositionBuffer(this.preferences);

  Future<void> add(String tripId, TrackedPosition position) async {
    final positions = await read(tripId);
    positions.add(position);
    positions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final bounded = positions.length > maxItems
        ? positions.sublist(positions.length - maxItems)
        : positions;
    await preferences.setString(
      '$_prefix$tripId',
      jsonEncode(bounded.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<TrackedPosition>> read(String tripId) async {
    final raw = preferences.getString('$_prefix$tripId');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TrackedPosition.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Object {
      await clear(tripId);
      return [];
    }
  }

  Future<void> clear(String tripId) => preferences.remove('$_prefix$tripId');
}
