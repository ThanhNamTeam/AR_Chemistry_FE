import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';

class ARCameraView extends StatefulWidget {
  const ARCameraView({super.key, this.portalBorderRadius = 22});

  final double portalBorderRadius;

  @override
  State<ARCameraView> createState() => _ARCameraViewState();
}

class _ARCameraViewState extends State<ARCameraView>
    with AutomaticKeepAliveClientMixin, RouteAware {
  final _session = ARUnitySession.instance;
  ModalRoute<dynamic>? _route;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _session.markRouteOpened();
    _session.logWidgetLifecycle('ARCameraView initState');
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPortal());
  }

  @override
  void dispose() {
    _session.logWidgetLifecycle('ARCameraView dispose');
    appRouteObserver.unsubscribe(this);
    _session.hidePortal(this);
    super.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPortal());
  }

  @override
  void didPush() {
    _session.logWidgetLifecycle('ARCameraView route didPush');
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPortal());
  }

  @override
  void didPopNext() {
    _session.logWidgetLifecycle('ARCameraView route didPopNext');
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPortal());
  }

  @override
  void didPushNext() {
    _session.logWidgetLifecycle('ARCameraView route didPushNext');
    _session.hidePortal(this);
  }

  @override
  void didPop() {
    _session.logWidgetLifecycle('ARCameraView route didPop');
    _session.hidePortal(this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _session.logWidgetLifecycle('ARCameraView build');
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPortal());

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const _UnityUnavailableView();
    }

    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        if (_session.preloadState == ARUnityPreloadState.failedFinal) {
          return const _UnityUnavailableView(
            message: 'Unable to initialize AR on this device.',
          );
        }

        if (_session.permissionGranted == false) {
          return const _UnityUnavailableView();
        }

        return const SizedBox.expand();
      },
    );
  }

  void _syncPortal() {
    if (!mounted) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      _session.hidePortal(this);
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    _session.showPortal(
      owner: this,
      rect: topLeft & renderObject.size,
      borderRadius: widget.portalBorderRadius,
    );
    _session.ensureReadyForArEntry();
  }
}

enum ARUnityPreloadState {
  idle,
  preloading,
  ready,
  preloadFailed,
  retrying,
  failedFinal,
}

class ARUnityHost extends StatefulWidget {
  const ARUnityHost({super.key, required this.child});

  final Widget child;

  @override
  State<ARUnityHost> createState() => _ARUnityHostState();
}

class _ARUnityHostState extends State<ARUnityHost> with WidgetsBindingObserver {
  final _session = ARUnitySession.instance;
  late final Widget _unityWidget;
  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  int _stableFrameToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unityWidget = UnityWidget(
      key: const ValueKey('ar-unity-platform-view'),
      fullscreen: false,
      useAndroidViewSurface: true,
      onUnityCreated: _session.attach,
      onUnityMessage: _session.onUnityMessage,
      onUnitySceneLoaded: _session.onUnitySceneLoaded,
      onUnityUnloaded: _session.onUnityUnloaded,
    );
  }

  @override
  void dispose() {
    _session.logWidgetLifecycle('ARUnityHost dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _session.logWidgetLifecycle('appLifecycleState ${state.name}');
    if (state == AppLifecycleState.resumed) {
      _scheduleSafePreload();
      _session.resume();
    } else if (state == AppLifecycleState.inactive) {
      _session.skipPauseForInactive();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _session.pause(lifecycleState: state);
    }
  }

  @override
  void didChangeMetrics() {
    _stableFrameToken++;
    _session.logWidgetLifecycle(
      'appUnityPreloadDeferred reason=metricsChanged',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleSafePreload();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_session.shouldMountUnity) _buildUnityLayer(),
          ],
        );
      },
    );
  }

  void _scheduleSafePreload() {
    if (!mounted ||
        !_session.hasVisiblePortal ||
        !_session.canStartSafePreload) {
      return;
    }

    final token = ++_stableFrameToken;
    _session.logWidgetLifecycle('appUnityPreloadScheduled visiblePortal=true');
    _runSafePreload(token);
  }

  Future<void> _runSafePreload(int token) async {
    if (_lifecycleState != AppLifecycleState.resumed) {
      _session.logWidgetLifecycle(
        'appUnityPreloadWaiting lifecycle=${_lifecycleState.name}',
      );
      return;
    }

    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);

    if (!mounted || token != _stableFrameToken || !_session.hasVisiblePortal) {
      return;
    }

    if (_lifecycleState != AppLifecycleState.resumed) {
      _session.logWidgetLifecycle(
        'appUnityPreloadWaiting lifecycle=${_lifecycleState.name}',
      );
      return;
    }

    await _session.startInitialPreload();
  }

  Widget _buildUnityLayer() {
    final isVisible = _session.hasVisiblePortal;
    final rect = isVisible
        ? _session.portalRect!
        : const Rect.fromLTWH(-1, -1, 1, 1);

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            isVisible ? _session.portalBorderRadius : 0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _session.logUnityHostRect(
                mode: isVisible ? 'portal' : 'preload-hidden',
                size: Size(constraints.maxWidth, constraints.maxHeight),
              );
              return _unityWidget;
            },
          ),
        ),
      ),
    );
  }
}

class ARUnitySession extends ChangeNotifier {
  ARUnitySession._();

  static final ARUnitySession instance = ARUnitySession._();
  static const _permissionsChannel = MethodChannel(
    'ar_chemistry_visual/permissions',
  );

  final Stopwatch _routeStopwatch = Stopwatch();
  Future<bool>? _permissionFuture;
  Completer<void>? _sceneLoadedCompleter;
  UnityWidgetController? _controller;
  Object? _portalOwner;
  Rect? _portalRect;
  double _portalBorderRadius = 0;
  bool _lifecycleTransitionInFlight = false;
  DateTime? _lastRetryAt;
  String? _lastHostRectLogKey;

  bool? permissionGranted;
  bool unityCreated = false;
  bool sceneLoaded = false;
  bool isVisible = false;
  bool isPaused = false;
  ARUnityPreloadState preloadState = ARUnityPreloadState.idle;

  Rect? get portalRect => _portalRect;
  double get portalBorderRadius => _portalBorderRadius;
  bool get hasVisiblePortal => isVisible && _portalRect != null;
  bool get isPreloading =>
      preloadState == ARUnityPreloadState.preloading ||
      preloadState == ARUnityPreloadState.retrying;
  bool get shouldMountUnity =>
      permissionGranted == true &&
      hasVisiblePortal &&
      preloadState != ARUnityPreloadState.idle &&
      preloadState != ARUnityPreloadState.preloadFailed &&
      preloadState != ARUnityPreloadState.failedFinal;
  bool get canStartSafePreload =>
      preloadState == ARUnityPreloadState.idle && !unityCreated;

  void markRouteOpened() {
    _routeStopwatch
      ..reset()
      ..start();
    _log('routeOpened');
  }

  Future<void> startInitialPreload() {
    if (!canStartSafePreload) return Future<void>.value();
    return _runPreload(
      nextState: ARUnityPreloadState.preloading,
      timeout: const Duration(seconds: 12),
      failedState: ARUnityPreloadState.preloadFailed,
      startLog: 'appUnityPreloadStart',
      timeoutLog: 'appUnityPreloadTimeout',
    );
  }

  Future<void> ensureReadyForArEntry() {
    if (preloadState == ARUnityPreloadState.ready ||
        preloadState == ARUnityPreloadState.preloading ||
        preloadState == ARUnityPreloadState.retrying) {
      return Future<void>.value();
    }

    if (preloadState == ARUnityPreloadState.idle) {
      return startInitialPreload();
    }

    if (preloadState == ARUnityPreloadState.failedFinal) {
      _log('appUnityPreloadRetrySkipped state=failedFinal');
      return Future<void>.value();
    }

    final now = DateTime.now();
    final lastRetryAt = _lastRetryAt;
    if (lastRetryAt != null &&
        now.difference(lastRetryAt) < const Duration(seconds: 3)) {
      _log('appUnityPreloadRetrySkipped reason=cooldown');
      return Future<void>.value();
    }

    _lastRetryAt = now;
    return _runPreload(
      nextState: ARUnityPreloadState.retrying,
      timeout: const Duration(seconds: 15),
      failedState: ARUnityPreloadState.failedFinal,
      startLog: 'appUnityPreloadRetryStart',
      timeoutLog: 'appUnityPreloadRetryTimeout',
    );
  }

  Future<void> _runPreload({
    required ARUnityPreloadState nextState,
    required Duration timeout,
    required ARUnityPreloadState failedState,
    required String startLog,
    required String timeoutLog,
  }) async {
    if (preloadState == ARUnityPreloadState.ready ||
        preloadState == ARUnityPreloadState.preloading ||
        preloadState == ARUnityPreloadState.retrying) {
      _log('appUnityPreloadSkipped state=${preloadState.name}');
      return;
    }

    preloadState = nextState;
    sceneLoaded = false;
    _sceneLoadedCompleter = Completer<void>();
    _log(startLog);
    notifyListeners();

    final granted = await ensureCameraPermission();
    if (!granted) {
      preloadState = failedState;
      _resetUnityControllerState();
      _log(
        failedState == ARUnityPreloadState.failedFinal
            ? 'appUnityPreloadFailedFinal reason=cameraPermission'
            : 'appUnityPreloadFailed reason=cameraPermission',
      );
      notifyListeners();
      return;
    }

    notifyListeners();

    try {
      await _sceneLoadedCompleter!.future.timeout(timeout);
    } on TimeoutException {
      if (preloadState == ARUnityPreloadState.ready || sceneLoaded) return;

      preloadState = failedState;
      _resetUnityControllerState();
      _log(timeoutLog);
      if (failedState == ARUnityPreloadState.failedFinal) {
        _log('appUnityPreloadFailedFinal reason=timeout');
      } else {
        _log('appUnityPreloadFailed reason=timeout');
      }
      notifyListeners();
    } catch (error, stackTrace) {
      if (preloadState == ARUnityPreloadState.ready || sceneLoaded) return;

      preloadState = failedState;
      _resetUnityControllerState();
      _log('appUnityPreloadUnexpectedError $error');
      _log('appUnityPreloadUnexpectedStack $stackTrace');
      if (failedState == ARUnityPreloadState.failedFinal) {
        _log('appUnityPreloadFailedFinal reason=unexpectedError');
      }
      notifyListeners();
    }
  }

  Future<bool> ensureCameraPermission() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      permissionGranted = true;
      notifyListeners();
      return Future<bool>.value(true);
    }

    return _permissionFuture ??= _requestCameraPermission();
  }

  Future<void> attach(UnityWidgetController controller) async {
    _controller = controller;
    unityCreated = true;
    _log('unityCreated');
    notifyListeners();

    try {
      await _logControllerState('attach-before-resume');

      final isPaused = await controller.isPaused();
      if (isPaused == true) {
        await controller.resume();
        _log('unityResumedFromAttach');
        await _logControllerState('attach-after-resume');
      }
    } on PlatformException catch (error) {
      _log(
        'unityAttachPlatformError '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
    } catch (error, stackTrace) {
      _log('unityAttachUnexpectedError $error');
      _log('unityAttachUnexpectedStack $stackTrace');
    }
  }

  void onUnityMessage(dynamic message) {
    _log('unityMessage ${message.toString()}');
  }

  void onUnitySceneLoaded(SceneLoaded? sceneInfo) {
    if (sceneInfo == null) {
      _log('unitySceneLoaded null');
      return;
    }
    _log(
      'unitySceneLoaded name=${sceneInfo.name} '
      'buildIndex=${sceneInfo.buildIndex} '
      'isLoaded=${sceneInfo.isLoaded} '
      'isValid=${sceneInfo.isValid}',
    );
    sceneLoaded = sceneInfo.isLoaded == true;
    if (sceneLoaded) {
      preloadState = ARUnityPreloadState.ready;
      _log('appUnityPreloadReady');
      final completer = _sceneLoadedCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    }
    notifyListeners();
  }

  void onUnityUnloaded() {
    unityCreated = false;
    sceneLoaded = false;
    isPaused = false;
    _controller = null;
    if (preloadState == ARUnityPreloadState.ready) {
      preloadState = ARUnityPreloadState.idle;
    }
    _log('unityUnloaded');
    notifyListeners();
  }

  void logPermissionResult(bool granted) {
    _log('cameraPermission granted=$granted');
  }

  void logPermissionDenied() {
    _log('cameraPermissionDenied');
  }

  void logWidgetLifecycle(String event) {
    _log(event);
  }

  void _resetUnityControllerState() {
    _controller = null;
    unityCreated = false;
    sceneLoaded = false;
    isPaused = false;
  }

  void logUnityHostRect({required String mode, required Size size}) {
    final width = size.width.toStringAsFixed(1);
    final height = size.height.toStringAsFixed(1);
    final key = '$mode:$width:$height';
    if (_lastHostRectLogKey == key) return;

    _lastHostRectLogKey = key;
    _log('unityHostRect mode=$mode width=$width height=$height');
  }

  void showPortal({
    required Object owner,
    required Rect rect,
    required double borderRadius,
  }) {
    final changed =
        _portalOwner != owner ||
        _portalRect != rect ||
        _portalBorderRadius != borderRadius ||
        !isVisible;

    _portalOwner = owner;
    _portalRect = rect;
    _portalBorderRadius = borderRadius;
    isVisible = true;

    if (changed) {
      _log(
        'unityPortalShow '
        'left=${rect.left.toStringAsFixed(1)} '
        'top=${rect.top.toStringAsFixed(1)} '
        'width=${rect.width.toStringAsFixed(1)} '
        'height=${rect.height.toStringAsFixed(1)}',
      );
      notifyListeners();
    }
  }

  void hidePortal(Object owner) {
    if (_portalOwner != owner) return;

    _portalOwner = null;
    isVisible = false;
    _log('unityPortalHide');
    notifyListeners();
  }

  void skipPauseForInactive() {
    _log('unityPauseSkipped lifecycle=inactive');
  }

  Future<void> pause({AppLifecycleState? lifecycleState}) async {
    final controller = _controller;
    if (controller == null) {
      _log('unityPauseSkipped noController');
      return;
    }
    if (!unityCreated) {
      _log('unityPauseSkipped unityNotCreated');
      return;
    }
    if (!sceneLoaded) {
      _log('unityPauseSkipped sceneNotLoaded');
      return;
    }
    if (isPreloading) {
      _log('unityPauseSkipped startupInProgress');
      return;
    }
    if (_lifecycleTransitionInFlight) {
      _log('unityLifecycleSkipped inFlight action=pause');
      return;
    }

    try {
      _lifecycleTransitionInFlight = true;
      if (lifecycleState != null) {
        _log('unityPauseRequested lifecycle=${lifecycleState.name}');
      }
      await _logControllerState('pause-before');
      final isPaused = await controller.isPaused();
      if (isPaused == true) {
        _log('unityPauseSkipped alreadyPaused');
        return;
      }

      await controller.pause();
      this.isPaused = true;
      _log('unityPaused');
      await _logControllerState('pause-after');
      notifyListeners();
    } on PlatformException catch (error) {
      _log(
        'unityPausePlatformError '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
    } catch (error, stackTrace) {
      _log('unityPauseUnexpectedError $error');
      _log('unityPauseUnexpectedStack $stackTrace');
    } finally {
      _lifecycleTransitionInFlight = false;
    }
  }

  Future<void> resume() async {
    final controller = _controller;
    if (controller == null) {
      _log('unityResumeSkipped noController');
      return;
    }
    if (_lifecycleTransitionInFlight) {
      _log('unityLifecycleSkipped inFlight action=resume');
      return;
    }

    try {
      _lifecycleTransitionInFlight = true;
      await _logControllerState('resume-before');
      final isPaused = await controller.isPaused();
      if (isPaused == false) {
        this.isPaused = false;
        _log('unityResumeSkipped alreadyRunning');
        return;
      }

      await controller.resume();
      this.isPaused = false;
      _log('unityResumed');
      await _logControllerState('resume-after');
      notifyListeners();
    } on PlatformException catch (error) {
      _log(
        'unityResumePlatformError '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
    } catch (error, stackTrace) {
      _log('unityResumeUnexpectedError $error');
      _log('unityResumeUnexpectedStack $stackTrace');
    } finally {
      _lifecycleTransitionInFlight = false;
    }
  }

  Future<void> _logControllerState(String reason) async {
    final controller = _controller;
    if (controller == null) {
      _log('unityState reason=$reason noController');
      return;
    }

    try {
      final isLoaded = await controller.isLoaded();
      final isReady = await controller.isReady();
      final isPaused = await controller.isPaused();
      this.isPaused = isPaused == true;
      _log(
        'unityState reason=$reason '
        'loaded=$isLoaded ready=$isReady paused=$isPaused',
      );
    } on PlatformException catch (error) {
      _log(
        'unityStatePlatformError reason=$reason '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
    } catch (error, stackTrace) {
      _log('unityStateUnexpectedError reason=$reason $error');
      _log('unityStateUnexpectedStack reason=$reason $stackTrace');
    }
  }

  void _log(String event) {
    final elapsed = _routeStopwatch.isRunning
        ? _routeStopwatch.elapsedMilliseconds
        : 0;
    debugPrint('[AR_UNITY_TIMING] ${elapsed}ms $event');
  }

  Future<bool> _requestCameraPermission() async {
    try {
      debugPrint('[AR_UNITY_TIMING] cameraPermission requestStart');
      final granted = await _permissionsChannel.invokeMethod<bool>(
        'requestCameraPermission',
      );
      permissionGranted = granted == true;
      logPermissionResult(permissionGranted == true);
      notifyListeners();
      return permissionGranted == true;
    } on MissingPluginException catch (error) {
      debugPrint('[AR_UNITY_TIMING] cameraPermissionChannelMissing $error');
      permissionGranted = false;
      notifyListeners();
      return false;
    } on PlatformException catch (error) {
      debugPrint(
        '[AR_UNITY_TIMING] cameraPermissionError '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
      permissionGranted = false;
      notifyListeners();
      return false;
    } catch (error, stackTrace) {
      debugPrint('[AR_UNITY_TIMING] cameraPermissionUnexpectedError $error');
      debugPrint(
        '[AR_UNITY_TIMING] cameraPermissionUnexpectedStack $stackTrace',
      );
      permissionGranted = false;
      notifyListeners();
      return false;
    }
  }
}

class _UnityUnavailableView extends StatelessWidget {
  const _UnityUnavailableView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: message == null
          ? null
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
    );
  }
}
