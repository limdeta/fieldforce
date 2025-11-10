import 'package:fieldforce/features/shop/presentation/pages/trading_point_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';

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
  TradingPoint? _selectedTradingPoint;
  int? _selectedTradingPointId;
  bool _isSelecting = false;

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
          _selectedTradingPoint = null;
          _selectedTradingPointId = null;
        });
        return;
      }

      final selectedPoint = session.appUser.selectedTradingPoint;

      // Получаем торговые точки сотрудника 
      // TODO переписать .session.appUser.employee
      final result = await _getTradingPointsUseCase.call(session.appUser.employee);
      
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
            _selectedTradingPoint = selectedPoint;
            _selectedTradingPointId = selectedPoint?.id;
          });
        },
        (tradingPoints) {
          setState(() {
            _tradingPoints = tradingPoints;
            _filteredTradingPoints = List.from(tradingPoints);
            _isLoading = false;
            _selectedTradingPoint = selectedPoint;
            _selectedTradingPointId = selectedPoint?.id;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
        _selectedTradingPoint = null;
        _selectedTradingPointId = null;
      });
    }
  }

  Future<void> _syncSelectionFromSession() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();
    if (!mounted) return;

    sessionResult.fold(
      (_) {
        // Ошибку игнорируем здесь, пользователь уже видел сообщение на загрузке списка
      },
      (session) {
        setState(() {
          _selectedTradingPoint = session?.appUser.selectedTradingPoint;
          _selectedTradingPointId = session?.appUser.selectedTradingPointId;
        });
      },
    );
  }

  Future<void> _handleSelectTradingPoint(TradingPoint tradingPoint) async {
    if (_isSelecting || _selectedTradingPointId == tradingPoint.id) {
      return;
    }

    setState(() {
      _isSelecting = true;
    });

    final result = await AppSessionService.selectTradingPoint(tradingPoint);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось выбрать торговую точку: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (session) {
        setState(() {
          _selectedTradingPoint = session.appUser.selectedTradingPoint;
          _selectedTradingPointId = session.appUser.selectedTradingPointId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Текущая точка: ${tradingPoint.name}'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        _isSelecting = false;
      });
    }
  }

  Future<void> _openTradingPointDetails(TradingPoint tradingPoint) async {
    final selectionChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TradingPointDetailPage(
          tradingPoint: tradingPoint,
        ),
      ),
    );

    if (selectionChanged == true) {
      await _syncSelectionFromSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Торговые точки'),

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
          if (_selectedTradingPoint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Текущая торговая точка',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedTradingPoint!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedTradingPoint!.externalId.isNotEmpty)
                      Text(
                        'ID: ${_selectedTradingPoint!.externalId}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
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
    final theme = Theme.of(context);
    final isSelected = _selectedTradingPointId == tradingPoint.id;
    return InkWell(
      onTap: () => _openTradingPointDetails(tradingPoint),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black87, width: 1.2),
              ),
              child: const Icon(Icons.store, color: Colors.black87, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tradingPoint.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black87, width: 1),
                        ),
                        child: Text(
                          tradingPoint.region,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID: ${tradingPoint.externalId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  if (tradingPoint.inn != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ИНН: ${tradingPoint.inn}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Текущая точка',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: _isSelecting
                      ? null
                      : () => _handleSelectTradingPoint(tradingPoint),
                  icon: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: Colors.black87,
                  ),
                  tooltip: isSelected ? 'Уже выбрана' : 'Сделать текущей',
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
