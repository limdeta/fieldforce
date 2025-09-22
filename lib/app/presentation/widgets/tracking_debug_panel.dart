import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:get_it/get_it.dart';

/// Debug панель для отслеживания состояния GPS трекинга
/// Показывается только при включенном showTrackingDebugInfo
class TrackingDebugPanel extends StatelessWidget {
  const TrackingDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showTrackingDebugInfo) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      left: 16,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🐛 GPS Debug Panel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<TrackingBloc, TrackingState>(
              builder: (context, state) {
                return _buildTrackingInfo(state);
              },
            ),
            const SizedBox(height: 8),
            _buildGpsInfo(),
            const SizedBox(height: 8),
            _buildServiceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(TrackingState state) {
    String stateText;
    Color stateColor;
    
    if (state is TrackingOff) {
      stateText = 'OFF';
      stateColor = Colors.red;
    } else if (state is TrackingStarting) {
      stateText = 'STARTING...';
      stateColor = Colors.yellow;
    } else if (state is TrackingOn) {
      stateText = 'ON';
      stateColor = Colors.green;
      if (state.latitude != null && state.longitude != null) {
        stateText += '\nLat: ${state.latitude!.toStringAsFixed(6)}';
        stateText += '\nLng: ${state.longitude!.toStringAsFixed(6)}';
        if (state.bearing != null) {
          stateText += '\nBearing: ${state.bearing!.toStringAsFixed(1)}°';
        }
      }
    } else if (state is TrackingNoUser) {
      stateText = 'NO USER';
      stateColor = Colors.grey;
    } else {
      stateText = 'UNKNOWN';
      stateColor = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 TrackingBloc State:',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
        ),
        Text(
          stateText,
          style: TextStyle(color: stateColor, fontSize: 11, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildGpsInfo() {
    final gpsManager = GetIt.instance<GpsDataManager>();
    final configInfo = gpsManager.getConfigInfo();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🛰️ GPS Manager:',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
        ),
        Text(
          'Mode: ${configInfo['mode']}',
          style: const TextStyle(color: Colors.cyan, fontSize: 11, fontFamily: 'monospace'),
        ),
        Text(
          'Initialized: ${configInfo['isInitialized']}',
          style: TextStyle(
            color: configInfo['isInitialized'] == true ? Colors.green : Colors.red,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    final trackingService = GetIt.instance<LocationTrackingServiceBase>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏃 Tracking Service:',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
        ),
        Text(
          'isTracking: ${trackingService.isTracking}',
          style: TextStyle(
            color: trackingService.isTracking ? Colors.green : Colors.red,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'currentTrack: ${trackingService.currentTrack?.id ?? 'null'}',
          style: TextStyle(
            color: trackingService.currentTrack != null ? Colors.green : Colors.red,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Environment: ${AppConfig.environment.name.toUpperCase()}',
          style: TextStyle(
            color: AppConfig.isProd ? Colors.orange : Colors.lightBlue,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}