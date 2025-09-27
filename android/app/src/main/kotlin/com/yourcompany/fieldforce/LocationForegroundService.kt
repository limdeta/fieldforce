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
import com.instock.fieldforce.db.BgGpsDatabase
import com.instock.fieldforce.db.BgGpsPoint

class LocationForegroundService : Service() {
    private val CHANNEL_ID = "fieldforce_location_channel"
    private val NOTIF_ID = 8472
    private lateinit var fusedClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    // Use Room DB for background points
    private val writeExecutor = java.util.concurrent.Executors.newSingleThreadExecutor()
    private var db: BgGpsDatabase? = null

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()

        // Initialize DB instance (lazy-backed)
        try {
            db = BgGpsDatabase.getInstance(applicationContext)
        } catch (e: Exception) {
            // best-effort
            db = null
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) {
                    persistLocationToDb(loc)
                }
            }
        }
    }

    private fun persistLocationToDb(loc: Location) {
        val dao = db?.bgGpsPointDao() ?: return
        val point = BgGpsPoint(
            latitude = loc.latitude,
            longitude = loc.longitude,
            accuracy = loc.accuracy,
            timestamp = loc.time,
            processed = false
        )
        writeExecutor.execute {
            try {
                dao.insert(point)
            } catch (e: Exception) {
                // ignore write errors for PoC
            }
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
        try {
            writeExecutor.shutdownNow()
        } catch (_: Exception) {}
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
