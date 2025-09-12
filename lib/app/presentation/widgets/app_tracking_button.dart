import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/widgets/tracking_toggle_button.dart';
import 'package:fieldforce/app/services/app_session_service.dart';

/// App-слой обертка для TrackingToggleButton
class AppTrackingButton extends StatelessWidget {
  final double size;

  const AppTrackingButton({
    super.key,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        return TrackingToggleButton(
          state: state,
          size: size,
          onPressed: () {
            // Если пользователя нет, пытаемся получить из сессии
            if (state is TrackingNoUser) {
              final currentSession = AppSessionService.currentSession;
              if (currentSession?.appUser != null) {
                context.read<TrackingBloc>().add(TrackingStart(currentSession!.appUser));
                return;
              }
            }

            context.read<TrackingBloc>().add(TrackingTogglePressed());
          },
        );
      },
    );
  }
}
