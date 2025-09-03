import 'package:flutter/foundation.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'dart:async';
import '../../domain/entities/user_track.dart';
import '../usecases/get_user_tracks_usecase.dart';
import '../../../../../app/services/location_tracking_service.dart';
import 'package:get_it/get_it.dart';

/// Provider для управления состоянием треков пользователя
/// Объединяет исторические треки из БД с активным треком от LocationTrackingService
class UserTracksProvider extends ChangeNotifier {
  final GetUserTracksUseCase _getUserTracksUseCase;
  late final LocationTrackingService _locationTrackingService;
  
  List<UserTrack> _userTracks = [];
  UserTrack? _activeTrack;
  List<UserTrack> _completedTracks = [];
  bool _isLoading = false;
  String? _error;
  
  // Подписка на активный трек
  StreamSubscription<UserTrack>? _activeTrackSubscription;
  
  // Кэширование для предотвращения повторных запросов
  NavigationUser? _lastLoadedUser;
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  // Дебаунсинг для предотвращения частых обновлений UI
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  
  UserTracksProvider(this._getUserTracksUseCase) {
    _locationTrackingService = GetIt.instance<LocationTrackingService>();
    _subscribeToActiveTrack();
  }
  
  // Getters
  List<UserTrack> get userTracks => _userTracks;
  UserTrack? get activeTrack => _activeTrack;
  List<UserTrack> get completedTracks => _completedTracks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Загружает все треки пользователя (с кэшированием и дебаунсингом)
  Future<void> loadUserTracks(NavigationUser user) async {
    if (_lastLoadedUser?.id == user.id && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _cacheTimeout) {
      return;
    }
    
    // Отменяем предыдущий дебаунс таймер если есть
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(_debounceDelay, () async {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await _getUserTracksUseCase.call(user);
      
      result.fold(
        (failure) {
          _error = 'Ошибка загрузки треков: $failure';
          _isLoading = false;
          print('❌ UserTracksProvider: Ошибка загрузки треков: $failure');
          notifyListeners();
        },
        (tracks) {
          _userTracks = tracks;
          _activeTrack = tracks.where((track) => track.status.isActive).firstOrNull;
          _completedTracks = tracks.where((track) => track.status.name == 'completed').toList();
          _isLoading = false;
          
          // Обновляем кэш
          _lastLoadedUser = user;
          _lastLoadTime = DateTime.now();
          
                // Убираем избыточные логи для dev режима
      // print('✅ UserTracksProvider: Загружено ${loaded.length} треков для ${user.fullName}');
          notifyListeners();
        },
      );
    });
  }
  
  /// Загружает треки пользователя для конкретного дня
  Future<void> loadUserTracksForDate(NavigationUser user, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _getUserTracksUseCase.call(user);
    
    result.fold(
      (failure) {
        _error = 'Ошибка загрузки треков: $failure';
        _isLoading = false;
        print('❌ UserTracksProvider: Ошибка загрузки треков для даты: $failure');
        notifyListeners();
      },
      (allTracks) {
        // Фильтруем треки по дню
        final targetDate = DateTime(date.year, date.month, date.day);
        final filteredTracks = allTracks.where((track) {
          final trackDate = DateTime(
            track.startTime.year, 
            track.startTime.month, 
            track.startTime.day
          );
          return trackDate.isAtSameMomentAs(targetDate);
        }).toList();
        
        _userTracks = filteredTracks;
        _activeTrack = filteredTracks.where((track) => track.status.isActive).firstOrNull;
        _completedTracks = filteredTracks.where((track) => track.status.name == 'completed').toList();
        _isLoading = false;
        
        print('✅ UserTracksProvider: Загружено ${filteredTracks.length} треков для ${date.day}.${date.month}.${date.year}');
        notifyListeners();
      },
    );
  }

  /// Очищает треки (при выходе пользователя)
  void clearTracks() {
    _debounceTimer?.cancel(); // Отменяем таймер для экономии ресурсов
    _userTracks.clear();
    _activeTrack = null;
    _completedTracks.clear();
    _error = null;
    _lastLoadedUser = null;
    _lastLoadTime = null;
    print('🧹 UserTracksProvider: Треки и кэш очищены');
    notifyListeners();
  }

  /// Подписывается на активный трек от LocationTrackingService
  void _subscribeToActiveTrack() {
    _activeTrackSubscription = _locationTrackingService.trackUpdateStream.listen(
      (activeTrack) {
        print('📡 UserTracksProvider: Получен активный трек ${activeTrack.id} (${activeTrack.totalPoints} точек)');
        _updateActiveTrack(activeTrack);
      },
      onError: (error) {
        print('❌ UserTracksProvider: Ошибка получения активного трека: $error');
      },
    );
  }

  /// УПРОЩЕННАЯ ЛОГИКА: Просто обновляем трек без объединения
  void _updateActiveTrack(UserTrack activeTrack) {
    print('📡 UserTracksProvider: Получен активный трек ${activeTrack.id} (${activeTrack.totalPoints} точек)');
    
    // Ищем трек с таким же ID в списке
    final existingIndex = _userTracks.indexWhere((track) => track.id == activeTrack.id);
    
    if (existingIndex != -1) {
      // Обновляем существующий трек
      _userTracks[existingIndex] = activeTrack;
      print('📊 UserTracksProvider: Обновлен трек ${activeTrack.id} (${activeTrack.totalPoints} точек)');
    } else {
      // Добавляем новый трек
      _userTracks.add(activeTrack);
      print('📊 UserTracksProvider: Добавлен новый трек ${activeTrack.id} (${activeTrack.totalPoints} точек)');
    }
    
    _activeTrack = activeTrack;
    notifyListeners();
  }

  /// Обновляет существующий активный трек в списке (СОХРАНЯЯ ОБЪЕДИНЕНИЕ)
  @override
  void dispose() {
    _debounceTimer?.cancel(); // Очищаем таймер при удалении провайдера
    _activeTrackSubscription?.cancel(); // Очищаем подписку на активный трек
    super.dispose();
  }
}
