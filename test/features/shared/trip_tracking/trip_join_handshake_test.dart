import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/datasources/trip_tracking_socket_datasource.dart';

void main() {
  test('não confirma a entrada antes de trip.joined', () async {
    final handshake = TripJoinHandshake('trip-123');
    var completed = false;
    handshake.firstConfirmation.then((_) => completed = true);

    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    expect(handshake.confirmEvent({'tripId': 'outra-corrida'}), isFalse);
    expect(completed, isFalse);

    expect(handshake.confirmEvent({'tripId': 'trip-123'}), isTrue);
    await handshake.firstConfirmation;
    expect(completed, isTrue);
    expect(handshake.joined, isTrue);
  });

  test('aceita acknowledgement válido e rejeita falha', () async {
    final failed = TripJoinHandshake('trip-123');
    expect(failed.confirmAcknowledgement({'success': false}), isFalse);
    expect(failed.joined, isFalse);

    final confirmed = TripJoinHandshake('trip-123');
    expect(confirmed.confirmAcknowledgement(null), isTrue);
    await confirmed.firstConfirmation;
    expect(confirmed.joined, isTrue);
  });

  test('exige nova confirmação depois de reconectar', () {
    final handshake = TripJoinHandshake('trip-123');
    expect(handshake.confirmEvent({'tripId': 'trip-123'}), isTrue);
    handshake.reset();
    expect(handshake.joined, isFalse);
    expect(handshake.confirmEvent({'tripId': 'trip-123'}), isTrue);
  });
}
