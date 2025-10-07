abstract class Job {
  String get id;
  String get type;
  DateTime get createdAt;

  /// Дополнительные данные, необходимые обработчику job.
  Map<String, dynamic> toJson();
}
