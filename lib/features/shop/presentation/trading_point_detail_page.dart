import 'package:flutter/material.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';

/// Страница детализации торговой точки
class TradingPointDetailPage extends StatefulWidget {
  final TradingPoint tradingPoint;

  const TradingPointDetailPage({
    super.key,
    required this.tradingPoint,
  });

  @override
  State<TradingPointDetailPage> createState() => _TradingPointDetailPageState();
}

class _TradingPointDetailPageState extends State<TradingPointDetailPage> {
  bool _isProcessing = false;
  int? _selectedTradingPointId;

  @override
  void initState() {
    super.initState();
    _loadSelectionState();
  }

  Future<void> _loadSelectionState() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();
    if (!mounted) return;

    sessionResult.fold(
      (_) {},
      (session) {
        setState(() {
          _selectedTradingPointId = session?.appUser.selectedTradingPointId;
        });
      },
    );
  }

  bool get _isCurrentlySelected =>
      _selectedTradingPointId == widget.tradingPoint.id;

  Future<void> _handleSelect() async {
    if (_isCurrentlySelected) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await AppSessionService.selectTradingPoint(widget.tradingPoint);
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
          _selectedTradingPointId = session.appUser.selectedTradingPointId;
        });
        Navigator.pop(context, true);
      },
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleClearSelection() async {
    if (!_isCurrentlySelected) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await AppSessionService.clearSelectedTradingPoint();
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось снять выбор: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (session) {
        setState(() {
          _selectedTradingPointId = session.appUser.selectedTradingPointId;
        });
        Navigator.pop(context, true);
      },
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tradingPoint.name),

        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isProcessing ? null : _handleSelect,
            icon: Icon(
              _isCurrentlySelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            tooltip: _isCurrentlySelected
                ? 'Текущая торговая точка'
                : 'Сделать текущей',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isCurrentlySelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Эта торговая точка выбрана как текущая',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Основная информация
            _DetailSection(
              icon: Icons.store,
              title: 'Основная информация',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Название', widget.tradingPoint.name),
                  _buildInfoRow('Регион', widget.tradingPoint.region),
                  if (widget.tradingPoint.inn != null)
                    _buildInfoRow('ИНН', widget.tradingPoint.inn!),
                  _buildInfoRow('Внешний ID', widget.tradingPoint.externalId),
                  _buildInfoRow(
                    'Дата создания',
                    _formatDate(widget.tradingPoint.createdAt),
                  ),
                  if (widget.tradingPoint.updatedAt != null)
                    _buildInfoRow(
                      'Дата обновления',
                      _formatDate(widget.tradingPoint.updatedAt!),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.shopping_cart_outlined,
              title: 'Заказы',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 4),
                  Text(
                    'Информация о заказах появится позже',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Заглушка под карту
            _DetailSection(
              icon: Icons.location_on_outlined,
              title: 'Местоположение',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: Colors.black45,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Карта местоположения',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Будет реализована позже',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Дополнительная информация (заглушка)
            _DetailSection(
              icon: Icons.info_outline,
              title: 'Дополнительно',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.pending, color: Colors.black54),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Дополнительные данные будут доступны позднее.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleSelect,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isCurrentlySelected
                                ? Icons.check_circle
                                : Icons.radio_button_checked,
                          ),
                    label: Text(
                      _isCurrentlySelected
                          ? 'Точка выбрана'
                          : 'Сделать текущей',
                    ),
                  ),
                ),
              ],
            ),
            if (_isCurrentlySelected) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _isProcessing ? null : _handleClearSelection,
                  child: const Text('Снять выбор'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
