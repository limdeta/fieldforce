import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:flutter/material.dart';
import 'package:fieldforce/app/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppUser? _appUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

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

      setState(() {
        _appUser = session.appUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки профиля: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_appUser == null) {
      return const Center(
        child: Text('Пользователь не найден'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар и основная информация
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _getInitials(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _appUser!.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getRoleDisplayName(_appUser!.employee.role),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Детальная информация
          const Text(
            'Личная информация',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            'Фамилия',
            _appUser!.lastName ?? 'Не указано',
          ),

          _buildInfoCard(
            'Имя',
            _appUser!.firstName,
          ),

          _buildInfoCard(
            'Отчество',
            _appUser!.employee.middleName ?? 'Не указано',
          ),

          _buildInfoCard(
            'Телефон',
            _appUser!.phoneNumber,
          ),

          _buildInfoCard(
            'Роль',
            _getRoleDisplayName(_appUser!.employee.role),
          ),

          _buildInfoCard(
            'ID пользователя',
            _appUser!.id.toString(),
          ),

          if (_appUser!.selectedTradingPoint != null) ...[
            const SizedBox(height: 32),
            const Text(
              'Текущая торговая точка',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Название',
              _appUser!.selectedTradingPoint!.name,
            ),
            _buildInfoCard(
              'ИНН',
              _appUser!.selectedTradingPoint!.inn ?? 'Не указан',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final firstName = _appUser?.firstName ?? '';
    final lastName = _appUser?.lastName ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else {
      return 'U';
    }
  }

  String _getRoleDisplayName(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.sales:
        return 'Торговый представитель';
      case EmployeeRole.supervisor:
        return 'Супервайзер';
      case EmployeeRole.manager:
        return 'Менеджер';
    }
  }
}