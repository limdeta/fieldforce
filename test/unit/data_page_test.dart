import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/app/presentation/pages/data_page.dart';

void main() {
  testWidgets('DataPage загружается корректно', (WidgetTester tester) async {
    // Создаем DataPage
    await tester.pumpWidget(
      const MaterialApp(
        home: DataPage(),
      ),
    );

    // Проверяем, что страница загружается
    expect(find.text('Управление данными'), findsOneWidget);
    expect(find.text('Синхронизировать продукты'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}