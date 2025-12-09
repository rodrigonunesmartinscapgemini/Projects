package com.example.exercicio_final

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.exercicio_final/device"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getDeviceInfo" -> {
					val info = mapOf(
						"manufacturer" to (Build.MANUFACTURER ?: ""),
						"brand" to (Build.BRAND ?: ""),
						"model" to (Build.MODEL ?: ""),
						"sdk" to Build.VERSION.SDK_INT
					)
					result.success(info)
				}
				else -> result.notImplemented()
			}
		}
	}
}
