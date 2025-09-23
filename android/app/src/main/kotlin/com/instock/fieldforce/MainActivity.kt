package com.instock.fieldforce

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "fieldforce/background_location"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"startService" -> {
					val minDistance = (call.argument<Double>("minDistance") ?: 5.0)
					val interval = (call.argument<Int>("intervalMillis") ?: 15000)
					val intent = Intent(this, LocationForegroundService::class.java)
					intent.putExtra("minDistance", minDistance)
					intent.putExtra("intervalMillis", interval)
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
						startForegroundService(intent)
					} else {
						startService(intent)
					}
					result.success(true)
				}
				"stopService" -> {
					val intent = Intent(this, LocationForegroundService::class.java)
					stopService(intent)
					result.success(true)
				}
				else -> result.notImplemented()
			}
		}
	}
}

