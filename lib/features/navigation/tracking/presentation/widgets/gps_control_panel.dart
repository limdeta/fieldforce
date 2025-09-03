import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../../app/services/location_tracking_service.dart';
import '../../domain/entities/navigation_user.dart';
import '../../data/fixtures/track_fixtures.dart' as fixtures;
import '../../../../shop/domain/entities/route.dart' as shop;

/// Виджет для управления GPS режимами в режиме разработки
/// 
/// Предоставляет интерфейс для:
/// - Переключения между реальным и мок GPS
/// - Запуска различных тестовых сценариев
/// - Мониторинга состояния трекинга
/// - Управления воспроизведением мок данных
class GpsControlPanel extends StatefulWidget {
  final NavigationUser user;
  final List<shop.Route> routes;
  
  const GpsControlPanel({
    super.key,
    required this.user,
    required this.routes,
  });

  @override
  State<GpsControlPanel> createState() => _GpsControlPanelState();
}

class _GpsControlPanelState extends State<GpsControlPanel> {
  final LocationTrackingService _trackingService = GetIt.instance<LocationTrackingService>();
  Map<String, dynamic>? _gpsInfo;
  Map<String, dynamic>? _playbackInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateInfo();
    
    // Обновляем информацию каждые 2 секунды
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateInfo();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateInfo() {
    setState(() {
      final gpsInfoString = _trackingService.getGpsInfo();
      _gpsInfo = {'status': gpsInfoString}; // Конвертируем String в Map
      _playbackInfo = _trackingService.getMockPlaybackInfo();
    });
  }

  Future<void> _executeAction(String actionName, Future<void> Function() action) async {
    setState(() => _isLoading = true);
    
    try {
      await action();
      _showSnackBar('$actionName выполнено успешно', Colors.green);
    } catch (e) {
      _showSnackBar('Ошибка: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
      _updateInfo();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gpsMode = _gpsInfo?['mode'] ?? 'unknown';
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой статуса
            Row(
              children: [
                Icon(
                  gpsMode.contains('real') ? Icons.gps_fixed : Icons.gps_not_fixed,
                  color: gpsMode.contains('real') ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'GPS Control Panel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (_isLoading) const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Информация о состоянии
            _buildStatusInfo(),
            
            const SizedBox(height: 16),
            
            // Прогресс воспроизведения (для мок режима)
            if (_playbackInfo != null) ...[
              _buildPlaybackProgress(),
              const SizedBox(height: 16),
            ],
            
            // Кнопки управления
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Режим GPS', _gpsInfo?['mode'] ?? 'unknown'),
          _buildInfoRow('Трекинг активен', _gpsInfo?['tracking_active'].toString() ?? 'false'),
          _buildInfoRow('ID трека', _gpsInfo?['current_track_id']?.toString() ?? 'нет'),
          if (_gpsInfo?['testConfig'] != null) ...[
            _buildInfoRow('Множитель скорости', _gpsInfo!['testConfig']['speedMultiplier'].toString()),
            _buildInfoRow('GPS шум', _gpsInfo!['testConfig']['addGpsNoise'].toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildPlaybackProgress() {
    final progress = _playbackInfo?['progress']?.toDouble() ?? 0.0;
    final currentIndex = _playbackInfo?['currentIndex'] ?? 0;
    final totalPoints = _playbackInfo?['totalPoints'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Прогресс воспроизведения', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('$currentIndex / $totalPoints'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Переключение на реальный GPS
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _executeAction(
            'Переключение на реальный GPS',
            () => _trackingService.enableRealGps(),
          ),
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Реальный GPS'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        
        // Тестовый режим
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _executeAction(
            'Запуск тестового режима',
            () => _startMockTracking(),
          ),
          icon: const Icon(Icons.bug_report),
          label: const Text('Тест режим'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        
        // Демо режим
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _executeAction(
            'Запуск демо режима',
            () => _startDemoMode(),
          ),
          icon: const Icon(Icons.play_circle_filled),
          label: const Text('Демо режим'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        
        // Остановить мок трекинг
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _executeAction(
            'Остановка мок трекинга',
            () => fixtures.TrackFixtures.stopMockTracking(),
          ),
          icon: const Icon(Icons.stop),
          label: const Text('Стоп'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Future<void> _startMockTracking() async {
    if (widget.routes.isEmpty) {
      throw Exception('Нет доступных маршрутов');
    }
    
    final route = widget.routes.first;
    
    await fixtures.TrackFixtures.startActiveMockTracking(
      user: widget.user,
      route: route,
      config: const fixtures.GpsTestConfig(
        mockDataPath: 'assets/data/tracks/continuation_scenario.json',
        speedMultiplier: 2.0,
        addGpsNoise: true,
        baseAccuracy: 4.0,
        startProgress: 0.6,
      ),
    );
  }

  Future<void> _startDemoMode() async {
    if (widget.routes.isEmpty) {
      throw Exception('Нет доступных маршрутов');
    }
    
    final route = widget.routes.first;
    
    await fixtures.TrackFixtures.startDemoMode(
      user: widget.user,
      route: route,
    );
  }
}
