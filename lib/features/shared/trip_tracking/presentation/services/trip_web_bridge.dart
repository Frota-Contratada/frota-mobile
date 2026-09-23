import 'dart:async';
import '../../data/dtos/trip_bridge_message.dart';

typedef JavaScriptRunner = Future<void> Function(String script);

class TripWebBridge {
  final String tripId;
  final JavaScriptRunner runJavaScript;
  final List<TripBridgeMessage> _pending = [];
  final _incoming = StreamController<TripBridgeMessage>.broadcast();
  bool _ready = false;
  bool _disposed = false;

  TripWebBridge({required this.tripId, required this.runJavaScript});

  bool get isReady => _ready;
  Stream<TripBridgeMessage> get messages => _incoming.stream;

  Future<void> handleJavaScriptMessage(String raw) async {
    if (_disposed) return;
    final message = TripBridgeMessage.decode(
      raw,
      expectedTripId: tripId,
      allowedTypes: TripMessageType.fromWeb,
    );
    if (message.type == TripMessageType.webReady) {
      _ready = true;
      await _flush();
    }
    _incoming.add(message);
  }

  Future<void> send(TripBridgeMessage message) async {
    if (_disposed) return;
    if (message.tripId != tripId ||
        !TripMessageType.fromFlutter.contains(message.type)) {
      throw ArgumentError('Mensagem Flutter → Web inválida.');
    }
    if (!_ready) {
      _pending.add(message);
      return;
    }
    await _deliver(message);
  }

  Future<void> resetForReload() async {
    _ready = false;
  }

  Future<void> _flush() async {
    final messages = List<TripBridgeMessage>.of(_pending);
    _pending.clear();
    for (final message in messages) {
      await _deliver(message);
    }
  }

  Future<void> _deliver(TripBridgeMessage message) {
    final encoded = message.encode();
    final jsLiteral = _escapeForJavaScript(encoded);
    return runJavaScript('''
      (() => {
        const message = JSON.parse('$jsLiteral');
        window.dispatchEvent(new CustomEvent('flutter.trip', { detail: message }));
        if (window.FrotaTripBridge && typeof window.FrotaTripBridge.onMessage === 'function') {
          window.FrotaTripBridge.onMessage(message);
        }
      })();
    ''');
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _pending.clear();
    await _incoming.close();
  }
}

String _escapeForJavaScript(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll('\u2028', r'\u2028')
    .replaceAll('\u2029', r'\u2029');
