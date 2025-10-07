import 'dart:async';

import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

class MockOrderApiService implements OrderApiService {
  MockOrderApiService({Duration responseDelay = const Duration(milliseconds: 200)})
      : _responseDelay = responseDelay;

  static final Logger _logger = Logger('MockOrderApiService');

  final Duration _responseDelay;

  @override
  Future<Either<Failure, void>> submitOrder(Map<String, dynamic> orderJson) async {
    _logger.info('Mock submit order ${orderJson['id'] ?? orderJson['orderId']}');
    await Future.delayed(_responseDelay);
    return const Right(null);
  }
}
