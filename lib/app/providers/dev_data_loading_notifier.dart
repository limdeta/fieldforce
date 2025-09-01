import 'package:flutter/foundation.dart';

enum DevDataLoadingState {
  idle,
  loading,
  loaded,
  error,
}

class DevDataLoadingNotifier extends ValueNotifier<DevDataLoadingState> {
  DevDataLoadingNotifier() : super(DevDataLoadingState.idle);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading() {
    value = DevDataLoadingState.loading;
    _errorMessage = null;
  }

  void setLoaded() {
    value = DevDataLoadingState.loaded;
    _errorMessage = null;
  }

  void setError(String error) {
    value = DevDataLoadingState.error;
    _errorMessage = error;
  }

  void reset() {
    value = DevDataLoadingState.idle;
    _errorMessage = null;
  }
}

/// Глобальный экземпляр для отслеживания состояния загрузки dev данных
final devDataLoadingNotifier = DevDataLoadingNotifier();