import 'package:flutter/material.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';

enum TrackingToggleState {
  off,        // Зеленый: трекинг выключен (play)
  starting,   // Желтый: идет запуск трекинга
  on,         // Красный: трекинг включен (pause)
  noUser      // Серый: пользователь не задан
}

class TrackingToggleButton extends StatelessWidget {
  final TrackingState state;
  final VoidCallback onPressed;
  final double size;

  const TrackingToggleButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.size = 56.0,
  });

  TrackingToggleState get _toggleState {
    if (state is TrackingOff) return TrackingToggleState.off;
    if (state is TrackingStarting) return TrackingToggleState.starting;
    if (state is TrackingOn) return TrackingToggleState.on;
    if (state is TrackingNoUser) return TrackingToggleState.noUser;
    return TrackingToggleState.off;
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    bool isActive;

    switch (_toggleState) {
      case TrackingToggleState.off:
        color = Colors.green;
        icon = Icons.play_circle_fill;
        isActive = true;
        break;
      case TrackingToggleState.starting:
        color = Colors.amber;
        icon = Icons.sync;
        isActive = false;
        break;
      case TrackingToggleState.on:
        color = Colors.red;
        icon = Icons.pause_circle_filled;
        isActive = true;
        break;
      case TrackingToggleState.noUser:
        color = Colors.grey;
        icon = Icons.person_off;
        isActive = false;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onPressed : null,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: _toggleState == TrackingToggleState.starting
                  ? SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: size * 0.6,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
