import 'dart:async';
import 'dart:math';

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
  Future<Either<Failure, int?>> submitOrder(Map<String, dynamic> orderJson) async {
    _logger.info('Mock submit order ${orderJson['mobileOrderId']}');
    await Future.delayed(_responseDelay);
    // Mock возвращает фикстивный serverId
    return Right(Random().nextInt(10000) + 1000);
  }
}
