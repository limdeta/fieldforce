import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Простая карта без зависимостей для тестирования
class TestMapPage extends StatefulWidget {
  const TestMapPage({super.key});

  @override
  State<TestMapPage> createState() => _TestMapPageState();
}

class _TestMapPageState extends State<TestMapPage> {
  // Текущая позиция пользователя
  LatLng? _currentPosition;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест карты'),
        backgroundColor: Colors.blue,
        actions: [
          // Кнопка тестирования
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🐛 Тест кнопка работает!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Тест',
          ),
          // Кнопка имитации геолокации
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _currentPosition = const LatLng(43.1198, 131.8869);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 Геолокация установлена на Владивосток!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Геолокация',
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(43.1198, 131.8869), // Владивосток
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.fieldforce.app',
          ),
          MarkerLayer(
            markers: [
              // Маркер центра Владивостока
              const Marker(
                point: LatLng(43.1198, 131.8869),
                child: Icon(
                  Icons.location_city,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              // Маркер текущей позиции
              if (_currentPosition != null)
                Marker(
                  point: _currentPosition!,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentPosition = const LatLng(43.1156, 131.8855);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚗 Переместились в новую точку!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        child: const Icon(Icons.directions_car),
      ),
    );
  }
}
