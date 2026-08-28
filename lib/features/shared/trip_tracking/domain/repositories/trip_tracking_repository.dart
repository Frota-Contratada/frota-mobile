import '../../data/dtos/trip_bridge_message.dart';
import '../entities/canonical_route.dart';
import '../entities/tracked_position.dart';
import '../entities/trip_tracking_snapshot.dart';
import '../entities/trip_waiting_state.dart';

abstract class TripTrackingRepository {
  Stream<TripBridgeMessage> get events;
  Stream<bool> get connectionChanges;

  Future<TripTrackingSnapshot> loadSnapshot(String tripId, TripRole role);
  Future<void> connect(String tripId, TripRole role);
  Future<void> disconnect();
  Future<void> publishVehiclePosition(String tripId, TrackedPosition position);
  Future<void> publishPassengerPosition(
    String tripId,
    TrackedPosition position,
  );
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  );
  Future<TripWaitingState> confirmWaiting(String tripId, String commandEventId);
  Future<TripWaitingState> resumeWaiting(String tripId, String commandEventId);
  Future<void> finishTrip(String tripId, String commandEventId);
  Future<void> flushOfflinePositions(String tripId);
  Future<void> clearTrip(String tripId);
}
