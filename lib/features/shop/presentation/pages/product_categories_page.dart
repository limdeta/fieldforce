import 'package:flutter/material.dart';
import 'package:fieldforce/shared/presentation/widgets/home_icon_button.dart';

/// Страница категорий прайса (заглушка)
class ProductCategoriesPage extends StatelessWidget {
  const ProductCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории прайса'),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        actions: const [
          // Кнопка домой (скрывается автоматически если уже на домашней странице)
          HomeIconButton(),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Категории прайса',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Здесь будут отображаться категории товаров',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
