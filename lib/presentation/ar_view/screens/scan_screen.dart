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
    with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _pulseCtrl;
  Widget? _arCameraView;
  ModalRoute<dynamic>? _route;
  bool _scannerUiModeActive = false;
  bool _landscapeGateSeen = false;
  bool _landscapeStabilized = false;
  bool _arEntryRequested = false;
  int _uiModeToken = 0;
  int _landscapeGateToken = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[AR_UNITY_TIMING] ScanScreen initState');
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

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
    _syncLandscapeGate();
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
  void dispose() {
    debugPrint('[AR_UNITY_TIMING] ScanScreen dispose');
    appRouteObserver.unsubscribe(this);
    _restoreAppUiMode();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _enterScannerUiMode() async {
    if (_scannerUiModeActive) return;
    final token = ++_uiModeToken;
    _scannerUiModeActive = true;
    debugPrint('[AR_UNITY_TIMING] ScanScreen landscapeRequested');
    await OrientationLockService.requestScannerLandscape();
    OrientationLockService.logAndroidOrientationState('scannerUiModeEntered');
    if (!mounted || token != _uiModeToken || !_scannerUiModeActive) {
      await OrientationLockService.restoreAppPortrait();
      return;
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _restoreAppUiMode() async {
    if (!_scannerUiModeActive) return;
    final token = ++_uiModeToken;
    _scannerUiModeActive = false;
    debugPrint('[AR_UNITY_TIMING] ScanScreen portraitRestored');
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (token != _uiModeToken || _scannerUiModeActive) return;
    await OrientationLockService.restoreAppPortrait();
  }

  Future<void> _handleBackPressed() async {
    await _restoreAppUiMode();
    if (!mounted) return;
    Navigator.maybePop(context);
  }

  void _syncLandscapeGate() {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;

    final size = mediaQuery.size;
    if (size.width <= size.height) {
      if (_landscapeGateSeen ||
          _landscapeStabilized ||
          _arEntryRequested ||
          _arCameraView != null) {
        debugPrint(
          '[AR_UNITY_TIMING] scanLandscapeGateReset '
          'width=${size.width.toStringAsFixed(1)} '
          'height=${size.height.toStringAsFixed(1)}',
        );
      }
      _landscapeGateToken++;
      _landscapeGateSeen = false;
      _landscapeStabilized = false;
      _arEntryRequested = false;
      _arCameraView = null;
      return;
    }

    if (!_landscapeGateSeen) {
      _landscapeGateSeen = true;
      final token = ++_landscapeGateToken;
      debugPrint(
        '[AR_UNITY_TIMING] scanLandscapeGateSeen '
        'width=${size.width.toStringAsFixed(1)} '
        'height=${size.height.toStringAsFixed(1)}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stabilizeLandscapeGate(token);
      });
      return;
    }

    if (_landscapeStabilized) {
      _ensureArCameraView();
      _requestArEntryAfterLandscape();
    }
  }

  void _stabilizeLandscapeGate(int token) {
    if (!mounted || token != _landscapeGateToken) return;

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;

    final size = mediaQuery.size;
    if (size.width <= size.height) {
      _syncLandscapeGate();
      return;
    }

    setState(() {
      _landscapeStabilized = true;
      _ensureArCameraView();
    });
    debugPrint(
      '[AR_UNITY_TIMING] scanLandscapeGatePassed '
      'width=${size.width.toStringAsFixed(1)} '
      'height=${size.height.toStringAsFixed(1)}',
    );
    OrientationLockService.logAndroidOrientationState('scanLandscapeGatePassed');
    _requestArEntryAfterLandscape();
  }

  void _ensureArCameraView() {
    _arCameraView ??= const ARCameraView(
      key: ValueKey('stable-ar-camera-view'),
      portalBorderRadius: 0,
    );
  }

  void _requestArEntryAfterLandscape() {
    if (_arEntryRequested || !_landscapeStabilized || _arCameraView == null) {
      return;
    }

    _arEntryRequested = true;
    debugPrint('[AR_UNITY_TIMING] scanArEntryRequested');
    ARUnitySession.instance.ensureReadyForArEntry();
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
              final session = ARUnitySession.instance;
              final arCameraView =
                  _landscapeStabilized ? _arCameraView : null;

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (arCameraView != null)
                    Positioned.fill(child: arCameraView),
                  if (session.preloadState == ARUnityPreloadState.failedFinal)
                    const _UnityScannerErrorView()
                  else if (arCameraView == null ||
                      session.preloadState != ARUnityPreloadState.ready ||
                      !session.sceneLoaded)
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
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
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
