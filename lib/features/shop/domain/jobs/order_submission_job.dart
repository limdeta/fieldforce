import 'package:fieldforce/app/jobs/job.dart';

class OrderSubmissionJob implements Job {
  static const String jobType = 'order.submit';

  @override
  final String id;

  @override
  String get type => jobType;

  final int orderId;

  final Map<String, dynamic> payload;

  @override
  final DateTime createdAt;

  const OrderSubmissionJob({
    required this.id,
    required this.orderId,
    required this.payload,
    required this.createdAt,
  });

  factory OrderSubmissionJob.create({
    required String id,
    required int orderId,
    required Map<String, dynamic> payload,
    DateTime? createdAt,
  }) {
    return OrderSubmissionJob(
      id: id,
      orderId: orderId,
      payload: payload,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory OrderSubmissionJob.fromJson(Map<String, dynamic> json) {
    return OrderSubmissionJob(
      id: json['id'] as String,
      orderId: json['orderId'] as int,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
