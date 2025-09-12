import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';
import 'package:fieldforce/features/shop/presentation/trading_point_detail_page.dart';

/// Страница со списком торговых точек закрепленных за сотрудником
class TradingPointsListPage extends StatefulWidget {
  const TradingPointsListPage({super.key});

  @override
  State<TradingPointsListPage> createState() => _TradingPointsListPageState();
}

class _TradingPointsListPageState extends State<TradingPointsListPage> {
  final GetEmployeeTradingPointsUseCase _getTradingPointsUseCase = 
      GetIt.instance<GetEmployeeTradingPointsUseCase>();
  
  List<TradingPoint> _tradingPoints = [];
  List<TradingPoint> _filteredTradingPoints = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTradingPoints();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTradingPoints = List.from(_tradingPoints);
      } else {
        _filteredTradingPoints = _tradingPoints.where((tp) =>
          tp.name.toLowerCase().contains(query) ||
          (tp.inn?.toLowerCase().contains(query) ?? false)
        ).toList();
      }
    });
  }

  Future<void> _loadTradingPoints() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Получаем текущую сессию
      final sessionResult = await AppSessionService.getCurrentAppSession();
      if (sessionResult.isLeft()) {
        setState(() {
          _error = 'Не удалось получить сессию пользователя';
          _isLoading = false;
        });
        return;
      }

      final session = sessionResult.fold((l) => throw Exception(l), (r) => r);
      if (session == null) {
        setState(() {
          _error = 'Пользователь не найден в сессии';
          _isLoading = false;
        });
        return;
      }

      // Получаем торговые точки сотрудника 
      // TODO переписать .session.appUser.employee
      final result = await _getTradingPointsUseCase.call(session.appUser.employee);
      
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (tradingPoints) {
          setState(() {
            _tradingPoints = tradingPoints;
            _filteredTradingPoints = List.from(tradingPoints);
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Торговые точки'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadTradingPoints,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по названию или ИНН...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          
          // Список торговых точек
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка торговых точек...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTradingPoints,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    // Если у пользователя нет торговых точек вообще
    if (_tradingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Торговые точки не назначены',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Если есть точки, но поиск не дал результатов
    if (_filteredTradingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Торговые точки не найдены',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить поисковый запрос',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTradingPoints,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredTradingPoints.length,
        itemBuilder: (context, index) {
          final tradingPoint = _filteredTradingPoints[index];
          return _buildTradingPointCard(tradingPoint);
        },
      ),
    );
  }

  Widget _buildTradingPointCard(TradingPoint tradingPoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.store,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          tradingPoint.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tradingPoint.inn != null) ...[
              const SizedBox(height: 4),
              Text(
                'ИНН: ${tradingPoint.inn}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'ID: ${tradingPoint.externalId}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TradingPointDetailPage(
                tradingPoint: tradingPoint,
              ),
            ),
          );
        },
      ),
    );
  }
}
