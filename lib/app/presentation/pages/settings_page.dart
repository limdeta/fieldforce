import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/features/shop/domain/entities/catalog_display_mode.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserPreferencesService _preferencesService =
      GetIt.instance<UserPreferencesService>();

  late CatalogDisplayMode _catalogMode;

  @override
  void initState() {
    super.initState();
    _catalogMode = _preferencesService.getCatalogDisplayMode();
  }

  Future<void> _onCatalogModeChanged(CatalogDisplayMode? mode) async {
    if (mode == null || mode == _catalogMode) return;

    setState(() {
      _catalogMode = mode;
    });

    await _preferencesService.setCatalogDisplayMode(mode);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Режим каталога: ${mode.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleCheckUpdates() {
    SimpleUpdateService.checkForUpdatesIfEnabled(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCatalogModeCard(context),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: 'Проверить обновления',
            icon: Icons.system_update,
            onTap: _handleCheckUpdates,
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogModeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Режим каталога',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите, как отображаются категории и список товаров.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<CatalogDisplayMode>(
              segments: const [
                ButtonSegment<CatalogDisplayMode>(
                  value: CatalogDisplayMode.classic,
                  label: Text('Классический'),
                  icon: Icon(Icons.view_day_outlined),
                ),
                ButtonSegment<CatalogDisplayMode>(
                  value: CatalogDisplayMode.split,
                  label: Text('Сплит'),
                  icon: Icon(Icons.view_week_outlined),
                ),
              ],
              selected: <CatalogDisplayMode>{_catalogMode},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                final mode = selection.first;
                _onCatalogModeChanged(mode);
              },
            ),
            const SizedBox(height: 12),
            Text(
              _catalogMode == CatalogDisplayMode.classic
                  ? 'Категории и товары открываются на отдельных экранах.'
                  : 'Категории и товары отображаются одновременно и разделитель можно перетаскивать.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: const RoundedRectangleBorder(),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
