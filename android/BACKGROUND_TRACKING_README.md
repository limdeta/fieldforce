Android background tracking plan (developer notes)

Goal: Support reliable low-battery background GPS updates by running a native ForegroundService that forwards location updates to Flutter via MethodChannel.

High level:
- Implement a Kotlin ForegroundService at: android/app/src/main/kotlin/com/instock/fieldforce/OptimizedLocationForegroundService.kt
- Manifest: a service entry has already been added for
  com.instock.fieldforce.OptimizedLocationForegroundService (foregroundServiceType="location").
- Permissions added: ACCESS_BACKGROUND_LOCATION, FOREGROUND_SERVICE.

MethodChannel contract (native -> Flutter):
- Channel name: "fieldforce/background_location"
- Methods/events:
  - "onLocation": sends a map {"latitude": double, "longitude": double, "accuracy": double, "timestamp": long, "isBackground": true}
  - "onStatus": "started" | "stopped" | "permission_denied" | "error"
  - Flutter can call: "startService" {"minDistance": double, "intervalMillis": int} and "stopService".

Kotlin notes:
- Use FusedLocationProviderClient (com.google.android.gms:play-services-location).
- Create NotificationChannel and a persistent notification with actions (pause/stop) so the service is less likely to be killed.
- Use startForeground with Notification and ensure the service only runs while tracking is active.
- Use ActivityRecognition (optional) to detect motion vs stationary and adjust LocationRequest priorities.

Flutter wiring:
- Extend GpsDataManager to call platform channel to start/stop the native service when background=true in startGps.
- Platform messages from native service should be forwarded into the existing position stream so TrackManager and LocationTrackingService receive the updates unchanged.

Security & privacy:
- Ask user for background permission separately (ACCESS_BACKGROUND_LOCATION) and show an explanation UI.
- Provide setting to disable background tracking.

Testing:
- Test on Android 11/12/13 devices. Use `adb logcat` and `adb shell dumpsys location` to verify updates while screen is off.

This is a minimal, pragmatic plan — we can iterate to add adaptive sampling / activity detection after the basic service works.
