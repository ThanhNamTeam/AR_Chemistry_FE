import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../../../shared/styles/app_colors.dart';

class ARCameraView extends StatefulWidget {
  const ARCameraView({super.key});

  @override
  State<ARCameraView> createState() => _ARCameraViewState();
}

class _ARCameraViewState extends State<ARCameraView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  static const _permissionsChannel =
      MethodChannel('ar_chemistry_visual/permissions');

  final _session = ARUnitySession.instance;
  late final Future<bool> _cameraPermissionFuture;
  late final Widget _unityWidget;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session.markRouteOpened();
    _session.logWidgetLifecycle('ARCameraView initState');
    _cameraPermissionFuture = _ensureCameraPermission();
    _unityWidget = UnityWidget(
      fullscreen: false,
      onUnityCreated: _session.attach,
      onUnityMessage: _session.onUnityMessage,
      onUnitySceneLoaded: _session.onUnitySceneLoaded,
      onUnityUnloaded: _session.onUnityUnloaded,
    );
  }

  @override
  void dispose() {
    _session.logWidgetLifecycle('ARCameraView dispose');
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
    super.build(context);
    _session.logWidgetLifecycle('ARCameraView build');

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const _UnityUnavailableView();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return FutureBuilder<bool>(
        future: _cameraPermissionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _UnityUnavailableView();
          }

          if (snapshot.data != true) {
            _session.logPermissionDenied();
            return const _UnityUnavailableView();
          }

          return _buildUnityWidget();
        },
      );
    }

    return _buildUnityWidget();
  }

  Widget _buildUnityWidget() {
    return _unityWidget;
  }

  Future<bool> _ensureCameraPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      debugPrint('[AR_UNITY_TIMING] cameraPermission requestStart');
      final granted = await _permissionsChannel.invokeMethod<bool>(
        'requestCameraPermission',
      );
      _session.logPermissionResult(granted == true);
      return granted == true;
    } on MissingPluginException catch (error) {
      debugPrint('[AR_UNITY_TIMING] cameraPermissionChannelMissing $error');
      return false;
    } on PlatformException catch (error) {
      debugPrint(
        '[AR_UNITY_TIMING] cameraPermissionError '
        'code=${error.code} message=${error.message} details=${error.details}',
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('[AR_UNITY_TIMING] cameraPermissionUnexpectedError $error');
      debugPrint('[AR_UNITY_TIMING] cameraPermissionUnexpectedStack $stackTrace');
      return false;
    }
  }
}

class ARUnitySession {
  ARUnitySession._();

  static final ARUnitySession instance = ARUnitySession._();

  final Stopwatch _routeStopwatch = Stopwatch();
  UnityWidgetController? _controller;

  void markRouteOpened() {
    _routeStopwatch
      ..reset()
      ..start();
    _log('routeOpened');
  }

  Future<void> attach(UnityWidgetController controller) async {
    _controller = controller;
    _log('unityCreated');

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
  }

  void onUnityUnloaded() {
    _log('unityUnloaded');
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
      _log('unityPaused');
      await _logControllerState('pause-after');
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
        _log('unityResumeSkipped alreadyRunning');
        return;
      }

      await controller.resume();
      _log('unityResumed');
      await _logControllerState('resume-after');
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
