import 'package:equatable/equatable.dart';

/// Унифицированное описание результата шага синхронизации.
///
/// [processedCount] — основная числовая метрика (например количество сущностей).
/// [duration] — длительность выполнения шага.
/// [description] — краткое человекочитаемое описание результата.
/// [details] — дополнительные метрики, например числа по разным сущностям.
class SyncReport extends Equatable {
  const SyncReport({
    required this.processedCount,
    required this.duration,
    this.description,
    this.details = const <String, dynamic>{},
  });

  final int processedCount;
  final Duration duration;
  final String? description;
  final Map<String, dynamic> details;

  SyncReport copyWith({
    int? processedCount,
    Duration? duration,
    String? description,
    Map<String, dynamic>? details,
  }) {
    return SyncReport(
      processedCount: processedCount ?? this.processedCount,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        processedCount,
        duration,
        description,
        details,
      ];
}
