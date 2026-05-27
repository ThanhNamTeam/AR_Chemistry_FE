package com.example.ar_chemistry_visual

import android.Manifest
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.ViewGroup
import android.widget.FrameLayout
import com.xraph.plugin.flutter_unity_widget.FlutterUnityActivity
import com.xraph.plugin.flutter_unity_widget.UnityPlayerUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterUnityActivity() {
    private var pendingCameraPermissionResult: MethodChannel.Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var orientationRequestToken: Int = 0
    private var scannerOrientationActive: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        logHost("onCreate activity=${this::class.java.name}")
        super.onCreate(savedInstanceState)
        forceUnityFrameMatchParent("onCreate")
    }

    override fun onResume() {
        logHost("onResume cameraPermission=${hasCameraPermission()}")
        super.onResume()
        reassertScannerLandscapeIfActive("onResume")
        forceUnityFrameMatchParent("onResume")
    }

    override fun onPause() {
        logHost("onPause cameraPermission=${hasCameraPermission()}")
        super.onPause()
    }

    override fun onStop() {
        logHost("onStop")
        super.onStop()
    }

    override fun onDestroy() {
        logHost("onDestroy pendingPermission=${pendingCameraPermissionResult != null}")
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        logHost("configureFlutterEngine")
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PERMISSIONS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            logHost("methodCall method=${call.method} cameraPermission=${hasCameraPermission()}")
            when (call.method) {
                "requestCameraPermission" -> requestCameraPermission(result)
                "hasCameraPermission" -> result.success(hasCameraPermission())
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ORIENTATION_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "lockScannerLandscape" -> {
                    val flutterReason = call.argument<String>("reason")
                        ?: "scannerEnter"
                    lockScannerLandscape(flutterReason)
                    result.success(orientationSnapshot())
                }
                "lockScannerLandscapeAfterUnityReady" -> {
                    val flutterReason = call.argument<String>("reason")
                        ?: "scannerUnityReadyLegacy"
                    lockScannerLandscape(flutterReason)
                    result.success(orientationSnapshot())
                }
                "requestScannerLandscape" -> {
                    lockScannerLandscape("requestScannerLandscape")
                    result.success(orientationSnapshot())
                }
                "restoreAppPortrait" -> {
                    val flutterReason = call.argument<String>("reason") ?: "restoreAppPortrait"
                    orientationRequestToken += 1
                    scannerOrientationActive = false
                    requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
                    logOrientation(flutterReason)
                    forceUnityFrameMatchParent(flutterReason)
                    broadcastOrientationToUnity("portrait")
                    result.success(orientationSnapshot())
                }
                "getOrientationState" -> result.success(orientationSnapshot())
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UNITY_LAYOUT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "forceUnityFullscreen" -> {
                    val flutterReason = call.argument<String>("reason") ?: "unknown"
                    forceUnityFrameMatchParent("flutterForceUnityFullscreen:$flutterReason")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        logHost(
            "onConfigurationChanged orientation=${newConfig.orientation} " +
                "requestedOrientation=$requestedOrientation",
        )
        reassertScannerLandscapeIfActive("configurationChanged")
        forceUnityFrameMatchParent("configurationChanged")
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        logHost("onWindowFocusChanged hasFocus=$hasFocus")
        if (hasFocus) {
            reassertScannerLandscapeIfActive("windowFocus")
            forceUnityFrameMatchParent("windowFocus")
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != CAMERA_PERMISSION_REQUEST_CODE) return

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        logHost(
            "onRequestPermissionsResult requestCode=$requestCode " +
                "permissions=${permissions.joinToString()} granted=$granted",
        )
        pendingCameraPermissionResult?.success(granted)
        pendingCameraPermissionResult = null
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        if (hasCameraPermission()) {
            logHost("requestCameraPermission alreadyGranted")
            result.success(true)
            return
        }

        logHost("requestCameraPermission requestPrompt pending=${pendingCameraPermissionResult != null}")
        pendingCameraPermissionResult?.success(false)
        pendingCameraPermissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.CAMERA),
            CAMERA_PERMISSION_REQUEST_CODE,
        )
    }

    private fun hasCameraPermission(): Boolean =
        checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun orientationSnapshot(): Map<String, Any> =
        mapOf(
            "requestedOrientation" to requestedOrientation,
            "configurationOrientation" to resources.configuration.orientation,
            "isLandscape" to (resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE),
        )

    private fun logOrientation(reason: String) {
        val configOrientation = resources.configuration.orientation
        logHost(
            "orientationRequest reason=$reason " +
                "requestedOrientation=$requestedOrientation " +
                "configurationOrientation=$configOrientation",
        )
    }

    private fun lockScannerLandscape(reason: String) {
        orientationRequestToken += 1
        scannerOrientationActive = true
        val token = orientationRequestToken
        applyScannerLandscapeRequest(reason, token)
        scheduleScannerLandscapeRetry(reason, token, 100L)
        scheduleScannerLandscapeRetry(reason, token, 250L)
        scheduleScannerLandscapeRetry(reason, token, 750L)
        scheduleScannerLandscapeRetry(reason, token, 1500L)
        scheduleScannerLandscapeRetry(reason, token, 3000L)
    }

    private fun scheduleScannerLandscapeRetry(reason: String, token: Int, delayMillis: Long) {
        mainHandler.postDelayed({
            applyScannerLandscapeRequest("$reason-retry-${delayMillis}ms", token)
        }, delayMillis)
    }

    private fun applyScannerLandscapeRequest(reason: String, token: Int) {
        if (!scannerOrientationActive || token != orientationRequestToken) {
            logHost(
                "orientationRequestSkipped reason=$reason token=$token " +
                    "active=$scannerOrientationActive currentToken=$orientationRequestToken",
            )
            return
        }

        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
        logOrientation(reason)
        // Unity embedded views can keep stale dimensions across Android rotations.
        // Re-applying match-parent during each orientation assertion keeps the
        // Unity frame aligned with the Flutter scanner viewport.
        forceUnityFrameMatchParent(reason)
        broadcastOrientationToUnity("landscape")
    }

    private fun reassertScannerLandscapeIfActive(reason: String) {
        if (!scannerOrientationActive) return
        applyScannerLandscapeRequest("$reason-reassert", orientationRequestToken)
    }

    private fun broadcastOrientationToUnity(orientation: String) {
        val intent = Intent("com.unity3d.player.ORIENTATION_CHANGE").apply {
            putExtra("orientation", orientation)
            setPackage("com.unity3d.player") // Target the unity library package
        }
        try {
            sendBroadcast(intent)
            logHost("orientationBroadcast sent orientation=$orientation")
        } catch (e: Exception) {
            logHost("orientationBroadcast failed: ${e.message}")
        }
    }

    private fun forceUnityFrameMatchParent(reason: String) {
        mainHandler.post { applyUnityFrameMatchParent(reason) }
        mainHandler.postDelayed({ applyUnityFrameMatchParent("$reason-delayed") }, 250L)
    }

    private fun applyUnityFrameMatchParent(reason: String) {
        val frame = UnityPlayerUtils.unityFrameLayout
        if (frame == null) {
            logHost("unityLayout reason=$reason frame=null")
            return
        }

        val parent = frame.parent as? ViewGroup
        val currentParams = frame.layoutParams
        val beforeWidth = currentParams?.width
        val beforeHeight = currentParams?.height
        val matchParent = ViewGroup.LayoutParams.MATCH_PARENT
        val nextParams = when (currentParams) {
            is FrameLayout.LayoutParams -> currentParams.apply {
                width = matchParent
                height = matchParent
            }
            null -> FrameLayout.LayoutParams(matchParent, matchParent)
            else -> ViewGroup.LayoutParams(matchParent, matchParent)
        }

        if (currentParams !== nextParams) {
            frame.layoutParams = nextParams
        }

        val parentBeforeWidth = parent?.layoutParams?.width
        val parentBeforeHeight = parent?.layoutParams?.height

        frame.requestLayout()
        frame.invalidate()
        parent?.requestLayout()
        parent?.invalidate()

        logHost(
            "unityLayout reason=$reason " +
                "parent=${parent?.javaClass?.simpleName ?: "none"} " +
                "before=${beforeWidth ?: "null"}x${beforeHeight ?: "null"} " +
                "after=${frame.layoutParams.width}x${frame.layoutParams.height} " +
                "parentBefore=${parentBeforeWidth ?: "null"}x${parentBeforeHeight ?: "null"} " +
                "parentAfter=${parent?.layoutParams?.width ?: "null"}x${parent?.layoutParams?.height ?: "null"} " +
                "measured=${frame.measuredWidth}x${frame.measuredHeight} " +
                "size=${frame.width}x${frame.height}",
        )
    }

    private fun logHost(message: String) {
        Log.i(TAG, message)
    }

    companion object {
        private const val TAG = "ANDROID_HOST_DIAG"
        private const val PERMISSIONS_CHANNEL = "ar_chemistry_visual/permissions"
        private const val ORIENTATION_CHANNEL = "ar_chemistry_visual/orientation"
        private const val UNITY_LAYOUT_CHANNEL = "ar_chemistry_visual/unity_layout"
        private const val CAMERA_PERMISSION_REQUEST_CODE = 4101
    }
}
