import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../config/env.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../data/dtos/trip_bridge_message.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';
import '../bloc/trip_tracking_bloc.dart';
import '../services/trip_web_bridge.dart';

class TripWebViewArgs {
  final String tripId;
  final TripRole role;

  const TripWebViewArgs({required this.tripId, required this.role});
}

class TripWebViewPage extends StatelessWidget {
  final TripWebViewArgs args;

  const TripWebViewPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripTrackingBloc>()..start(args.tripId, args.role),
      child: _TripWebViewContent(args: args),
    );
  }
}

class _TripWebViewContent extends StatefulWidget {
  final TripWebViewArgs args;

  const _TripWebViewContent({required this.args});

  @override
  State<_TripWebViewContent> createState() => _TripWebViewContentState();
}

class _TripWebViewContentState extends State<_TripWebViewContent>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  late final TripWebBridge _bridge;
  StreamSubscription<TripBridgeMessage>? _outboundSubscription;
  String? _pageError;
  late final Uri _configuredUri;
  Timer? _mainFrameRetryTimer;
  int _mainFrameRetryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configuredUri = _buildUri();
    _controller =
        WebViewController(onPermissionRequest: (request) => request.deny())
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xfff5f7fa));
    _bridge = TripWebBridge(
      tripId: widget.args.tripId,
      runJavaScript: _controller.runJavaScript,
    );
    _controller
      ..addJavaScriptChannel(
        'FlutterTripBridge',
        onMessageReceived: (message) => _receiveFromWeb(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _navigationDecision(request.url),
          onPageStarted: (_) {
            unawaited(_bridge.resetForReload());
            _queueRestoredBootstrap();
            if (mounted) setState(() => _pageError = null);
          },
          onPageFinished: (_) => _injectHandshakeContext(),
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            _handleMainFrameLoadFailure('Falha ao carregar a navegação.');
          },
          onHttpError: (error) {
            if (error.response?.statusCode == null ||
                !_isConfiguredMainDocument(error.request?.uri)) {
              return;
            }
            _handleMainFrameLoadFailure('Webapp indisponível no momento.');
          },
        ),
      );
    _outboundSubscription = context
        .read<TripTrackingBloc>()
        .outboundMessages
        .listen((message) {
          unawaited(_bridge.send(message));
        });
    if (_isAllowedConfiguration(_configuredUri)) {
      unawaited(_controller.loadRequest(_configuredUri));
    } else {
      _pageError = 'A URL configurada para o webapp não é permitida.';
    }
  }

  Future<void> _injectHandshakeContext() {
    final json = jsonEncode({
      'schemaVersion': TripBridgeMessage.currentSchemaVersion,
      'tripId': widget.args.tripId,
    });
    final literal = jsonEncode(json);
    return _controller.runJavaScript('''
      (() => {
        const context = JSON.parse($literal);
        window.FrotaNativeContext = Object.freeze(context);
        window.dispatchEvent(new CustomEvent('flutter.context', { detail: context }));
      })();
    ''');
  }

  Uri _buildUri() {
    final base = Uri.parse(Env.tripWebAppUrl);
    return base.replace(
      queryParameters: {...base.queryParameters, 'role': widget.args.role.name},
    );
  }

  bool _isAllowedConfiguration(Uri uri) {
    if (!uri.hasScheme || uri.host.isEmpty) return false;
    if (uri.scheme == 'https') return true;
    return kDebugMode && uri.scheme == 'http';
  }

  NavigationDecision _navigationDecision(String rawUrl) {
    final target = Uri.tryParse(rawUrl);
    if (target == null) return NavigationDecision.prevent;
    if (target.scheme == 'about' && target.path == 'blank') {
      return NavigationDecision.navigate;
    }
    final sameOrigin =
        target.scheme == _configuredUri.scheme &&
        target.host == _configuredUri.host &&
        target.port == _configuredUri.port;
    return sameOrigin
        ? NavigationDecision.navigate
        : NavigationDecision.prevent;
  }

  bool _isConfiguredMainDocument(Uri? uri) {
    if (uri == null) return false;
    return uri.scheme == _configuredUri.scheme &&
        uri.host == _configuredUri.host &&
        uri.port == _configuredUri.port &&
        uri.path == _configuredUri.path &&
        uri.queryParameters['role'] == _configuredUri.queryParameters['role'];
  }

  void _handleMainFrameLoadFailure(String message) {
    if (!mounted || (_mainFrameRetryTimer?.isActive ?? false)) return;
    if (_mainFrameRetryCount == 0) {
      _mainFrameRetryCount++;
      _mainFrameRetryTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        unawaited(_controller.loadRequest(_configuredUri));
      });
      return;
    }
    setState(() => _pageError = message);
  }

  Future<void> _receiveFromWeb(String raw) async {
    try {
      await _bridge.handleJavaScriptMessage(raw);
      final message = TripBridgeMessage.decode(
        raw,
        expectedTripId: widget.args.tripId,
        allowedTypes: TripMessageType.fromWeb,
      );
      if (message.type == TripMessageType.webReady) {
        _mainFrameRetryTimer?.cancel();
        _mainFrameRetryCount = 0;
      }
      if (message.type == TripMessageType.externalNavigationRequested) {
        await _openExternalNavigation(message.payload);
        return;
      }
      if (mounted) {
        await context.read<TripTrackingBloc>().handleWebMessage(message);
      }
    } on FormatException {
      // A WebView não recebe detalhes da validação e o conteúdo não é logado.
    }
  }

  Future<void> _openExternalNavigation(Map<String, dynamic> payload) async {
    final provider = payload['provider'] as String;
    final destination = payload['destination'] as Map;
    final origin = payload['origin'] as Map?;
    final destinationCoordinates =
        '${destination['lat']},${destination['lng']}';
    final uri = provider == 'waze'
        ? Uri.https('waze.com', '/ul', {
            'll': destinationCoordinates,
            'navigate': 'yes',
          })
        : Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            if (origin != null) 'origin': '${origin['lat']},${origin['lng']}',
            'destination': destinationCoordinates,
            'travelmode': 'driving',
          });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) _showExternalNavigationError();
    } catch (_) {
      _showExternalNavigationError();
    }
  }

  void _showExternalNavigationError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir o aplicativo de navegação.'),
      ),
    );
  }

  void _queueRestoredBootstrap() {
    final snapshot = context.read<TripTrackingBloc>().state.snapshot;
    if (snapshot == null) return;
    unawaited(
      _bridge.send(
        TripBridgeMessage.create(
          type: TripMessageType.bootstrap,
          tripId: widget.args.tripId,
          payload: snapshot.toBootstrapPayload(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<TripTrackingBloc>();
    if (state == AppLifecycleState.resumed) {
      unawaited(bloc.onAppResumed());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(bloc.onAppPaused());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainFrameRetryTimer?.cancel();
    unawaited(_outboundSubscription?.cancel());
    unawaited(_bridge.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripTrackingBloc, TripTrackingState>(
      listenWhen: (previous, current) =>
          previous.passengerDistanceAlert != current.passengerDistanceAlert ||
          previous.finished != current.finished,
      listener: (context, state) {
        if (state.passengerDistanceAlert) _showPassengerAlert();
        if (state.finished) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _TripTrackingHeader(
                  title: widget.args.role == TripRole.driver
                      ? 'Navegação da corrida'
                      : 'Acompanhar corrida',
                  onBack: () => Navigator.of(context).maybePop(),
                  onReload: () => _controller.reload(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if (_pageError == null)
                        WebViewWidget(controller: _controller),
                      if (state.loading)
                        const ColoredBox(
                          color: Color(0xfff5f7fa),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_pageError != null || state.errorMessage != null)
                        _ErrorView(
                          message: _pageError ?? state.errorMessage!,
                          onRetry: () {
                            _mainFrameRetryTimer?.cancel();
                            _mainFrameRetryCount = 0;
                            setState(() => _pageError = null);
                            if (state.errorMessage != null) {
                              unawaited(
                                context.read<TripTrackingBloc>().retry(),
                              );
                            } else {
                              unawaited(
                                _controller.loadRequest(_configuredUri),
                              );
                            }
                          },
                        ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _ConnectionChip(connected: state.connected),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPassengerAlert() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Você se afastou do veículo?'),
        content: const Text(
          'Sua posição permaneceu distante do veículo. Se você saiu por engano, retorne ao veículo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
    if (mounted) context.read<TripTrackingBloc>().dismissPassengerAlert();
  }

}

class _TripTrackingHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onReload;

  const _TripTrackingHeader({
    required this.title,
    required this.onBack,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 17, 17, 16),
      child: Row(
        children: [
          Material(
            color: AppColors.primaryBlue,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
                height: 1.2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Recarregar',
            onPressed: onReload,
            color: AppColors.primaryBlue,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  final bool connected;
  const _ConnectionChip({required this.connected});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: connected ? const Color(0xffe7f7ed) : const Color(0xfffff2d8),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(connected ? 'Online' : 'Reconectando…'),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xfff5f7fa),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    ),
  );
}
