import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/widgets/tracking_toggle_button.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:logging/logging.dart';

/// App-слой обертка для TrackingToggleButton
class AppTrackingButton extends StatelessWidget {
  final double size;

  const AppTrackingButton({
    super.key,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final _logger = Logger('AppTrackingButton');
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        // ИСПРАВЛЕНО: Всегда проверяем и устанавливаем пользователя если его нет
        if (state is TrackingNoUser) {
          final currentSession = AppSessionService.currentSession;
          if (currentSession?.appUser != null) {
            // Устанавливаем пользователя без запуска трекинга
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<TrackingBloc>().setUser(currentSession!.appUser);
            });
          }
        }
        
        return TrackingToggleButton(
          state: state,
          size: size,
          onPressed: () async {
            // Determine if this action will start tracking
            final willStart = state is TrackingNoUser || state is TrackingOff;

            Future<void> proceedStart() async {
              if (state is TrackingNoUser) {
                final currentSession = AppSessionService.currentSession;
                if (currentSession?.appUser != null) {
                  context.read<TrackingBloc>().add(TrackingStart(currentSession!.appUser));
                  return;
                }
              }
              _logger.info('AppTrackingButton: dispatching TrackingTogglePressed (state=${state.runtimeType})');
              context.read<TrackingBloc>().add(TrackingTogglePressed());
            }

            if (willStart) {
              // Do not show an extra in-app dialog here. Instead dispatch
              // immediately so the centralized permission flow in
              // GpsDataManager.startGps() will call Geolocator.requestPermission()
              // and trigger the native system permission dialog.
              _logger.info('AppTrackingButton: starting tracking; dispatching to TrackingBloc to trigger native permission prompt');
              if (state is TrackingNoUser) {
                final currentSession = AppSessionService.currentSession;
                if (currentSession?.appUser != null) {
                  context.read<TrackingBloc>().add(TrackingStart(currentSession!.appUser));
                }
              } else {
                context.read<TrackingBloc>().add(TrackingTogglePressed());
              }
            } else {
              // Not starting - proceed normally
              await proceedStart();
            }
          },
        );
      },
    );
  }
}
