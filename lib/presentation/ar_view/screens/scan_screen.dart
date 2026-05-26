import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/orientation_lock_service.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../widgets/ar_camera_view.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  static const _unityLandscapeMessage = 'landscape';
  static const _unityPortraitMessage = 'portrait';

  final _session = ARUnitySession.instance;
  late final AnimationController _pulseCtrl;
  Widget? _arCameraView;
  ModalRoute<dynamic>? _route;
  bool _unityReadyForLandscape = false;
  bool _scannerActive = false;
  int _uiModeToken = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[AR_UNITY_TIMING] ScanScreen initState');
    WidgetsBinding.instance.addObserver(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _ensureArCameraView();
    _syncUnityReadyFromCurrentState(
      reason: OrientationLockService.scannerAlreadyReady,
      shouldSetState: false,
    );
    _session.addListener(_onUnitySessionChanged);
    _syncUnityReadyFromCurrentState(
      reason: OrientationLockService.scannerAlreadyReady,
      shouldSetState: false,
    );
    _enterScannerUiMode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
    _scheduleLandscapeMetricsLog();
  }

  @override
  void didPush() {
    _enterScannerUiMode();
  }

  @override
  void didPopNext() {
    _enterScannerUiMode();
  }

  @override
  void didPushNext() {
    _restoreAppUiMode();
  }

  @override
  void didPop() {
    _restoreAppUiMode();
  }

  @override
  void didChangeMetrics() {
    _scheduleLandscapeMetricsLog();
  }

  @override
  void dispose() {
    debugPrint('[AR_UNITY_TIMING] ScanScreen dispose');
    WidgetsBinding.instance.removeObserver(this);
    _session.removeListener(_onUnitySessionChanged);
    appRouteObserver.unsubscribe(this);
    _restoreAppUiMode();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _enterScannerUiMode() async {
    if (_scannerActive) return;
    final token = ++_uiModeToken;
    _scannerActive = true;
    _resetScannerLocalFlags();
    _ensureArCameraView();
    _syncUnityReadyFromCurrentState(
      reason: OrientationLockService.scannerAlreadyReady,
      shouldSetState: false,
    );
    debugPrint('[AR_UNITY_TIMING] ScanScreen scannerModeEntered');
    unawaited(
      OrientationLockService.lockScannerLandscape(
        reason: OrientationLockService.scannerEnter,
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!mounted || token != _uiModeToken || !_scannerActive) {
      await OrientationLockService.restoreAppPortrait();
      return;
    }
    _scheduleLandscapeMetricsLog();
    _sendUnityLandscapeIfReady();
  }

  Future<void> _restoreAppUiMode() async {
    if (!_scannerActive) return;
    final token = ++_uiModeToken;
    _scannerActive = false;
    debugPrint('[AR_UNITY_TIMING] ScanScreen portraitRestored');
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (token != _uiModeToken || _scannerActive) return;
    await OrientationLockService.restoreAppPortrait();
    unawaited(_session.sendOrientationToUnity(_unityPortraitMessage));
  }

  Future<void> _handleBackPressed() async {
    await _restoreAppUiMode();
    if (!mounted) return;
    Navigator.maybePop(context);
  }

  void _ensureArCameraView() {
    _arCameraView ??= const ARCameraView(
      key: ValueKey('stable-ar-camera-view'),
      portalBorderRadius: 0,
    );
  }

  void _resetScannerLocalFlags() {
    _unityReadyForLandscape = false;
  }

  void _onUnitySessionChanged() {
    if (!_scannerActive) return;
    _syncUnityReadyFromCurrentState(
      reason: _scannerReadyReason(),
      shouldSetState: true,
    );
  }

  void _syncUnityReadyFromCurrentState({
    required String reason,
    required bool shouldSetState,
  }) {
    if (!_isUnityReadyForLandscape) return;

    if (!_unityReadyForLandscape) {
      if (shouldSetState && mounted) {
        setState(() {
          _unityReadyForLandscape = true;
        });
      } else {
        _unityReadyForLandscape = true;
      }
      debugPrint('[AR_UNITY_TIMING] scanUnityReadyForLandscape reason=$reason');
    }

    _sendUnityLandscapeIfReady();
  }

  bool get _isUnityReadyForLandscape =>
      _session.sceneLoaded &&
      _session.preloadState == ARUnityPreloadState.ready;

  String _scannerReadyReason() {
    switch (_session.readySignal) {
      case ARUnityReadySignal.sceneLoaded:
        return OrientationLockService.scannerUnitySceneLoaded;
      case ARUnityReadySignal.fallback:
        return OrientationLockService.scannerUnityReadyFallback;
      case null:
        return OrientationLockService.scannerAlreadyReady;
    }
  }

  void _sendUnityLandscapeIfReady() {
    if (!_scannerActive || !_unityReadyForLandscape) return;

    final reason = _scannerReadyReason();
    unawaited(_session.forceNativeUnityFullscreen(reason: reason));
    unawaited(_session.sendOrientationToUnity(_unityLandscapeMessage));
  }

  void _scheduleLandscapeMetricsLog() {
    if (!mounted || !_scannerActive) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logLandscapeMetricsIfSettled();
    });
  }

  void _logLandscapeMetricsIfSettled() {
    if (!mounted || !_scannerActive) return;

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null || !_isLandscape(mediaQuery)) return;

    setState(() {});
    debugPrint(
      '[AR_UNITY_TIMING] scanLandscapeSettled '
      'width=${mediaQuery.size.width.toStringAsFixed(1)} '
      'height=${mediaQuery.size.height.toStringAsFixed(1)}',
    );
    OrientationLockService.logAndroidOrientationState('scanLandscapeSettled');
    unawaited(
      _session.forceNativeUnityFullscreen(reason: 'scanLandscapeSettled'),
    );
  }

  bool _isLandscape(MediaQueryData mediaQuery) {
    return mediaQuery.orientation == Orientation.landscape ||
        mediaQuery.size.width > mediaQuery.size.height;
  }

  bool _shouldShowLoading(ARUnitySession session, MediaQueryData mediaQuery) {
    return !_unityReadyForLandscape ||
        session.preloadState != ARUnityPreloadState.ready ||
        !session.sceneLoaded ||
        !_isLandscape(mediaQuery);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[AR_UNITY_TIMING] ScanScreen build');

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _restoreAppUiMode();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: AnimatedBuilder(
            animation: ARUnitySession.instance,
            builder: (context, _) {
              final session = _session;
              final mediaQuery = MediaQuery.of(context);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (_scannerActive && _arCameraView != null)
                    Positioned.fill(child: _arCameraView!),
                  if (session.preloadState == ARUnityPreloadState.failedFinal)
                    const _UnityScannerErrorView()
                  else if (_shouldShowLoading(session, mediaQuery))
                    _UnityScannerLoadingView(animation: _pulseCtrl),
                  _ScannerBackButton(onPressed: _handleBackPressed),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UnityScannerLoadingView extends StatelessWidget {
  const _UnityScannerLoadingView({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [Color(0xFF062321), Colors.black],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.96 + (animation.value * 0.06),
              child: Opacity(
                opacity: 0.74 + (animation.value * 0.26),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Powered by Unity Engine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Preparing AR scanner...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.64),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerBackButton extends StatelessWidget {
  const _ScannerBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: Colors.black.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: 'Back',
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnityScannerErrorView extends StatelessWidget {
  const _UnityScannerErrorView();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 56,
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to start AR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The Unity engine could not initialize on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 15,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
