package com.instock.fieldforce

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.FlutterInjector

class LocationForegroundService : Service() {
    private val CHANNEL_ID = "fieldforce_location_channel"
    private val NOTIF_ID = 8472
    private lateinit var fusedClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var engine: FlutterEngine? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()

        // Initialize Flutter engine for MethodChannel communication if needed
        try {
            val injector = FlutterInjector.instance()
            engine = FlutterEngine(this)
            // Note: don't execute a Dart entrypoint here; we'll only use MethodChannel to send events
            methodChannel = MethodChannel(engine!!.dartExecutor.binaryMessenger, "fieldforce/background_location")
        } catch (e: Exception) {
            // Best-effort, if engine can't be created we still continue with local behavior
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) {
                    sendLocationToFlutter(loc)
                }
            }
        }
    }

    private fun sendLocationToFlutter(loc: Location) {
        val map = HashMap<String, Any?>()
        map["latitude"] = loc.latitude
        map["longitude"] = loc.longitude
        map["accuracy"] = loc.accuracy
        map["timestamp"] = loc.time
        map["isBackground"] = true
        try {
            methodChannel?.invokeMethod("onLocation", map)
        } catch (e: Exception) {
            // swallow: flutter engine may not be available in some contexts
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification()
        startForeground(NOTIF_ID, notification)

        // Start location updates
        startLocationUpdates()
        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        engine?.destroy()
        super.onDestroy()
    }

    private fun startLocationUpdates() {
        try {
            val req = LocationRequest.create().apply {
                interval = 15_000 // 15s default; can be adjusted from Flutter via MethodChannel
                fastestInterval = 5_000
                priority = Priority.PRIORITY_BALANCED_POWER_ACCURACY
                smallestDisplacement = 5f
            }
            fusedClient.requestLocationUpdates(req, locationCallback, Looper.getMainLooper())
        } catch (e: SecurityException) {
            // missing permissions — the app should ensure permissions before starting service
        }
    }

    private fun stopLocationUpdates() {
        fusedClient.removeLocationUpdates(locationCallback)
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Fieldforce tracking")
            .setContentText("Background location tracking is active")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Location tracking", NotificationManager.IMPORTANCE_LOW)
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
