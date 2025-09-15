import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';

/// Авторизация тестового пользователя
Future<void> loginAsTestUser(WidgetTester tester) async {
  await ensureLoggedInAsDevUser();

  // Предполагаем, что после авторизации мы находимся на главной странице
  // Если нужно, добавьте здесь навигацию к главной странице
}

/// Переход в каталог
Future<void> navigateToCatalog(WidgetTester tester) async {
  // Ищем кнопку или элемент для перехода в каталог
  final catalogButton = find.text('Каталог');
  expect(catalogButton, findsOneWidget);
  await tester.tap(catalogButton);
  await tester.pumpAndSettle();
}

/// Раскрытие категории
Future<void> expandCategory(WidgetTester tester, String categoryName) async {
  final categoryTile = find.ancestor(
    of: find.text(categoryName),
    matching: find.byType(ExpansionTile),
  );

  if (categoryTile.evaluate().isNotEmpty) {
    // Просто нажимаем на категорию, чтобы раскрыть/свернуть
    await tester.tap(find.text(categoryName));
    await tester.pumpAndSettle();
  }
}

/// Нажатие на категорию
Future<void> tapCategory(WidgetTester tester, String categoryName) async {
  final categoryText = find.text(categoryName);
  expect(categoryText, findsOneWidget);
  await tester.tap(categoryText);
  await tester.pumpAndSettle();
}

// Инжектим app_user в сессию. Не забывать порядок вызовов (может дёрнуть юзера из бд предыдущего теста/запуска)
Future<void> ensureLoggedInAsDevUser({String phoneContains = '7-999-111-2233'}) async {
  final userRepo = GetIt.instance<UserRepository>();
  final phoneEither = PhoneNumber.create(phoneContains);
  if (phoneEither.isLeft()) {
    throw StateError('Invalid phone format: $phoneContains');
  }
  final phone = phoneEither.fold((l) => throw StateError(l.toString()), (r) => r);
  final userResult = await userRepo.getUserByPhoneNumber(phone);
  if (userResult.isLeft()) {
    throw StateError('No user found with phone "$phoneContains": ${userResult.fold((l) => l, (r) => '')}');
  }
  final user = userResult.fold((l) => throw StateError(l.toString()), (r) => r);

  final sessionEither = UserSession.create(
    user: user,
    rememberMe: true,
  );

  if (sessionEither.isLeft()) {
    throw StateError('Failed to create UserSession: ${sessionEither.fold((l) => l, (r) => '')}');
  }

  final userSession = sessionEither.fold((l) => throw StateError(l.toString()), (r) => r);

  final appSessionResult = await AppSessionService.createFromSecuritySession(userSession);
  if (appSessionResult.isLeft()) {
    throw StateError('Failed to create AppSession: ${appSessionResult.fold((l) => l, (r) => '')}');
  }
}