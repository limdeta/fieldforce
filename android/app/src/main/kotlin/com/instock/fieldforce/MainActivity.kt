package com.instock.fieldforce

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.instock.fieldforce.db.BgGpsDatabase
import com.instock.fieldforce.db.BgGpsPoint
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
	private val CHANNEL = "fieldforce/background_location"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
			val db = BgGpsDatabase.getInstance(applicationContext)
			val dbExecutor = Executors.newSingleThreadExecutor()

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"startService" -> {
					val minDistance = (call.argument<Double>("minDistance") ?: 5.0)
					val interval = (call.argument<Int>("intervalMillis") ?: 15000)
					val priority = (call.argument<String>("priority") ?: "balanced")
					
					val intent = Intent(this, LocationForegroundService::class.java)
					intent.putExtra("minDistance", minDistance.toFloat())
					intent.putExtra("intervalMillis", interval.toLong())
					intent.putExtra("priority", priority)
					
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
				"readBatch" -> {
					val limit = (call.argument<Int>("limit") ?: 200)
					dbExecutor.execute {
						try {
							val dao = db.bgGpsPointDao()
							val list = dao.getUnprocessed(limit)
							val out = ArrayList<Map<String, Any?>>()
							for (p in list) {
								val m = HashMap<String, Any?>()
								m["id"] = p.id
								m["latitude"] = p.latitude
								m["longitude"] = p.longitude
								m["accuracy"] = p.accuracy
								m["timestamp"] = p.timestamp
								out.add(m)
							}
							result.success(out)
						} catch (e: Exception) {
							result.error("read_error", e.message, null)
						}
					}
				}
				"markProcessed" -> {
					val ids = (call.argument<List<Int>>("ids") ?: emptyList())
					dbExecutor.execute {
						try {
							if (ids.isNotEmpty()) {
								val longIds = ids.map { it.toLong() }.toLongArray()
								db.bgGpsPointDao().markProcessedByIds(longIds)
								// optionally purge old processed rows
								db.bgGpsPointDao().deleteProcessed()
							}
							result.success(true)
						} catch (e: Exception) {
							result.error("mark_error", e.message, null)
						}
					}
				}
				else -> result.notImplemented()
			}
		}
	}
}

