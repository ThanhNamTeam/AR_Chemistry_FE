package com.example.ar_chemistry_visual

import android.Manifest
import android.os.Bundle
import android.util.Log
import android.content.pm.PackageManager
import com.xraph.plugin.flutter_unity_widget.FlutterUnityActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterUnityActivity() {
    private var pendingCameraPermissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        logHost("onCreate activity=${this::class.java.name} unityHost=${this is FlutterUnityActivity}")
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        logHost("onResume cameraPermission=${hasCameraPermission()}")
        super.onResume()
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

    private fun logHost(message: String) {
        Log.i(TAG, message)
    }

    companion object {
        private const val TAG = "ANDROID_HOST_DIAG"
        private const val PERMISSIONS_CHANNEL = "ar_chemistry_visual/permissions"
        private const val CAMERA_PERMISSION_REQUEST_CODE = 4101
    }
}
