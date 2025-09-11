import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/widgets/gps_toggle_button.dart';

// События
abstract class GpsEvent {}
class GpsTogglePressed extends GpsEvent {}
class GpsStart extends GpsEvent {}
class GpsStop extends GpsEvent {}

// Состояния
abstract class GpsState {
  final GpsToggleState toggleState;
  const GpsState(this.toggleState);
}
class GpsOff extends GpsState {
  const GpsOff() : super(GpsToggleState.off);
}
class GpsConnecting extends GpsState {
  const GpsConnecting() : super(GpsToggleState.connecting);
}
class GpsOn extends GpsState {
  const GpsOn() : super(GpsToggleState.on);
}

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  final GpsDataManager gpsManager;

  GpsBloc(this.gpsManager) : super(const GpsOff()) {
    on<GpsTogglePressed>((event, emit) async {
      if (state is GpsOff) {
        emit(const GpsConnecting());
        final started = await gpsManager.startGps();
        if (started) {
          emit(const GpsOn());
        } else {
          emit(const GpsOff());
        }
      } else if (state is GpsOn) {
        gpsManager.stopGps();
        emit(const GpsOff());
      }
    });

    on<GpsStart>((event, emit) async {
      emit(const GpsConnecting());
      final started = await gpsManager.startGps();
      if (started) {
        emit(const GpsOn());
      } else {
        emit(const GpsOff());
      }
    });

    on<GpsStop>((event, emit) {
      gpsManager.stopGps();
      emit(const GpsOff());
    });
  }
}








