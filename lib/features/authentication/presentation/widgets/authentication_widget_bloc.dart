import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

/// Независимый виджет аутентификации с BLoC
/// 
/// Особенности:
/// - Использует AuthenticationBloc для управления состоянием
/// - Не знает про AppSession, навигацию, инициализацию
/// - Работает только с authentication domain
/// - Полностью переиспользуемый компонент
/// - Вся app-логика обрабатывается родительским виджетом через BlocListener
class AuthenticationWidget extends StatefulWidget {
  final String? initialPhone;
  final String? initialPassword;
  final bool showTestData;
  
  const AuthenticationWidget({
    super.key,
    this.initialPhone,
    this.initialPassword,
    this.showTestData = false,
  });

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      final cleaned = widget.initialPhone!.replaceAll(RegExp(r'[^\d]'), '');
      String localPart = cleaned;
      if (cleaned.startsWith('7') && cleaned.length == 11) {
        localPart = cleaned.substring(1);
      } else if (cleaned.startsWith('8') && cleaned.length == 11) {
        localPart = cleaned.substring(1);
      } else if (cleaned.length == 10) {
        localPart = cleaned;
      }
      _phoneController.text = localPart;
    }
    if (widget.initialPassword != null) {
      _passwordController.text = widget.initialPassword!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final raw = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      String phoneString;
      if (raw.length == 10) {
        phoneString = '7$raw';
      } else if (raw.length == 11 && raw.startsWith('7')) {
        phoneString = raw;
      } else {
        phoneString = raw;
      }

      context.read<AuthenticationBloc>().add(
        AuthenticationLoginRequested(
          phoneNumber: phoneString,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isLoading = state is AuthenticationLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone number field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Номер телефона',
                  hintText: '999-111-2233',
                  prefixText: '+7 ',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                enabled: !isLoading,
                validator: (value) {
                  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.isEmpty) {
                    return 'Введите номер телефона';
                  }
                  if (digits.length != 10) {
                    return 'Номер телефона должен содержать 10 цифр без кода страны';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Remember me checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Запомнить меня'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Login button
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Войти'),
              ),
              
              // Test data section
              if (widget.showTestData) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Тестовые данные:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildTestDataInfo(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestDataInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Используйте эти данные для входа:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.initialPhone != null ? '+7${widget.initialPhone}' : '+7-999-111-2233',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  _phoneController.text = widget.initialPhone ?? '999-111-2233';
                },
                tooltip: 'Скопировать',
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.lock, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.initialPassword ?? 'password123',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  _passwordController.text = widget.initialPassword ?? 'password123';
                },
                tooltip: 'Скопировать',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
