import 'package:fieldforce/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Tests', () {
    testWidgets('should navigate to login and test login scenarios', (tester) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle();

      // Ждем экран логина
      await _waitForLoginScreen(tester);

      expect(find.text('Вход в fieldforce'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(2));

      await _testInvalidLogin(tester);
      await _testValidLogin(tester);
    });
  });
}

Future<void> _waitForLoginScreen(WidgetTester tester) async {
  // Используем findsOneWidget с автоматическим ожиданием
  await tester.pumpAndSettle();

  // Если сразу не найден - ждем навигацию
  if (!tester.any(find.text('Вход в fieldforce'))) {
    await tester.pumpAndSettle();

    // Если все еще нет - возможно splash screen
    if (!tester.any(find.text('Вход в fieldforce'))) {
      // Pump несколько кадров для навигации со splash
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // Splash delay
      await tester.pumpAndSettle();
    }
  }

  expect(find.text('Вход в fieldforce'), findsOneWidget);
}

Future<void> _testInvalidLogin(WidgetTester tester) async {
  final phoneField = find.byType(TextFormField).first;
  final passwordField = find.byType(TextFormField).last;
  final loginButton = find.text('Войти');

  await tester.enterText(phoneField, '+7-000-000-0000');
  await tester.enterText(passwordField, 'wrongpassword');
  await tester.pumpAndSettle();

  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // Ждем появления ошибки
  expect(find.byType(SnackBar), findsOneWidget);
}

Future<void> _testValidLogin(WidgetTester tester) async {
  final phoneField = find.byType(TextFormField).first;
  final passwordField = find.byType(TextFormField).last;
  final loginButton = find.text('Войти');

  await tester.enterText(phoneField, '+7-999-111-2233');
  await tester.enterText(passwordField, 'password123');
  await tester.pumpAndSettle();

  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // Ждем исчезновения экрана логина (что-бы не проверять конкретный следующий экран а только логин)
  expect(find.text('Вход в fieldforce'), findsNothing);
}
