import 'dart:convert';

import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';

/// Синхронизирует категории через JSON API (fallback — локальная фикстура).
class SyncCategoriesUseCase {
  SyncCategoriesUseCase({
    required SessionManager sessionManager,
    required CategoryRepository categoryRepository,
  })  : _sessionManager = sessionManager,
        _categoryRepository = categoryRepository;

  static final Logger _logger = Logger('SyncCategoriesUseCase');

  final SessionManager _sessionManager;
  final CategoryRepository _categoryRepository;

  Future<Either<Failure, SyncReport>> call() async {
    final start = DateTime.now();

    try {
      final categoriesJson = await _loadCategoriesJson();
      final categories = categoriesJson
          .map<Category>((dynamic json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      final saveResult = await _categoryRepository.saveCategories(categories);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) {
          final duration = DateTime.now().difference(start);
          final description = categories.isEmpty
              ? 'Категории не изменились'
              : 'Обновлено ${categories.length} категорий';

          return Right(
            SyncReport(
              processedCount: categories.length,
              duration: duration,
              description: description,
              details: const <String, dynamic>{},
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Ошибка синхронизации категорий', e, stackTrace);
      return Left(GeneralFailure('Ошибка синхронизации категорий: $e', details: stackTrace));
    }
  }

  Future<List<dynamic>> _loadCategoriesJson() async {
    final url = AppConfig.categoriesApiUrl;

    if (url.isEmpty) {
      _logger.info('categoriesApiUrl не настроен, используем локальную фикстуру категорий');
      final raw = await rootBundle.loadString('assets/fixtures/categories.json');
      return jsonDecode(raw) as List<dynamic>;
    }

    final client = await _sessionManager.getSessionClient();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'FieldForce-Mobile/1.0',
      ...await _sessionManager.getSessionHeaders(),
    };

    final response = await client
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
  _logger.warning('Сервер вернул статус ${response.statusCode} при загрузке категорий');
  throw Exception('Не удалось загрузить категории: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> && decoded['categories'] is List) {
      return decoded['categories'] as List<dynamic>;
    }

    throw const ValidationFailure('Неверный формат JSON категорий');
  }
}
