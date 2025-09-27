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
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.instock.fieldforce.db.BgGpsDatabase
import com.instock.fieldforce.db.BgGpsPoint
import java.util.concurrent.Executors

class OptimizedLocationForegroundService : Service() {
    companion object {
        private const val CHANNEL_ID = "fieldforce_location_channel"
        private const val NOTIF_ID = 8472
        private const val TAG = "LocationFGService"
        
        // Action extras
        const val EXTRA_MIN_DISTANCE = "minDistance"
        const val EXTRA_INTERVAL_MILLIS = "intervalMillis"
        const val EXTRA_PRIORITY = "priority" // "high", "balanced", "low"
    }
    
    private lateinit var fusedClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private val writeExecutor = Executors.newSingleThreadExecutor()
    private var db: BgGpsDatabase? = null
    
    // Configurable parameters
    private var minDistance = 5.0f
    private var intervalMillis = 15000L
    private var priority = Priority.PRIORITY_BALANCED_POWER_ACCURACY
    
    // Batching for efficiency
    private val locationBatch = mutableListOf<BgGpsPoint>()
    private val batchSize = 10
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate")
        
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()

        try {
            db = BgGpsDatabase.getInstance(applicationContext)
            Log.d(TAG, "Database initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize database", e)
            db = null
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                Log.d(TAG, "Received ${result.locations.size} locations")
                for (loc in result.locations) {
                    persistLocationToDb(loc)
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand called")
        
        // Extract parameters from intent
        intent?.let { i ->
            minDistance = i.getFloatExtra(EXTRA_MIN_DISTANCE, 5.0f)
            intervalMillis = i.getLongExtra(EXTRA_INTERVAL_MILLIS, 15000L)
            
            val priorityStr = i.getStringExtra(EXTRA_PRIORITY) ?: "balanced"
            priority = when (priorityStr) {
                "high" -> Priority.PRIORITY_HIGH_ACCURACY
                "low" -> Priority.PRIORITY_PASSIVE
                else -> Priority.PRIORITY_BALANCED_POWER_ACCURACY
            }
            
            Log.d(TAG, "Config: minDistance=$minDistance, interval=${intervalMillis}ms, priority=$priorityStr")
        }
        
        val notification = buildNotification()
        startForeground(NOTIF_ID, notification)

        startLocationUpdates()
        return START_STICKY
    }

    private fun persistLocationToDb(loc: Location) {
        val dao = db?.bgGpsPointDao()
        if (dao == null) {
            Log.w(TAG, "Database not available, dropping location")
            return
        }
        
        val point = BgGpsPoint(
            latitude = loc.latitude,
            longitude = loc.longitude,
            accuracy = loc.accuracy,
            timestamp = loc.time,
            processed = false
        )
        
        synchronized(locationBatch) {
            locationBatch.add(point)
            
            // Batch insert for efficiency
            if (locationBatch.size >= batchSize) {
                val batch = locationBatch.toList()
                locationBatch.clear()
                
                writeExecutor.execute {
                    try {
                        dao.insertBatch(batch)
                        Log.d(TAG, "Persisted batch of ${batch.size} locations")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to persist location batch", e)
                        // TODO: Implement retry logic or alert mechanism
                    }
                }
            }
        }
    }
    
    private fun flushPendingBatch() {
        synchronized(locationBatch) {
            if (locationBatch.isNotEmpty()) {
                val batch = locationBatch.toList()
                locationBatch.clear()
                
                writeExecutor.execute {
                    try {
                        db?.bgGpsPointDao()?.insertBatch(batch)
                        Log.d(TAG, "Flushed final batch of ${batch.size} locations")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to flush final batch", e)
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "Service onDestroy")
        stopLocationUpdates()
        flushPendingBatch()
        
        try {
            writeExecutor.shutdown()
            if (!writeExecutor.awaitTermination(5, java.util.concurrent.TimeUnit.SECONDS)) {
                writeExecutor.shutdownNow()
            }
        } catch (e: Exception) {
            Log.w(TAG, "Executor shutdown interrupted", e)
        }
        
        super.onDestroy()
    }

    private fun startLocationUpdates() {
        try {
            val req = LocationRequest.create().apply {
                interval = intervalMillis
                fastestInterval = intervalMillis / 3 // Allow some flexibility
                priority = this@OptimizedLocationForegroundService.priority
                smallestDisplacement = minDistance
            }
            
            Log.d(TAG, "Starting location updates with: $req")
            fusedClient.requestLocationUpdates(req, locationCallback, Looper.getMainLooper())
            
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing location permissions", e)
            stopSelf()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start location updates", e)
            stopSelf()
        }
    }

    private fun stopLocationUpdates() {
        try {
            fusedClient.removeLocationUpdates(locationCallback)
            Log.d(TAG, "Location updates stopped")
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping location updates", e)
        }
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, 
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Fieldforce GPS Tracking")
            .setContentText("Собираем GPS данные в фоне (интервал: ${intervalMillis/1000}с)")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_LOCATION_SHARING)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, 
                "GPS Tracking", 
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Фоновое отслеживание местоположения для полевых работ"
                setShowBadge(false)
            }
            
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}