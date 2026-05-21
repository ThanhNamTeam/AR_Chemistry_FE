import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';

class ARCameraView extends StatefulWidget {
  const ARCameraView({super.key});

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
        if (_session.permissionGranted == false) {
          return const _UnityUnavailableView();
        }

        if (_session.permissionGranted == null || !_session.unityCreated) {
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
      borderRadius: 22,
    );
  }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unityWidget = UnityWidget(
      fullscreen: false,
      onUnityCreated: _session.attach,
      onUnityMessage: _session.onUnityMessage,
      onUnitySceneLoaded: _session.onUnitySceneLoaded,
      onUnityUnloaded: _session.onUnityUnloaded,
    );
    _session.preload();
  }

  @override
  void dispose() {
    _session.logWidgetLifecycle('ARUnityHost dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _session.logWidgetLifecycle('appLifecycleState ${state.name}');
    if (state == AppLifecycleState.resumed) {
      _session.resume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _session.pause();
    }
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
            if (_session.permissionGranted == true) _buildUnityLayer(),
          ],
        );
      },
    );
  }

  Widget _buildUnityLayer() {
    final rect = _session.portalRect;
    final isVisible = _session.isVisible && rect != null;
    final positionedRect = isVisible ? rect : const Rect.fromLTWH(-1, -1, 1, 1);

    return Positioned(
      left: positionedRect.left,
      top: positionedRect.top,
      width: positionedRect.width,
      height: positionedRect.height,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            isVisible ? _session.portalBorderRadius : 0,
          ),
          child: _unityWidget,
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
  UnityWidgetController? _controller;
  Object? _portalOwner;
  Rect? _portalRect;
  double _portalBorderRadius = 0;

  bool? permissionGranted;
  bool unityCreated = false;
  bool sceneLoaded = false;
  bool isVisible = false;
  bool isPaused = false;
  bool isPreloading = false;

  Rect? get portalRect => _portalRect;
  double get portalBorderRadius => _portalBorderRadius;

  void markRouteOpened() {
    _routeStopwatch
      ..reset()
      ..start();
    _log('routeOpened');
  }

  Future<void> preload() async {
    if (isPreloading || unityCreated) return;

    isPreloading = true;
    _log('appUnityPreloadStart');
    notifyListeners();

    final granted = await ensureCameraPermission();
    if (!granted) {
      _log('appUnityPreloadBlocked cameraPermission=false');
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
    isPreloading = false;
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
      _log('appUnityPreloadReady');
    }
    notifyListeners();
  }

  void onUnityUnloaded() {
    unityCreated = false;
    sceneLoaded = false;
    isPaused = false;
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

  Future<void> pause() async {
    final controller = _controller;
    if (controller == null) {
      _log('unityPauseSkipped noController');
      return;
    }

    try {
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
    }
  }

  Future<void> resume() async {
    final controller = _controller;
    if (controller == null) {
      _log('unityResumeSkipped noController');
      return;
    }

    try {
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
  const _UnityUnavailableView();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            Colors.black.withOpacity(0.75),
          ],
        ),
      ),
    );
  }
}
