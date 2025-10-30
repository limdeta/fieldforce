import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '../config/app_config.dart';
import 'update_service.dart';

/// Обёртка для системы обновлений
/// Комбинирует автоматическую проверку через upgrader (для App Store/Google Play)
/// с кастомной проверкой через наш сервер
class UpgraderWrapper extends StatefulWidget {
  final Widget child;
  
  const UpgraderWrapper({
    super.key,
    required this.child,
  });

  @override
  State<UpgraderWrapper> createState() => _UpgraderWrapperState();
}

class _UpgraderWrapperState extends State<UpgraderWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Временно отключаем автоматическую проверку обновлений при старте
    // чтобы избежать ошибки с MaterialLocalizations
    /*
    if (AppConfig.checkForUpdates) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdatesOnStartup();
      });
    }
    */
  }

  Future<void> _checkForUpdatesOnStartup() async {
    // Небольшая задержка чтобы UI успел загрузиться
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      await UpdateService.checkForUpdatesIfEnabled(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.checkForUpdates) {
      return widget.child; // Проверка обновлений отключена
    }

    // Используем upgrader только для продакшена (App Store/Google Play)
    if (AppConfig.isProd) {
      return UpgradeAlert(
        child: widget.child,
      );
    }

    // В dev/test режиме используем только наш кастомный сервер
    return widget.child;
  }
}