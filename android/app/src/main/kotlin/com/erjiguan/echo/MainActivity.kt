package com.erjiguan.echo

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "echo/platform/storage_directory",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppStorageDirectory" -> result.success(applicationContext.filesDir.absolutePath)
                else -> result.notImplemented()
            }
        }
    }
}
