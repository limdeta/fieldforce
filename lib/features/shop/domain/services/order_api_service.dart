import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Контракт взаимодействия с внешним API заказов.
///
/// Вся работа с сетью и сериализацией заказа в JSON находиться за этим интерфейсом.
/// Домен оперирует только `Order` и `Either`, не зная о деталях транспорта.
abstract class OrderApiService {
  /// Отправляет заказ на внешнюю систему.
  ///
  /// Возвращает `Right(int?)` с serverId при успешной отправке.
  /// В противном случае возвращает `Left(Failure)` с описанием ошибки.
  Future<Either<Failure, int?>> submitOrder(Map<String, dynamic> orderJson);
}
