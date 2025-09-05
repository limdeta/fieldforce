import 'package:flutter/material.dart';

enum GpsToggleState {
  off,        // Зеленый: GPS выключен (play)
  connecting, // Желтый: идет подключение
  on          // Красный: GPS включен (pause)
}

class GpsToggleButton extends StatelessWidget {
  final GpsToggleState state;
  final VoidCallback onPressed;
  final double size;

  const GpsToggleButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    bool isActive;

    switch (state) {
      case GpsToggleState.off:
        color = Colors.green;
        icon = Icons.play_circle_fill;
        isActive = true;
        break;
      case GpsToggleState.connecting:
        color = Colors.amber;
        icon = Icons.sync;
        isActive = false;
        break;
      case GpsToggleState.on:
        color = Colors.red;
        icon = Icons.pause_circle_filled;
        isActive = true;
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
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
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
