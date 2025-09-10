import 'package:flutter/material.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import '../bloc/working_day_mode_bloc.dart';

/// Виджет для отображения активного рабочего дня
class ActiveWorkingDayWidget extends StatelessWidget {
  final ActiveWorkingDayState state;

  const ActiveWorkingDayWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок активного дня
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 8),
              Text(
                'Активный рабочий день',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Информация о дне
          _buildWorkDayInfo(state.currentWorkDay),
          const SizedBox(height: 12),

          // Информация о треке
          if (state.activeTrack != null) ...[
            _buildTrackInfo(state.activeTrack!),
            const SizedBox(height: 12),
          ],

          // Статус трекинга
          _buildTrackingStatus(state.isTrackingActive),
          const SizedBox(height: 16),

          // Кнопки управления
          _buildControlButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildWorkDayInfo(WorkDay workDay) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Маршрут: ${workDay.route?.name ?? "Неизвестен"}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Дата: ${_formatDate(workDay.date)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${workDay.id}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(UserTrack track) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 4),
              Text(
                'Текущий трек',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Точек: ${track.totalPoints}'),
                    Text('Расстояние: ${(track.totalDistanceKm / 1000).toStringAsFixed(1)} км'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Время: ${_formatDuration(track.totalDuration)}'),
                    Text('Обновлен: ${_formatTime(track.endTime ?? track.startTime)}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatus(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'GPS активен' : 'GPS остановлен',
            style: TextStyle(
              color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, ActiveWorkingDayState state) {
    return Row(
      children: [
        if (!state.isTrackingActive) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Здесь будет логика запуска трекинга
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Запуск трекинга...')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Запустить'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Здесь будет логика паузы трекинга
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пауза трекинга...')),
                );
              },
              icon: const Icon(Icons.pause),
              label: const Text('Пауза'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Здесь будет логика остановки трекинга
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Остановка трекинга...')),
                );
              },
              icon: const Icon(Icons.stop),
              label: const Text('Стоп'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}ч ${minutes}м';
  }
}

/// Виджет для просмотра исторических данных
class ViewingWorkingDayWidget extends StatelessWidget {
  final ViewingWorkingDayState state;

  const ViewingWorkingDayWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок просмотрового режима
          Row(
            children: [
              Icon(Icons.history, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Просмотр рабочего дня',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Информация о просматриваемом дне
          _buildWorkDayInfo(state.viewingWorkDay),
          const SizedBox(height: 12),

          // Информация об историческом треке
          if (state.historicalTrack != null) ...[
            _buildHistoricalTrackInfo(state.historicalTrack!),
            const SizedBox(height: 16),
          ],

          // Кнопка переключения в активный режим (если возможно)
          if (state.canSwitchToActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Переключение в активный режим...')),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Сделать активным'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkDayInfo(WorkDay workDay) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Маршрут: ${workDay.route?.name ?? "Неизвестен"}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Дата: ${_formatDate(workDay.date)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _isCompleted(workDay) ? Icons.check_circle : Icons.schedule,
                color: _isCompleted(workDay) ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _isCompleted(workDay) ? 'Завершен' : 'Не завершен',
                style: TextStyle(
                  color: _isCompleted(workDay) ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTrackInfo(UserTrack track) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.purple.shade700, size: 16),
              const SizedBox(width: 4),
              Text(
                'Статистика трека',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Точек: ${track.totalPoints}'),
                    Text('Расстояние: ${(track.totalDistanceKm / 1000).toStringAsFixed(1)} км'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Время: ${_formatDuration(track.totalDuration)}'),
                    Text('Средняя скорость: ${_calculateAverageSpeed(track)} км/ч'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isCompleted(WorkDay workDay) {
    // Логика определения завершенности дня
    // Пока простая проверка - если день не сегодняшний, считаем завершенным
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workDayDate = DateTime(workDay.date.year, workDay.date.month, workDay.date.day);
    return workDayDate.isBefore(today);
  }

  String _calculateAverageSpeed(UserTrack track) {
    if (track.totalDuration.inMinutes == 0) return '0.0';
    final speedKmH = track.totalDistanceKm / (track.totalDuration.inMinutes / 60);
    return speedKmH.toStringAsFixed(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}ч ${minutes}м';
  }
}
